"""
================================================================================
Overachiever2 - Resource Downloader
================================================================================

OVERVIEW:
    This script downloads the DB2 CSV files from wago.tools, SilverDragon's
    achievements.lua from GitHub, and AllTheThings' db/Standard/Categories lua
    files from GitHub, all required to generate npcAchievements.lua.
    All downloaded files are stored in a "resources" directory along with
    version/hash information. The three download sources are checked independently.

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

    3. AllTheThings db/Standard/Categories:
       The GitHub Contents API returns a list of files with their git blob SHAs.
       All filename:sha pairs are stored as JSON in resources/.last_att_db_standard.
       If any file is added, removed, or modified, the stored fingerprint will
       differ and all files are re-downloaded.

DATA SOURCES:
    - Achievement.csv   : Achievement ID, name, and root CriteriaTree ID  (wago.tools)
    - CriteriaTree.csv  : Tree structure linking achievements to criteria   (wago.tools)
    - Criteria.csv      : Individual criteria with type, asset, criteriaID  (wago.tools)
    - ModifierTree.csv  : NPC ID lookup for emote-type criteria (Type 54)   (wago.tools)
    - achievements.lua  : Curated NPC→criteria mappings for Type 27         (SilverDragon/GitHub)
    - db/Standard/Categories/*.lua : AllTheThings achievement/NPC data      (ATT/GitHub)

OUTPUT:
    resources/Achievement.csv          - Downloaded CSV file
    resources/CriteriaTree.csv         - Downloaded CSV file
    resources/Criteria.csv             - Downloaded CSV file
    resources/ModifierTree.csv         - Downloaded CSV file
    resources/achievements.lua         - Downloaded SilverDragon file
    resources/AllTheThings/db/Standard/Categories/*.lua - Downloaded ATT files
    resources/.last_build              - Last downloaded WoW build version
    resources/.last_silverdragon_sha   - Last downloaded SilverDragon git SHA
    resources/.last_att_db_standard    - Last downloaded ATT file fingerprint (JSON)

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

# AllTheThings db/Standard/Categories - lua files with achievement/NPC data.
# The GitHub Contents API lists all files in the directory with their git SHAs.
ATT_CATEGORIES_API = "https://api.github.com/repos/ATTWoWAddon/AllTheThings/contents/db/Standard/Categories"
ATT_CATEGORIES_DIR = os.path.join(RESOURCES_DIR, "AllTheThings", "db", "Standard", "Categories")

# Hidden file that stores a JSON fingerprint of all file SHAs in the ATT Categories directory.
# If any file changes, is added, or removed, the fingerprint will differ.
ATT_SHA_FILE = os.path.join(RESOURCES_DIR, ".last_att_db_standard")


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


# ── AllTheThings Functions ────────────────────────────────────────────────────

def get_remote_att_files():
    """
    Fetches the list of files in ATT's db/Standard/Categories from the GitHub API.

    Uses the GitHub Contents API which returns an array of file objects, each
    containing the filename, git blob SHA, and download URL.

    Returns:
        list: List of dicts with keys "name", "sha", "download_url".
        None: If the request fails.
    """
    try:
        req = urllib.request.Request(ATT_CATEGORIES_API, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return [
                {"name": item["name"], "sha": item["sha"], "download_url": item["download_url"]}
                for item in data
                if item["type"] == "file"
            ]
    except Exception as e:
        print(f"⚠️  Failed to fetch ATT Categories listing: {e}")
        return None


def build_att_fingerprint(file_list):
    """
    Builds a JSON fingerprint string from a list of ATT file entries.

    The fingerprint is a sorted JSON dict of {filename: sha} pairs.
    It changes whenever any file is added, removed, or modified.

    Args:
        file_list (list): List of dicts with "name" and "sha" keys.

    Returns:
        str: JSON string representing the fingerprint.
    """
    sha_dict = {f["name"]: f["sha"] for f in file_list}
    return json.dumps(sha_dict, sort_keys=True)


def get_last_att_fingerprint():
    """
    Reads the ATT fingerprint from the last successful download.

    Returns:
        str: Previously saved fingerprint JSON string.
        None: If the file does not exist (first run or never downloaded).
    """
    if os.path.exists(ATT_SHA_FILE):
        with open(ATT_SHA_FILE) as f:
            return f.read().strip()
    return None


def save_att_fingerprint(fingerprint):
    """
    Saves the ATT fingerprint after a successful download.

    Args:
        fingerprint (str): JSON fingerprint string to save.
    """
    with open(ATT_SHA_FILE, "w") as f:
        f.write(fingerprint)


def download_att_categories(file_list):
    """
    Downloads all files from ATT's db/Standard/Categories to the local directory.

    Args:
        file_list (list): List of dicts with "name" and "download_url" keys.

    Returns:
        bool: True if all files downloaded successfully, False otherwise.
    """
    os.makedirs(ATT_CATEGORIES_DIR, exist_ok=True)

    for file_info in file_list:
        filename = file_info["name"]
        url = file_info["download_url"]
        filepath = os.path.join(ATT_CATEGORIES_DIR, filename)
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

# ── 3. AllTheThings db/Standard/Categories ────────────────────────────────────
print("--- AllTheThings db/Standard/Categories ---")
print("Checking ATT Categories...", end=" ", flush=True)
att_files = get_remote_att_files()

if att_files:
    remote_fingerprint = build_att_fingerprint(att_files)
    print(f"{len(att_files)} files found")
else:
    remote_fingerprint = None
    print("(unavailable)")

local_fingerprint = get_last_att_fingerprint()

if local_fingerprint:
    local_count = len(json.loads(local_fingerprint))
    print(f"Last downloaded:     {local_count} files")
else:
    print("Last downloaded:     (none - first run)")

if not force and remote_fingerprint and remote_fingerprint == local_fingerprint:
    print("✅ ATT Categories already up to date.\n")
else:
    if att_files is None:
        print("⚠️  Cannot check for updates (offline?). Skipping.\n")
    else:
        if force:
            print("🔄 Force download mode")
        elif not local_fingerprint:
            print("🆕 First download...")
        else:
            print("🆕 ATT Categories changed!")

        if download_att_categories(att_files):
            save_att_fingerprint(remote_fingerprint)
            print(f"✅ {len(att_files)} ATT Categories files downloaded.\n")
        else:
            print("❌ ATT Categories download failed.\n")

# ── Summary ───────────────────────────────────────────────────────────────────
print(f"Resources directory: {RESOURCES_DIR}/")
print("Next step: Run 'python generate_npc_db.py' to process these files.")
