import os
import re
import sys
import subprocess
import zipfile

# ── Configuration ──────────────────────────────────────────────────────────
# All addon directories included in the release.
# The first entry is treated as the primary addon (used for version checks).
# To add a new addon, simply append its directory name here.
ADDON_DIRS = [
    "Overachiever2",
    "Overachiever2_Tabs",
]
# ───────────────────────────────────────────────────────────────────────────

def toc_path_for(addon_dir):
    """Return the .toc file path for a given addon directory (e.g., Overachiever2/Overachiever2.toc)."""
    return os.path.join(addon_dir, f"{addon_dir}.toc")

def run_command(command):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    return result

def update_release():
    if len(sys.argv) < 2:
        print("❌ Usage: python release.py 1.0.2")
        return

    new_version = sys.argv[1]

    # Validation: Enforce at least 3 version components (e.g., 1.0.0)
    if not re.match(r'^\d+(\.\d+){2,}$', new_version):
        print(f"❌ Invalid version format: '{new_version}'. Format must be X.Y.Z (e.g., 1.0.2).")
        return

    # Version check uses the primary (first) addon's TOC
    primary_toc = toc_path_for(ADDON_DIRS[0])
    main_notes_path = "RELEASE_NOTES.md"
    new_notes_path = "NEW_RELEASE_NOTES.md"

    # 1. Version Check (Prevent Downgrade)
    if os.path.exists(primary_toc):
        with open(primary_toc, 'r', encoding='utf-8') as f:
            content = f.read()
            match = re.search(r'## Version:\s*([0-9.]+)', content)
            if match:
                old_version = match.group(1)
                # Compare versions using tuples of integers for accuracy (e.g., 1.10 > 1.9)
                if tuple(map(int, new_version.split('.'))) < tuple(map(int, old_version.split('.'))):
                    print(f"⚠️  [ERROR] Downgrade detected! Current: {old_version}, Target: {new_version}")
                    return
                if new_version == old_version:
                    print(f"ℹ️  Version is already {new_version}. Skipping.")
                    return

    # 2. Move Release Notes
    if os.path.exists(new_notes_path) and os.path.exists(main_notes_path):
        with open(new_notes_path, 'r', encoding='utf-8') as f:
            new_notes_content = f.read()

        marker = "## Release notes for next branch cut"
        if marker in new_notes_content:
            parts = new_notes_content.split(marker)
            notes_to_move = parts[1].strip()

            if notes_to_move:
                with open(main_notes_path, 'r', encoding='utf-8') as f:
                    main_content = f.read()

                # Insert the latest version notes at the top
                insert_text = f"## {new_version}\n{notes_to_move}\n\n"
                # Regex finds the first occurrence of "## x.x.x" to insert before it
                main_content = re.sub(r'(##\s+\d+\.\d+\.\d+)', f"{insert_text}\\1", main_content, count=1)

                # Save file as UTF-8 without BOM
                with open(main_notes_path, 'w', encoding='utf-8') as f:
                    f.write(main_content)

                # Reset NEW_RELEASE_NOTES.md
                with open(new_notes_path, 'w', encoding='utf-8') as f:
                    f.write(parts[0] + marker + "\n")

                print("✅ Release notes moved successfully.")

    # 3. Update TOC File Version (all addons in ADDON_DIRS)
    for addon_dir in ADDON_DIRS:
        toc_path = toc_path_for(addon_dir)
        if os.path.exists(toc_path):
            with open(toc_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Use \g<1> to separate the capture group from the version numbers
            new_content = re.sub(r'(## Version:\s*).*', rf"\g<1>{new_version}", content)

            with open(toc_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"✅ TOC version updated: {toc_path} -> {new_version}")
        else:
            print(f"⚠️  TOC not found, skipping: {toc_path}")

    # 4. Git Operations (Stage all changes and commit)
    print("🚀 Staging and Committing...")
    run_command("git add .")
    commit_msg = f"Release {new_version}: Update version and release notes"
    run_command(f'git commit -m "{commit_msg}"')
    print(f"🎊 Successfully committed: {commit_msg}")

    # 5. Create Deployment Zip Archive

    # Create the Release directory if it doesn't exist
    release_dir = "Release"
    if not os.path.exists(release_dir):
        os.makedirs(release_dir)
        print(f"📁 Created directory: {release_dir}")

    zip_filename = f"Overachiever2_{new_version}.zip"
    zip_path = os.path.join(release_dir, zip_filename)

    # Verify all addon directories exist before building
    for addon_dir in ADDON_DIRS:
        if not os.path.exists(addon_dir):
            print(f"❌ [ERROR] Source directory '{addon_dir}' not found. Zip failed.")
            return

    if os.path.exists(zip_path):
        print(f"⚠️  File '{zip_filename}' already exists.")
        response = input("Overwrite? (y/N): ").strip().lower()
        if response != 'y':
            print("❌ Aborted.")
            return

    print(f"📦 Creating archive: {zip_path}...")
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Walk through each addon directory and add to the archive
        for addon_dir in ADDON_DIRS:
            for root, dirs, files in os.walk(addon_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    # Keep each addon's folder name as the root inside the zip
                    zipf.write(file_path, file_path)

    print(f"✨ Build complete! Archive created at: {zip_path}")

if __name__ == "__main__":
    update_release()
