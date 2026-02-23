"""
================================================================================
Overachiever2 - Resource Downloader
================================================================================

OVERVIEW:
    This script downloads the DB2 CSV files from wago.tools and SilverDragon's
    achievements.lua from GitHub, both required to generate npcAchievements.lua.
    All downloaded files are stored in a "resources" directory along with
    version/hash information. The two download sources are checked independently.

USAGE:
    Normal run (only downloads if updates are detected):
        python fetch_resources.py

    Force download regardless of version/SHA:
        python fetch_resources.py --force

HOW UPDATE DETECTION WORKS:
    1. SilverDragon achievements.lua:
       The GitHub Contents API returns a git blob SHA for the file. This SHA is
       compared against the value saved in resources/.last_silverdragon_sha.
       If they differ (or the file hasn't been downloaded yet), a fresh copy is
       downloaded from GitHub.

    2. wago.tools DB2 CSVs:
       wago.tools serves CSV files with a build version embedded in the
       Content-Disposition HTTP header, e.g.:
           filename="Achievement.12.0.1.66044.csv"
       This version is compared against resources/.last_build from the previous
       run. If they differ (or .last_build doesn't exist), fresh CSVs are
       downloaded.

DATA SOURCES:
    - Achievement.csv   : Achievement ID, name, and root CriteriaTree ID  (wago.tools)
    - CriteriaTree.csv  : Tree structure linking achievements to criteria   (wago.tools)
    - Criteria.csv      : Individual criteria with type, asset, criteriaID  (wago.tools)
    - ModifierTree.csv  : NPC ID lookup for emote-type criteria (Type 54)   (wago.tools)
    - achievements.lua  : Curated NPC→criteria mappings for Type 27         (SilverDragon/GitHub)

OUTPUT:
    resources/Achievement.csv          - Downloaded CSV file
    resources/CriteriaTree.csv         - Downloaded CSV file
    resources/Criteria.csv             - Downloaded CSV file
    resources/ModifierTree.csv         - Downloaded CSV file
    resources/achievements.lua         - Downloaded SilverDragon file
    resources/.last_build              - Last downloaded WoW build version
    resources/.last_silverdragon_sha   - Last downloaded SilverDragon git SHA

NEXT STEP:
    After downloading, run generate_npc_db.py to process these files and
    generate the npcAchievements.lua file.
================================================================================
"""

import urllib.request
import urllib.error
import os
import sys
import json

# ── Path Detection ────────────────────────────────────────────────────────────

# Automatically detect project root directory (parent of Scripts directory)
# This allows the script to be run from any directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)  # Go up one level from Scripts/

# ── Configuration ─────────────────────────────────────────────────────────────

# Directory where all downloaded resources will be stored
RESOURCES_DIR = os.path.join(PROJECT_ROOT, "Scripts", "resources")

# Hidden file that persists the WoW build version from the last successful download.
# Used to detect whether a new patch has been released since last execution.
VERSION_FILE = os.path.join(RESOURCES_DIR, ".last_build")

# wago.tools CSV export URLs for the four DB2 tables we need.
# These always serve the latest retail build data.
URLS = {
    "Achievement.csv":  "https://wago.tools/db2/Achievement/csv",
    "Criteria.csv":     "https://wago.tools/db2/Criteria/csv",
    "CriteriaTree.csv": "https://wago.tools/db2/CriteriaTree/csv",
    "ModifierTree.csv": "https://wago.tools/db2/ModifierTree/csv",
}

# SilverDragon achievements.lua URL.
# This file contains manually curated NPC ID → criteriaID mappings for
# Type 27 (quest-based) achievements that cannot be derived from DB2 files alone.
# Tracked independently from the WoW build version via its git blob SHA.
SILVERDRAGON_URL  = "https://raw.githubusercontent.com/kemayo/wow-silverdragon/master/achievements.lua"
SILVERDRAGON_FILE = os.path.join(RESOURCES_DIR, "achievements.lua")

