"""
================================================================================
Overachiever2 - Meta Achievement Database Generator
================================================================================

OVERVIEW:
    This script processes DB2 CSV files and generates DBMeta.lua,
    a data file used by the Overachiever2 WoW addon. The lua file maps
    child achievement IDs to their parent (meta) achievement IDs, enabling
    the addon to display "This achievement is part of [meta achievement]"
    in achievement tooltips.

PREREQUISITES:
    Before running this script, you must first run fetch_resources.py to
    download the required CSV files. This script expects the following files
    to exist in the "resources" directory:
        - Achievement.csv
        - CriteriaTree.csv
        - Criteria.csv

USAGE:
    python generate_meta_db.py

HOW IT WORKS:
    Meta achievements use Type 8 criteria, where Asset = child achievement ID.

    Achievement.db2 (meta)
        └─ CriteriaTree (root)
                └─ CriteriaTree (leaf)
                        └─ Criteria (Type=8, Asset=child_achievement_ID)

    This script:
    1. Builds a CriteriaTree lookup (criteriaID → root tree node)
    2. Finds all Criteria rows with Type=8 (achievement completion)
    3. Resolves each to its parent achievement ID via CriteriaTree traversal
    4. Outputs child → [parentID, ...] mapping

OUTPUT:
    Overachiever2/DBMeta.lua

LUA OUTPUT FORMAT:
    ns.DB.Meta = {
        [childAchID] = { parentAchID1, parentAchID2, ... },
        ...
    }

    Example:
        [40244] = { 61451 },   -- Nerub-ar Palace → Worldsoul-Searching
        [41222] = { 61451 },

ADDON USAGE:
    local parents = ns.DB.Meta[achID]
    if parents then
        for _, parentID in ipairs(parents) do
            local _, name = GetAchievementInfo(parentID)
            -- display "Part of: <name>"
        end
    end

MAINTENANCE:
    Run fetch_resources.py after each WoW patch to download fresh CSV files,
    then run this script to regenerate the lua file.
================================================================================
"""

import csv
import os
import sys

# ── Path Detection ────────────────────────────────────────────────────────────

SCRIPT_DIR   = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)

# ── Configuration ─────────────────────────────────────────────────────────────

RESOURCES_DIR = os.path.join(PROJECT_ROOT, "Scripts", "resources")
OUTPUT_LUA    = os.path.join(PROJECT_ROOT, "Overachiever2", "DBMeta.lua")

REQUIRED_FILES = [
    "Achievement.csv",
    "Criteria.csv",
    "CriteriaTree.csv",
]


# ── Input Validation ──────────────────────────────────────────────────────────

def check_required_files():
    missing = []
    for filename in REQUIRED_FILES:
        if not os.path.exists(os.path.join(RESOURCES_DIR, filename)):
            missing.append(filename)
    if missing:
        print("❌ Error: Required resource files are missing:")
        for f in missing:
            print(f"   - {os.path.join(RESOURCES_DIR, f)}")
        print("\n💡 Please run 'python fetch_resources.py' first.")
        sys.exit(1)


# ── Lua Generation ────────────────────────────────────────────────────────────

def generate_lua():
    print("\n--- Generating lua ---")

    # ── Step 1: Load Achievement → CriteriaTree root mapping ──────────────────
    print("1. Reading Achievement.csv...")
    # ach_by_tree[treeID] = achID
    # Shares_criteria achievements are skipped (same as generate_npc_db.py)
    ach_by_tree = {}
    with open(os.path.join(RESOURCES_DIR, "Achievement.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row.get("Shares_criteria", "0") != "0":
                continue
            tree_id = row.get("Criteria_tree", "0")
            if tree_id and tree_id != "0":
                ach_by_tree[tree_id] = row["ID"]
    print(f"   → {len(ach_by_tree)} tree mappings loaded")

    # ── Step 2: Load CriteriaTree parent relationships ────────────────────────
    print("2. Reading CriteriaTree.csv...")
    # tree_parent[treeID] = parentID  — for upward traversal to root
    # criteria_to_trees[criteriaID] = [treeID, ...]
    tree_parent      = {}
    criteria_to_trees = {}
    with open(os.path.join(RESOURCES_DIR, "CriteriaTree.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            tree_id = row["ID"]
            tree_parent[tree_id] = row.get("Parent", "0")
            cid = row.get("CriteriaID", "0")
            if cid and cid != "0":
                criteria_to_trees.setdefault(cid, []).append(tree_id)
    print(f"   → {len(tree_parent)} tree nodes loaded")

    def find_achievement_id(tree_id, depth=0):
        if depth > 15:
            return None
        if tree_id in ach_by_tree:
            return ach_by_tree[tree_id]
        parent = tree_parent.get(tree_id, "0")
        if parent and parent != "0":
            return find_achievement_id(parent, depth + 1)
        return None

    # ── Step 3: Find all Type 8 criteria (achievement completion) ─────────────
    print("3. Reading Criteria.csv...")
    # child_to_parents[childAchID] = set of parentAchIDs
    child_to_parents = {}
    with open(os.path.join(RESOURCES_DIR, "Criteria.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row.get("Type") != "8":
                continue
            child_ach_id = row.get("Asset", "0")
            if not child_ach_id or child_ach_id == "0":
                continue
            criteria_id = row["ID"]
            for tree_id in criteria_to_trees.get(criteria_id, []):
                parent_ach_id = find_achievement_id(tree_id)
                if parent_ach_id:
                    child_to_parents.setdefault(child_ach_id, set()).add(parent_ach_id)

    print(f"   → {len(child_to_parents)} child→parent mappings found")

    # ── Step 4: Write the lua file ─────────────────────────────────────────────
    print(f"4. Writing {os.path.relpath(OUTPUT_LUA, PROJECT_ROOT)}...")
    with open(OUTPUT_LUA, "w", encoding="utf-8") as f:
        f.write("-- Overachiever2: Prebuilt Database\n")
        f.write("-- Auto-generated lookup table for child → meta achievement mappings\n")
        f.write("-- Do not edit manually.\n")
        f.write("-- Format: [childAchID] = { parentAchID, ... }\n\n")
        f.write("local _, ns = ...\n\n")
        f.write("ns.DB = ns.DB or {}\n\n")
        f.write("-- Child achievement ID -> { parent (meta) achievement IDs }\n")
        f.write("ns.DB.Meta = {\n")
        for child_id, parents in sorted(child_to_parents.items(), key=lambda x: int(x[0])):
            entries = ", ".join(str(p) for p in sorted(parents, key=int))
            f.write(f"    [{child_id}] = {{ {entries} }},\n")
        f.write("}\n")

    return len(child_to_parents)


# ── Main ──────────────────────────────────────────────────────────────────────

print("=== Overachiever2 Meta Achievement Database Generator ===\n")

check_required_files()

count = generate_lua()

print(f"\n✅ Done! {count} child→parent mappings written to {os.path.relpath(OUTPUT_LUA, PROJECT_ROOT)}")
