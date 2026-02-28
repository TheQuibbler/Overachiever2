"""
Runs the full Overachiever2 NPC database generation pipeline:
  1. fetch_resources.py           - Download CSV and lua files
  2. generate_intermediate_npc_list.py - Build intermediate npc_list.txt
  3. generate_npc_db2.py          - Generate DBNpc.lua from npc_list.txt
"""

import subprocess
import sys
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

scripts = [
    "fetch_resources.py",
    "generate_intermediate_npc_list.py",
    "generate_npc_db2.py",
]

for script in scripts:
    print(f"\n{'=' * 60}")
    print(f"Running {script}...")
    print('=' * 60)
    result = subprocess.run([sys.executable, os.path.join(SCRIPT_DIR, script)])
    if result.returncode != 0:
        print(f"\n❌ {script} failed with exit code {result.returncode}. Aborting.")
        sys.exit(result.returncode)

print(f"\n{'=' * 60}")
print("✅ All steps completed successfully!")
print('=' * 60)
