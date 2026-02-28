"""
================================================================================
Overachiever2 - NPC Achievement Database Generator (from npc_list.txt)
================================================================================

OVERVIEW:
    This script reads a pre-generated NPC list from npc_list.txt and generates
    DBNpc.lua, a data file used by the Overachiever2 WoW addon. The lua file
    maps NPC IDs to (achievementID, criteriaID, orderIndex) tuples.

    Unlike generate_npc_db.py which discovers NPC→achievement mappings from
    raw DB2 CSV files, this script uses a curated NPC list that already contains
    (npcID, achievementID, criteriaID) triples. It only needs the CSV files to
    look up the orderIndex for each criteria.

PREREQUISITES:
    Before running this script, you must first run fetch_resources.py to download
    the required CSV files. This script expects the following files to exist:
        - resources/intermediate/npc_list.txt  (pre-generated NPC list)
        - resources/CriteriaTree.csv           (for orderIndex lookup)

USAGE:
    python generate_npc_db2.py

OUTPUT:
    Overachiever2/DBNpc.lua  - Lua table mapping NPC IDs to {achID, criteriaID, orderIndex} tuples
================================================================================
"""

import csv
import os
import re
import sys

# ── Path Detection ────────────────────────────────────────────────────────────

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)

# ── Configuration ─────────────────────────────────────────────────────────────

RESOURCES_DIR = os.path.join(PROJECT_ROOT, "Scripts", "resources")
NPC_LIST_FILE = os.path.join(RESOURCES_DIR, "intermediate", "npc_list.txt")
OUTPUT_LUA = os.path.join(PROJECT_ROOT, "Overachiever2", "DBNpc.lua")
CRITERIA_TREE_CSV = os.path.join(RESOURCES_DIR, "CriteriaTree.csv")


# ── Input Validation ──────────────────────────────────────────────────────────

def check_required_files():
    """
    Verifies that all required files exist.
    If any file is missing, prints an error message and exits the program.
    """
    missing_files = []
    for filepath in [NPC_LIST_FILE, CRITERIA_TREE_CSV]:
        if not os.path.exists(filepath):
            missing_files.append(filepath)

    if missing_files:
        print("❌ Error: Required files are missing:")
        for filepath in missing_files:
            print(f"   - {filepath}")
        print("\n💡 Please run 'python fetch_resources.py' first to download the required files.")
        sys.exit(1)


# ── NPC List Parsing ─────────────────────────────────────────────────────────