# GitHub API URL to query the file's git SHA without downloading the full content.
SILVERDRAGON_API  = "https://api.github.com/repos/kemayo/wow-silverdragon/contents/achievements.lua"

# Hidden file that persists the git SHA of the last downloaded SilverDragon file.
# Tracked independently from the WoW build version.
SILVERDRAGON_SHA_FILE = os.path.join(RESOURCES_DIR, ".last_silverdragon_sha")


# ── Build Version Functions ───────────────────────────────────────────────────

def get_latest_build():
    """
    Fetches the current WoW retail build version from wago.tools.

    wago.tools embeds the build version in the Content-Disposition HTTP header
    of its CSV downloads, e.g.:
        content-disposition: attachment; filename="Achievement.12.0.1.66044.csv"

    We download Achievement.csv, read only the response headers, and parse
    the version string from the filename.

    Returns:
        str: Build version string, e.g. "12.0.1.66044"
        None: If the request fails or the header is missing/malformed
    """
    url = "https://wago.tools/db2/Achievement/csv"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            disposition = resp.headers.get("content-disposition", "")

            # The header looks like:
            #   attachment; filename="Achievement.12.0.1.66044.csv"; filename*=UTF-8''...
            # We split on ";" and look for the part starting with "filename="
            for part in disposition.split(";"):
                part = part.strip()
                if part.startswith("filename="):
                    # Extract the raw filename value, stripping quotes
                    filename = part.replace("filename=", "").strip().strip('"')
                    # filename is now: "Achievement.12.0.1.66044.csv"
                    # Remove the "Achievement." prefix and ".csv" suffix
                    version = filename.replace("Achievement.", "").replace(".csv", "")
                    return version  # e.g. "12.0.1.66044"
        return None
    except Exception as e:
        print(f"⚠️  Failed to fetch build identifier: {e}")
        return None


def get_last_build():
    """
    Reads the WoW build version from the last successful download.

    The version is stored in VERSION_FILE (resources/.last_build) as a plain text string.
    This file is created/updated at the end of each successful download.

    Returns:
        str: Previously saved build version, e.g. "12.0.1.66044"
        None: If VERSION_FILE does not exist (i.e. first run)
    """
    if os.path.exists(VERSION_FILE):
        with open(VERSION_FILE) as f:
            return f.read().strip()
    return None


def save_build(version):
    """
    Saves the current WoW build version to VERSION_FILE (resources/.last_build).

    Called at the end of a successful download so the next execution can compare
    against it to determine whether a new patch has been released.

    Args:
        version (str): Build version string to save, e.g. "12.0.1.66044"
    """
    with open(VERSION_FILE, "w") as f:
        f.write(version)


# ── SilverDragon SHA Functions ────────────────────────────────────────────────

def get_remote_silverdragon_sha():
    """
    Fetches the git SHA of achievements.lua from the GitHub API.

    Uses the GitHub Contents API which returns file metadata (including the git
    blob SHA) without downloading the full file content.

    Returns:
        str: Git blob SHA, e.g. "a1b2c3d4..."
        None: If the request fails
    """
    try:
        req = urllib.request.Request(SILVERDRAGON_API, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data.get("sha")
    except Exception as e:
        print(f"⚠️  Failed to fetch SilverDragon SHA: {e}")
        return None


def get_last_silverdragon_sha():
    """
    Reads the git SHA from the last successful SilverDragon download.

    Returns:
        str: Previously saved SHA
        None: If the file does not exist (first run or never downloaded)
    """
    if os.path.exists(SILVERDRAGON_SHA_FILE):
        with open(SILVERDRAGON_SHA_FILE) as f:
            return f.read().strip()
    return None


def save_silverdragon_sha(sha):
    """
    Saves the SilverDragon git SHA after a successful download.

    Args:
        sha (str): Git blob SHA to save
    """
    with open(SILVERDRAGON_SHA_FILE, "w") as f:
        f.write(sha)


def download_silverdragon():
    """
    Downloads achievements.lua from SilverDragon's GitHub repository.

    Returns:
        bool: True if downloaded successfully, False otherwise.
    """
    print(f"  Downloading: achievements.lua (SilverDragon) ...", end=" ", flush=True)
    try:
        req = urllib.request.Request(SILVERDRAGON_URL, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=30) as resp:
            with open(SILVERDRAGON_FILE, "wb") as f:
                f.write(resp.read())
        print("✅")
        return True
    except Exception as e:
        print(f"⚠️  Failed (Type 27 mappings will be skipped): {e}")
        return False


# ── CSV Download ──────────────────────────────────────────────────────────────

def download_csvs():
    """
    Downloads the four DB2 CSV files from wago.tools to the resources directory.

    Downloads Achievement.csv, Criteria.csv, CriteriaTree.csv, and ModifierTree.csv
    into the resources directory, overwriting any existing files.

    Returns:
        bool: True if all files downloaded successfully, False otherwise.
    """
    for filename, url in URLS.items():
        filepath = os.path.join(RESOURCES_DIR, filename)
        print(f"  Downloading: {filename} ...", end=" ", flush=True)
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=30) as resp:
                with open(filepath, "wb") as f:
                    f.write(resp.read())
            print("✅")
        except Exception as e:
            print(f"❌ Failed: {e}")
            return False

    return True


