"""
================================================================================
Overachiever2 - NPC Achievement Database Generator
================================================================================

OVERVIEW:
    This script processes DB2 CSV files and generates npcAchievements.lua,
    a data file used by the Overachiever2 WoW addon. The lua file maps NPC IDs
    to (achievementID, criteriaID) pairs, enabling the addon to display relevant
    achievement information in NPC tooltips.

PREREQUISITES:
    Before running this script, you must first run fetch_resources.py to download
    the required CSV files. This script expects the following files to exist in
    the "resources" directory:
        - Achievement.csv
        - CriteriaTree.csv
        - Criteria.csv
        - ModifierTree.csv

USAGE:
    python generate_npc_db.py

    Note: This script has no command-line arguments. It always processes the
    files in the resources directory and generates the output file.

DATA SOURCES (all from wago.tools, which mirrors WoW's DB2 game files):
    - Achievement.csv   : Achievement ID, name, and root CriteriaTree ID
    - CriteriaTree.csv  : Tree structure linking achievements to criteria
    - Criteria.csv      : Individual criteria with type, asset, and criteriaID
    - ModifierTree.csv  : NPC ID lookup for emote-type criteria (Type 54)

WHY FOUR FILES?
    WoW's achievement system uses a hierarchical tree structure (since WoD 6.0).
    A single achievement can have multiple criteria grouped under sub-trees.

    For NPC kill criteria (Type 0), the NPC ID is stored directly in Criteria.Asset:

    Achievement.db2
        └─ CriteriaTree (root)
                └─ CriteriaTree (sub-tree)
                        └─ Criteria (Type=0, Asset=NPC_ID)

    For emote criteria (Type 54, e.g. "To All The Squirrels I've Loved Before"),
    the emote ID is in Criteria.Asset (e.g. 225 = /love), but the TARGET NPC ID
    is stored separately in ModifierTree.db2, referenced via Criteria.Modifier_tree_ID:

    Achievement.db2
        └─ CriteriaTree (root)
                └─ CriteriaTree (sub-tree, one per animal)
                        └─ Criteria (Type=54, Asset=225=/love, Modifier_tree_ID=256)
                                └─ ModifierTree 256 (root, operator=ANY)
                                        └─ ModifierTree 257 (Type=4, Asset=NPC_ID)

    ModifierTree Type 4 = "target NPC ID". This is how WoW specifies which NPC
    the player must emote at.

WHY criteriaID AND NOT criteriaIndex?
    The WoW Lua API offers two ways to query a criteria:
        GetAchievementCriteriaInfo(achID, criteriaIndex)
        GetAchievementCriteriaInfoByID(achID, criteriaID)

    criteriaIndex is a 1-based sequential number assigned at runtime by the
    WoW client, which can change between patches. criteriaID is a stable,
    unique identifier that comes directly from the DB2 files and never changes
    for a given criteria row. Storing criteriaID allows the addon to use
    GetAchievementCriteriaInfoByID(), which is more reliable and does not
    require knowing the runtime ordering of criteria.

OUTPUT:
    Overachiever2/DBNpc.lua  - Lua table mapping NPC IDs to {achID, criteriaID, orderIndex} tuples

LUA OUTPUT FORMAT:
    ns.DB.Npc = {
        [npcID] = { {achID, criteriaID, orderIndex}, ... },
        ...
    }

    Example:
        [129877] = { {13094, 56789, 1} },               -- one achievement
        [12345]  = { {111, 222, 1}, {333, 444, 2} },    -- appears in two achievements

ADDON USAGE:
    local data = ns.DB.Npc[npcID]
    if data then
        for _, pair in ipairs(data) do
            local achID, criteriaID, orderIndex = pair[1], pair[2], pair[3]
            local name, _, completed = GetAchievementCriteriaInfoByID(achID, criteriaID)
            -- or use: local name = GetAchievementCriteriaInfo(achID, orderIndex) for localized name
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

# Automatically detect project root directory (parent of Scripts directory)
# This allows the script to be run from any directory
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)  # Go up one level from Scripts/

# ── Configuration ─────────────────────────────────────────────────────────────

# Directory where downloaded resources are stored
RESOURCES_DIR = os.path.join(PROJECT_ROOT, "Scripts", "resources")

# Output lua file consumed by the Overachiever2 addon
OUTPUT_LUA = os.path.join(PROJECT_ROOT, "Overachiever2", "DBNpc.lua")

# Required CSV files that must exist in the resources directory
REQUIRED_FILES = [
    "Achievement.csv",
    "Criteria.csv",
    "CriteriaTree.csv",
    "ModifierTree.csv",
]


# ── Input Validation ──────────────────────────────────────────────────────────

def check_required_files():
    """
    Verifies that all required CSV files exist in the resources directory.

    If any file is missing, prints an error message and exits the program.

    Returns:
        None: If all files exist, the function returns normally.
              If any file is missing, the program exits with code 1.
    """
    missing_files = []
    for filename in REQUIRED_FILES:
        filepath = os.path.join(RESOURCES_DIR, filename)
        if not os.path.exists(filepath):
            missing_files.append(filename)

    if missing_files:
        print("❌ Error: Required resource files are missing:")
        for filename in missing_files:
            print(f"   - {os.path.join(RESOURCES_DIR, filename)}")
        print("\n💡 Please run 'python fetch_resources.py' first to download the required files.")
        sys.exit(1)


# ── Lua Generation ────────────────────────────────────────────────────────────

def generate_lua():
    """
    Parses the CSV files from the resources directory and writes npcAchievements.lua.

    The generation process has four steps:

    Step 1 - Achievement.csv:
        Build a dict mapping CriteriaTree root node IDs to Achievement IDs.
        Each achievement row contains a "Criteria_tree" field that points to
        the root node of its criteria tree.
            ach_by_tree[criteriaTreeID] = achievementID

    Step 2 - CriteriaTree.csv:
        Build two dicts from the tree structure:
        - tree_parent[treeID] = parentID
            Used to walk up the tree from any node to the root.
        - criteria_to_trees[criteriaID] = [treeID, ...]
            Maps each Criteria row back to its CriteriaTree node(s).
            A criteriaID can appear in multiple tree nodes (rare but possible).

    Step 2.5 - ModifierTree.csv:
        For emote criteria (Type 54), the target NPC ID is NOT in Criteria.Asset
        (that holds the emote ID). Instead, Criteria.Modifier_tree_ID points to
        a ModifierTree root node, whose children (Type=4) contain the NPC IDs.
        Build a dict: modifier_tree_id -> [npc_id, ...]

    Step 3 - Criteria.csv:
        Find all rows where Type == "0" (NPC kill) OR Type == "54" (emote at NPC).
        For Type 0:  NPC ID is in Criteria.Asset directly.
        For Type 54: NPC ID(s) are looked up via modifier_tree_npc_ids using
                     Criteria.Modifier_tree_ID.
        For each NPC ID found, walk up the CriteriaTree to find the Achievement ID.
        Store (achID, criteriaID) tuples so the addon can call
        GetAchievementCriteriaInfoByID(achID, criteriaID) directly.

    Step 4 - Output:
        Write Overachiever2/DBNpc.lua with the final mapping, sorted numerically
        by NPC ID. Each entry contains one or more {achID, criteriaID, orderIndex} tuples.

    Returns:
        int: Number of unique NPC IDs that were mapped to at least one achievement.
    """
    print("\n--- Generating lua ---")

    # ── Step 1: Load Achievement → CriteriaTree root mapping ──────────────────
    print("1. Reading Achievement.csv...")
    # ach_by_tree maps a CriteriaTree root node ID to its Achievement ID.
    # This is the anchor point for the upward tree traversal in Step 3.
    ach_by_tree = {}
    with open(os.path.join(RESOURCES_DIR, "Achievement.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            # Skip achievements that share criteria with another achievement.
            # These are duplicates (e.g. Alliance/Horde variants, or tiered achievements
            # like "Medium Rare" vs "Bloody Rare") that reference identical criteriaIDs.
            # Processing them would create duplicate NPC→achievement mappings.
            if row.get("Shares_criteria", "0") != "0":
                continue
            tree_id = row.get("Criteria_tree", "0")
            if tree_id and tree_id != "0":
                ach_by_tree[tree_id] = row["ID"]
    print(f"   → {len(ach_by_tree)} tree mappings loaded")

    # ── Step 2: Load CriteriaTree parent/child relationships ──────────────────
    print("2. Reading CriteriaTree.csv...")
    # tree_parent allows upward traversal: given a tree node, find its parent.
    tree_parent = {}
    # tree_order stores OrderIndex of each node.
    # The parent node's OrderIndex + 1 = criteriaIndex for GetAchievementCriteriaInfo().
    tree_order = {}
    # criteria_to_trees maps a Criteria ID to the CriteriaTree node(s) that
    # reference it. This bridges Step 2 and Step 3.
    criteria_to_trees = {}
    with open(os.path.join(RESOURCES_DIR, "CriteriaTree.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            tree_id = row["ID"]
            tree_parent[tree_id] = row.get("Parent", "0")
            tree_order[tree_id]  = int(row.get("OrderIndex", "0") or "0")
            cid = row.get("CriteriaID", "0")
            if cid and cid != "0":
                if cid not in criteria_to_trees:
                    criteria_to_trees[cid] = []
                criteria_to_trees[cid].append(tree_id)
    print(f"   → {len(tree_parent)} tree nodes loaded")

    def find_achievement_id(tree_id, depth=0):
        """
        Recursively walks up the CriteriaTree until the root node is found,
        then returns the Achievement ID associated with that root.

        WoW's criteria trees can be deeply nested (e.g. achievement → category
        sub-tree → individual criteria), so we must traverse upward step by
        step rather than jumping directly to the root.

        Args:
            tree_id (str): The CriteriaTree node ID to start from.
            depth (int):   Current recursion depth, used as a safety limit.

        Returns:
            str:  Achievement ID if the root was found.
            None: If the root was not found within 15 levels (safety limit),
                  or if the node has no parent (orphaned node).
        """
        # Safety limit to prevent infinite loops from malformed tree data
        if depth > 15:
            return None
        # Base case: this node IS the root (it's directly referenced by an achievement)
        if tree_id in ach_by_tree:
            return ach_by_tree[tree_id]
        # Recursive case: walk up to the parent node
        parent = tree_parent.get(tree_id, "0")
        if parent and parent != "0":
            return find_achievement_id(parent, depth + 1)
        return None

    # ── Step 2.5: Load ModifierTree → NPC ID mappings (for emote criteria) ──────
    print("2.5. Reading ModifierTree.csv...")
    # For Type 54 (emote) criteria, the target NPC ID is not in Criteria.Asset.
    # Instead, Criteria.Modifier_tree_ID points to a ModifierTree root node.
    # The root's children with Type=4 contain the actual NPC IDs.
    #
    # Structure:
    #   Criteria.Modifier_tree_ID → ModifierTree root (operator=ANY)
    #       └─ ModifierTree child (Type=4, Asset=NPC_ID)
    #
    # modifier_tree_npc_ids maps a root ModifierTree ID to its NPC ID(s).
    # Most have exactly one child (one NPC), but we handle multiple just in case.

    # First pass: collect all parent→children relationships and node details
    mt_parent = {}   # child_id -> parent_id
    mt_nodes  = {}   # node_id  -> (type, asset)
    with open(os.path.join(RESOURCES_DIR, "ModifierTree.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            node_id = row["ID"]
            parent  = row.get("Parent", "0")
            mt_parent[node_id] = parent
            mt_nodes[node_id]  = (row.get("Type", "0"), row.get("Asset", "0"))

    # Second pass: for each node with Type=4 (NPC target), walk up to root
    # and register the NPC ID under that root's ID.
    modifier_tree_npc_ids = {}  # root_modifier_tree_id -> [npc_id, ...]
    for node_id, (node_type, asset) in mt_nodes.items():
        if node_type != "4" or not asset or asset == "0":
            continue
        # Walk up to find the root (node with Parent=0)
        cur = node_id
        for _ in range(10):
            parent = mt_parent.get(cur, "0")
            if parent == "0":
                # cur is the root
                if cur not in modifier_tree_npc_ids:
                    modifier_tree_npc_ids[cur] = []
                modifier_tree_npc_ids[cur].append(asset)
                break
            cur = parent
    print(f"   → {len(modifier_tree_npc_ids)} modifier trees with NPC targets loaded")

    # ── Step 3: Find all NPC criteria and map them to achievements ────────────
    print("3. Reading Criteria.csv...")
    # Final output dict: npc_id (str) → set of (achID, criteriaID, orderIndex) tuples.
    npc_to_achievements = {}
    with open(os.path.join(RESOURCES_DIR, "Criteria.csv"), encoding="utf-8") as f:
        for row in csv.DictReader(f):
            crit_type   = row.get("Type")
            criteria_id = row["ID"]

            if crit_type == "0":
                # ── Type 0: NPC kill — NPC ID is directly in Asset ──────────
                npc_ids = [row.get("Asset", "0")]

            elif crit_type == "54":
                # ── Type 54: Emote at NPC — NPC ID is in ModifierTree ────────
                # Asset holds the emote ID (e.g. 225 = /love), not the NPC ID.
                # Modifier_tree_ID points to a ModifierTree root whose Type=4
                # children contain the actual target NPC IDs.
                mod_tree_id = row.get("Modifier_tree_ID", "0")
                if not mod_tree_id or mod_tree_id == "0":
                    continue
                npc_ids = modifier_tree_npc_ids.get(mod_tree_id, [])

            else:
                continue

            for npc_id in npc_ids:
                if not npc_id or npc_id == "0":
                    continue
                for tree_id in criteria_to_trees.get(criteria_id, []):
                    ach_id = find_achievement_id(tree_id)
                    if ach_id:
                        # tree_id is the leaf CriteriaTree node (CriteriaID=criteriaID).
                        # Its parent node holds the localized criteria name and OrderIndex.
                        # OrderIndex + 1 = criteriaIndex for GetAchievementCriteriaInfo(achID, criteriaIndex)
                        # which returns the localized name (e.g. "토끼") at runtime.
                        parent_id    = tree_parent.get(tree_id, "0")
                        order_index  = tree_order.get(parent_id, 0) + 1 if parent_id != "0" else 1
                        if npc_id not in npc_to_achievements:
                            npc_to_achievements[npc_id] = set()
                        npc_to_achievements[npc_id].add((ach_id, criteria_id, order_index))
    print(f"   → {len(npc_to_achievements)} NPC-achievement mappings found!")

    # ── Step 4: Write the lua file ─────────────────────────────────────────────
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
            # Sort by all three values (achID, criteriaID, orderIndex) for deterministic output
            entries = ", ".join(
                f"{{{ach_id}, {crit_id}, {order_idx}}}"
                for ach_id, crit_id, order_idx in sorted(pairs, key=lambda x: (int(x[0]), int(x[1]), int(x[2])))
            )
            f.write(f"    [{npc_id}] = {{ {entries} }},\n")
        f.write("}\n")

    return len(npc_to_achievements)


# ── Main ──────────────────────────────────────────────────────────────────────

print("=== Overachiever2 NPC Database Generator ===\n")

# Verify that all required CSV files exist
check_required_files()

# Generate the lua file from the downloaded resources
count = generate_lua()

print(f"\n✅ Done! {count} NPC mappings written to {os.path.relpath(OUTPUT_LUA, PROJECT_ROOT)}")
