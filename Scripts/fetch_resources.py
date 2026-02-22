"""
================================================================================
Overachiever2 - Resource Downloader
================================================================================

OVERVIEW:
    This script downloads the DB2 CSV files from wago.tools that are required
    to generate npcAchievements.lua. All downloaded files are stored in a
    "resources" directory along with version information.

USAGE:
    Normal run (only downloads if a new WoW patch is detected):
        python fetch_resources.py

    Force download regardless of patch version:
        python fetch_resources.py --force

HOW PATCH DETECTION WORKS:
    wago.tools serves CSV files with a build version embedded in the
    Content-Disposition HTTP header, e.g.:
        filename="Achievement.12.0.1.66044.csv"
    This script extracts that version string and compares it against the
    version saved in resources/.last_build from the previous run. If they match,
    download is skipped. If they differ (or .last_build doesn't exist),
    the script downloads fresh CSVs.

DATA SOURCES (all from wago.tools, which mirrors WoW's DB2 game files):
    - Achievement.csv   : Achievement ID, name, and root CriteriaTree ID
    - CriteriaTree.csv  : Tree structure linking achievements to criteria
    - Criteria.csv      : Individual criteria with type, asset, and criteriaID
    - ModifierTree.csv  : NPC ID lookup for emote-type criteria (Type 54)

OUTPUT:
    resources/Achievement.csv   - Downloaded CSV file
    resources/CriteriaTree.csv  - Downloaded CSV file
    resources/Criteria.csv      - Downloaded CSV file
    resources/ModifierTree.csv  - Downloaded CSV file
    resources/.last_build       - Hidden file storing the last downloaded build version

NEXT STEP:
    After downloading, run generate_npc_db.py to process these files and
    generate the npcAchievements.lua file.
================================================================================
"""

import urllib.request
import urllib.error
import os
import sys

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


# ── CSV Download ──────────────────────────────────────────────────────────────

def download_csvs():
    """
    Downloads the four DB2 CSV files from wago.tools to the resources directory.

    Downloads Achievement.csv, Criteria.csv, CriteriaTree.csv, and ModifierTree.csv
    into the resources directory, overwriting any existing files.

    wago.tools always serves the latest retail build, so re-downloading
    guarantees we have up-to-date data after a patch.

    Returns:
        bool: True if all four files downloaded successfully, False otherwise.
              On the first failure, the function returns immediately without
              attempting the remaining downloads.
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

# Check if --force flag was passed to bypass patch version comparison
force = "--force" in sys.argv

# Fetch the current build version from wago.tools and compare with last download
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

# ── Patch detection: decide whether to proceed ────────────────────────────────
if not force and latest and latest == last:
    # Build version unchanged since last download — nothing to do
    print(f"\n✅ Already up to date (build {latest}).")
    print("   To force download: python fetch_resources.py --force")
    sys.exit(0)

if latest and last and latest != last:
    print(f"\n🆕 New patch detected! ({last} → {latest})")
elif not last:
    print("\n🆕 First run - downloading data...")
else:
    print("\n🔄 Force download mode")

# ── Download fresh CSVs ───────────────────────────────────────────────────────
print("\n--- Downloading CSVs ---")
if not download_csvs():
    print("❌ Download failed. Aborting.")
    sys.exit(1)

# ── Save build version for next run ───────────────────────────────────────────
if latest:
    save_build(latest)
    print(f"\n✅ Done! Build {latest} downloaded to {RESOURCES_DIR}/")
    print(f"   Next step: Run 'python generate_npc_db.py' to process these files.")
else:
    # If we couldn't determine the build version (e.g. offline during version check
    # but still managed to download CSVs somehow), we still complete but can't save a
    # version. The next run will re-download CSVs since no version is on record.
    print(f"\n✅ Done! Files downloaded to {RESOURCES_DIR}/")
    print("   ⚠️  Could not save build number (will re-download on next run)")
    print(f"   Next step: Run 'python generate_npc_db.py' to process these files.")