# ── Main ──────────────────────────────────────────────────────────────────────

print("=== Overachiever2 Resource Downloader ===\n")

# Create resources directory if it doesn't exist
if not os.path.exists(RESOURCES_DIR):
    print(f"Creating {RESOURCES_DIR} directory...")
    os.makedirs(RESOURCES_DIR)

# Check if --force flag was passed to bypass version/SHA comparison
force = "--force" in sys.argv

# ── 1. SilverDragon achievements.lua (independent of WoW build) ──────────────
print("--- SilverDragon achievements.lua ---")
print("Checking SilverDragon SHA...", end=" ", flush=True)
remote_sha = get_remote_silverdragon_sha()
local_sha  = get_last_silverdragon_sha()

if remote_sha:
    print(f"Remote: {remote_sha[:12]}...")
else:
    print("(unavailable)")

if local_sha:
    print(f"Last downloaded SHA:  {local_sha[:12]}...")
else:
    print("Last downloaded SHA:  (none - first run)")

if not force and remote_sha and remote_sha == local_sha:
    print("✅ SilverDragon achievements.lua is up to date.\n")
else:
    if force:
        print("🔄 Force download mode")
    elif not local_sha or not os.path.exists(SILVERDRAGON_FILE):
        print("🆕 First download...")
    else:
        print("🆕 SilverDragon file changed!")

    if download_silverdragon() and remote_sha:
        save_silverdragon_sha(remote_sha)
    print()

# ── 2. wago.tools DB2 CSVs (tied to WoW build version) ──────────────────────
print("--- wago.tools DB2 CSVs ---")
print("Checking current WoW build...", end=" ", flush=True)
latest = get_latest_build()
last   = get_last_build()

if latest:
    print(f"Latest: {latest}")
else:
    print("(unavailable - offline?)")

if last:
    print(f"Last downloaded build: {last}")
else:
    print("Last downloaded build: (none - first run)")

if not force and latest and latest == last:
    print("✅ CSVs already up to date (build {}).\n".format(latest))
else:
    if latest and last and latest != last:
        print(f"\n🆕 New patch detected! ({last} → {latest})")
    elif not last:
        print("\n🆕 First run - downloading data...")
    else:
        print("\n🔄 Force download mode")

    if not download_csvs():
        print("❌ CSV download failed. Aborting.")
        sys.exit(1)

    if latest:
        save_build(latest)
        print(f"✅ Build {latest} downloaded.\n")
    else:
        print("✅ CSVs downloaded.")
        print("⚠️  Could not save build number (will re-download on next run)\n")

# ── Summary ───────────────────────────────────────────────────────────────────
print(f"Resources directory: {RESOURCES_DIR}/")
print("Next step: Run 'python generate_npc_db.py' to process these files.")