def parse_npc_list():
    """
    Parses npc_list.txt and returns a dict mapping npcID to a list of
    (achievementID, criteriaID) tuples.

    Format: npcID = { achievementID, criteriaID }, { achievementID, criteriaID }, ...
    Lines starting with '--' are comments and are ignored.

    Returns:
        dict: npc_id (str) → list of (achID (str), criteriaID (str)) tuples
    """
    npc_data = {}
    with open(NPC_LIST_FILE, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            # Skip empty lines and comments
            if not line or line.startswith("--"):
                continue

            # Parse: npcID = { achID, critID }, { achID, critID }, ...
            m = re.match(r'^(\d+)\s*=\s*(.+)$', line)
            if not m:
                continue

            npc_id = m.group(1)
            pairs_str = m.group(2)

            # Extract all { achID, criteriaID } pairs
            pairs = re.findall(r'\{\s*(\d+)\s*,\s*(\d+)\s*\}', pairs_str)
            if pairs:
                npc_data[npc_id] = [(ach_id, crit_id) for ach_id, crit_id in pairs]

    return npc_data


# ── OrderIndex Lookup ─────────────────────────────────────────────────────────

def build_order_index_map():
    """
    Reads CriteriaTree.csv and builds a mapping from criteriaID to orderIndex.

    The CriteriaTree node that references a given criteriaID has a parent node
    whose OrderIndex + 1 gives the criteriaIndex for
    GetAchievementCriteriaInfo(achID, criteriaIndex).

    Returns:
        dict: criteriaID (str) → orderIndex (int)
    """
    print("   Reading CriteriaTree.csv for orderIndex lookup...")

    # tree_parent[treeID] = parentID
    tree_parent = {}
    # tree_order[treeID] = OrderIndex
    tree_order = {}
    # criteria_to_trees[criteriaID] = [treeID, ...]
    criteria_to_trees = {}

    with open(CRITERIA_TREE_CSV, encoding="utf-8") as f:
        for row in csv.DictReader(f):
            tree_id = row["ID"]
            tree_parent[tree_id] = row.get("Parent", "0")
            tree_order[tree_id] = int(row.get("OrderIndex", "0") or "0")
            cid = row.get("CriteriaID", "0")
            if cid and cid != "0":
                if cid not in criteria_to_trees:
                    criteria_to_trees[cid] = []
                criteria_to_trees[cid].append(tree_id)

    # Build criteriaID → orderIndex mapping
    # For each criteriaID, find its CriteriaTree node, then get the parent's OrderIndex + 1
    order_map = {}
    for crit_id, tree_ids in criteria_to_trees.items():
        # Use the first tree node (most criteria appear in only one tree node)
        tree_id = tree_ids[0]
        parent_id = tree_parent.get(tree_id, "0")
        if parent_id and parent_id != "0":
            order_map[crit_id] = tree_order.get(parent_id, 0) + 1
        else:
            order_map[crit_id] = 1

    print(f"   → {len(order_map)} criteria orderIndex mappings loaded")
    return order_map


# ── Lua Generation ────────────────────────────────────────────────────────────

def generate_lua():
    """
    Reads npc_list.txt, looks up orderIndex from CriteriaTree.csv, and writes
    DBNpc.lua in the same format as generate_npc_db.py.

    Returns:
        int: Number of unique NPC IDs written.
    """
    print("\n--- Generating lua ---")

    # Step 1: Parse the NPC list
    print("1. Reading npc_list.txt...")
    npc_data = parse_npc_list()
    print(f"   → {len(npc_data)} NPCs loaded")

    # Step 2: Build orderIndex lookup from CriteriaTree.csv
    print("2. Building orderIndex lookup...")
    order_map = build_order_index_map()

    # Step 3: Combine NPC data with orderIndex
    print("3. Resolving orderIndex for each entry...")
    npc_to_achievements = {}
    resolved = 0
    defaulted = 0
    for npc_id, pairs in npc_data.items():
        entries = set()
        for ach_id, crit_id in pairs:
            order_index = order_map.get(crit_id, 1)
            if crit_id in order_map:
                resolved += 1
            else:
                defaulted += 1
            entries.add((ach_id, crit_id, order_index))
        npc_to_achievements[npc_id] = entries
    print(f"   → {resolved} entries resolved, {defaulted} defaulted to orderIndex=1")

    # Step 4: Write the lua file
    print(f"4. Writing {os.path.relpath(OUTPUT_LUA, PROJECT_ROOT)}...")
    with open(OUTPUT_LUA, "w", encoding="utf-8") as f:
        f.write("-- Overachiever2: Prebuilt Database\n")
        f.write("-- Auto-generated lookup tables for NPC -> Achievement mappings\n")
        f.write("-- Do not edit manually.\n")
        f.write("-- Format: [npcID] = { {achID, criteriaID, orderIndex}, ... }\n")
        f.write("-- criteriaID  : use with GetAchievementCriteriaInfoByID(achID, criteriaID)\n")
        f.write("-- orderIndex  : use with GetAchievementCriteriaInfo(achID, orderIndex) for localized name\n\n")
        f.write("local _, ns = ...\n\n")
        f.write("ns.DB = ns.DB or {}\n\n")
        f.write("-- NPC ID -> { {achievementID, criteriaID, orderIndex}, ... }\n")
        f.write("ns.DB.Npc = {\n")
        for npc_id, pairs in sorted(npc_to_achievements.items(), key=lambda x: int(x[0])):
            entries = ", ".join(
                f"{{{ach_id}, {crit_id}, {order_idx}}}"
                for ach_id, crit_id, order_idx in sorted(pairs, key=lambda x: (int(x[0]), int(x[1]), int(x[2])))
            )
            f.write(f"    [{npc_id}] = {{ {entries} }},\n")
        f.write("}\n")

    return len(npc_to_achievements)


# ── Main ──────────────────────────────────────────────────────────────────────

print("=== Overachiever2 NPC Database Generator (from npc_list.txt) ===\n")

check_required_files()

count = generate_lua()

print(f"\n✅ Done! {count} NPC mappings written to {os.path.relpath(OUTPUT_LUA, PROJECT_ROOT)}")
