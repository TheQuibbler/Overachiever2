#!/usr/bin/env python3
"""
Parse AllTheThings database files to extract NPC -> Achievement/Criteria mappings.

Input:  resources/AllTheThings/db/Standard/Categories/*.lua
Output: resources/intermediate/npc_list.txt (intermediate format for merging)

Scans for crit() calls and extracts NPC associations from these sources:
  1. Hierarchy nesting: crit() inside n(npcID, {g={...}})
  2. crs={npcID, ...} or crs=a[N] on crit() or enclosing ach()
  3. qgs={npcID, ...} or qgs=a[N] on crit() or enclosing ach()
  4. providers={{"n", npcID}} or providers={a[N]} where a[N] = {"n", npcID}
  5. npcID= on any enclosing function call (e.g. e(encounterID, {npcID=...}))
"""

import os
import glob
from collections import defaultdict

# ============================================================================
# Step 1: Tokenizer
# ============================================================================

TOK_IDENT = 'IDENT'
TOK_NUMBER = 'NUMBER'
TOK_STRING = 'STRING'
TOK_LPAREN = '('
TOK_RPAREN = ')'
TOK_LBRACE = '{'
TOK_RBRACE = '}'
TOK_COMMA = ','
TOK_EQUALS = '='
TOK_DOT = '.'
TOK_LBRACKET = '['
TOK_RBRACKET = ']'
TOK_OTHER = 'OTHER'

def tokenize(content):
    """Tokenize Lua source into a list of (type, value) tuples."""
    tokens = []
    i = 0
    length = len(content)

    while i < length:
        c = content[i]

        if c in ' \t\r\n':
            i += 1
            continue

        # Comments
        if c == '-' and i + 1 < length and content[i + 1] == '-':
            if i + 3 < length and content[i + 2] == '[' and content[i + 3] == '[':
                end = content.find(']]', i + 4)
                i = (end + 2) if end != -1 else length
            else:
                end = content.find('\n', i + 2)
                i = (end + 1) if end != -1 else length
            continue

        # Strings
        if c == '"' or c == "'":
            quote = c
            j = i + 1
            while j < length:
                if content[j] == '\\':
                    j += 2
                elif content[j] == quote:
                    j += 1
                    break
                else:
                    j += 1
            tokens.append((TOK_STRING, content[i + 1:j - 1]))
            i = j
            continue

        if c == '[' and i + 1 < length and content[i + 1] == '[':
            end = content.find(']]', i + 2)
            if end == -1:
                break
            tokens.append((TOK_STRING, content[i + 2:end]))
            i = end + 2
            continue

        # Numbers
        if c.isdigit() or (c == '.' and i + 1 < length and content[i + 1].isdigit()):
            j = i
            while j < length and (content[j].isdigit() or content[j] == '.'):
                j += 1
            if j < length and content[j] in 'xX' and content[i] == '0':
                j += 1
                while j < length and content[j] in '0123456789abcdefABCDEF':
                    j += 1
            tokens.append((TOK_NUMBER, content[i:j]))
            i = j
            continue

        # Identifiers
        if c.isalpha() or c == '_':
            j = i + 1
            while j < length and (content[j].isalnum() or content[j] == '_'):
                j += 1
            tokens.append((TOK_IDENT, content[i:j]))
            i = j
            continue

        # Punctuation
        if c == '(':
            tokens.append((TOK_LPAREN, c))
        elif c == ')':
            tokens.append((TOK_RPAREN, c))
        elif c == '{':
            tokens.append((TOK_LBRACE, c))
        elif c == '}':
            tokens.append((TOK_RBRACE, c))
        elif c == ',':
            tokens.append((TOK_COMMA, c))
        elif c == '=':
            if i + 1 < length and content[i + 1] == '=':
                tokens.append((TOK_OTHER, '=='))
                i += 2
                continue
            tokens.append((TOK_EQUALS, c))
        elif c == '.':
            if i + 1 < length and content[i + 1] == '.':
                tokens.append((TOK_OTHER, '..'))
                i += 2
                continue
            tokens.append((TOK_DOT, c))
        elif c == '[':
            tokens.append((TOK_LBRACKET, c))
        elif c == ']':
            tokens.append((TOK_RBRACKET, c))
        else:
            if c not in '\xef\xbb\xbf;':
                tokens.append((TOK_OTHER, c))
        i += 1

    return tokens


# ============================================================================
# Step 2: Parse the `local a={...}` array
# ============================================================================

def parse_local_array(tokens):
    """
    Find `local a = { ... }` and parse each top-level element.
    Returns two dicts:
      npc_providers: index -> npc_id  (for {"n", npcID} entries)
      num_lists: index -> [int, ...]  (for plain number arrays like {14480, 14481, 18913})
    """
    # Find: IDENT(local) IDENT(a) = {
    npc_providers = {}
    num_lists = {}
    i = 0
    length = len(tokens)

    while i < length - 3:
        if (tokens[i] == (TOK_IDENT, 'local') and
            tokens[i + 1] == (TOK_IDENT, 'a') and
            tokens[i + 2][0] == TOK_EQUALS and
            tokens[i + 3][0] == TOK_LBRACE):
            break
        i += 1
    else:
        return npc_providers, num_lists  # not found

    # Now parse the array elements at depth 1
    i += 4  # skip past local a = {
    depth = 1
    element_index = 1
    elem_start = i

    while i < length and depth > 0:
        if tokens[i][0] == TOK_LBRACE:
            depth += 1
            if depth == 2:
                # Starting a sub-table element. Collect all tokens until matching }.
                sub_start = i + 1
                sub_depth = 1
                j = i + 1
                while j < length and sub_depth > 0:
                    if tokens[j][0] == TOK_LBRACE:
                        sub_depth += 1
                    elif tokens[j][0] == TOK_RBRACE:
                        sub_depth -= 1
                    j += 1
                sub_end = j - 1  # index of closing }
                sub_tokens = tokens[sub_start:sub_end]

                # Check pattern 1: {"n", NUMBER, ...} -> NPC provider
                if (len(sub_tokens) >= 3 and
                    sub_tokens[0][0] == TOK_STRING and sub_tokens[0][1] == 'n' and
                    sub_tokens[1][0] == TOK_COMMA and
                    sub_tokens[2][0] == TOK_NUMBER):
                    try:
                        npc_id = int(sub_tokens[2][1])
                        npc_providers[element_index] = npc_id
                    except ValueError:
                        pass
                # Check pattern 2: {NUMBER, NUMBER, ...} -> plain number array
                elif sub_tokens and sub_tokens[0][0] == TOK_NUMBER:
                    nums = []
                    all_nums = True
                    for st in sub_tokens:
                        if st[0] == TOK_NUMBER:
                            try:
                                nums.append(int(st[1]))
                            except ValueError:
                                all_nums = False
                                break
                        elif st[0] == TOK_COMMA:
                            continue
                        else:
                            all_nums = False
                            break
                    if all_nums and nums:
                        num_lists[element_index] = nums

                i = j  # advance past the closing }
                depth = 1  # we're back at depth 1
            else:
                i += 1
        elif tokens[i][0] == TOK_RBRACE:
            depth -= 1
            if depth == 0:
                break
            i += 1
        elif tokens[i][0] == TOK_COMMA and depth == 1:
            # End of element
            element_index += 1
            i += 1
            elem_start = i
        else:
            i += 1

    return npc_providers, num_lists


# ============================================================================
# Step 3: Parser - Extract NPC -> Achievement/Criteria mappings
# ============================================================================

def parse_tokens(tokens, array_npcs, array_num_lists):
    """
    Walk through tokens, tracking context stack of enclosing function calls.
    Extract NPC -> {achievementID, criteriaID} mappings.

    Tracks ALL function calls with numeric first args. For crit()/ach()/gach()
    does special processing. For any other call (e.g. e(), d(), p(), inst()),
    scans the table arg for npcID= to establish NPC context (like n() does).

    array_npcs: dict of array index -> npc_id from the local a={} array
    array_num_lists: dict of array index -> [int, ...] for plain number arrays
    """
    npc_map = defaultdict(set)

    pos = 0
    length = len(tokens)
    context_stack = []
    paren_depth = 0

    # Functions that get special handling
    SPECIAL_FUNCS = {'ach', 'crit', 'gach'}

    while pos < length:
        tok_type, tok_val = tokens[pos]

        if tok_type == TOK_LPAREN:
            paren_depth += 1
            pos += 1
            continue
        elif tok_type == TOK_RPAREN:
            paren_depth -= 1
            while context_stack and context_stack[-1]['depth'] > paren_depth:
                context_stack.pop()
            pos += 1
            continue

        # Detect function calls: IDENT ( NUMBER , ...
        if tok_type == TOK_IDENT:
            if pos + 1 < length and tokens[pos + 1][0] == TOK_LPAREN:
                func_name = tok_val
                pos += 2
                paren_depth += 1

                first_arg = None
                if pos < length and tokens[pos][0] == TOK_NUMBER:
                    try:
                        first_arg = int(tokens[pos][1])
                    except ValueError:
                        try:
                            first_arg = int(float(tokens[pos][1]))
                        except ValueError:
                            pass
                    pos += 1
                    if pos < length and tokens[pos][0] == TOK_COMMA:
                        pos += 1

                ctx = {
                    'type': func_name,
                    'id': first_arg,
                    'depth': paren_depth,
                    'crs': None,
                    'achID': None,
                    'npcID': None,  # npcID from table arg (e.g. e(473, {npcID=2748}))
                }
                context_stack.append(ctx)

                if func_name == 'crit' and first_arg is not None:
                    achID, npc_ids = scan_crit_table(tokens, pos, array_npcs, array_num_lists)
                    ctx['achID'] = achID

                    if achID is not None:
                        criteria_id = first_arg

                        # Source 1: NPCs from crs={} or providers={{"n",...}} on the crit
                        if npc_ids:
                            for npc_id in npc_ids:
                                if npc_id > 0:
                                    npc_map[npc_id].add((achID, criteria_id))

                        # Source 2: enclosing call with NPC context (n() or any call with npcID=)
                        # Stop at ach()/gach() boundaries — NPC context should not
                        # leak through achievements (avoids meta-achievement false positives)
                        for entry in reversed(context_stack[:-1]):
                            if entry['type'] in ('ach', 'gach'):
                                break  # don't cross achievement boundaries
                            npc_id = None
                            if entry['type'] == 'n' and entry['id'] is not None and entry['id'] > 0:
                                npc_id = entry['id']
                            elif entry.get('npcID') and entry['npcID'] > 0:
                                npc_id = entry['npcID']
                            if npc_id:
                                npc_map[npc_id].add((achID, criteria_id))
                                break

                        # Source 3: enclosing ach() with crs
                        for entry in reversed(context_stack[:-1]):
                            if entry['type'] in ('ach', 'gach') and entry['crs']:
                                for npc_id in entry['crs']:
                                    if npc_id > 0:
                                        npc_map[npc_id].add((achID, criteria_id))
                                break

                elif func_name in ('ach', 'gach') and first_arg is not None:
                    crs_list = scan_ach_crs(tokens, pos, array_npcs, array_num_lists)
                    ctx['crs'] = crs_list
                    ctx['achID'] = first_arg

                elif func_name not in SPECIAL_FUNCS and first_arg is not None:
                    # For any other function (e, d, p, inst, etc.),
                    # scan table arg for npcID= to establish NPC context
                    npcID = scan_table_npcID(tokens, pos)
                    if npcID:
                        ctx['npcID'] = npcID

                continue
            else:
                pos += 1
                continue
        else:
            pos += 1
            continue

    return npc_map


def scan_table_npcID(tokens, pos):
    """
    Starting at pos (expecting { ... }), scan the top-level table for npcID=NUMBER.
    Returns the NPC ID or None.
    """
    length = len(tokens)
    if pos >= length or tokens[pos][0] != TOK_LBRACE:
        return None

    depth = 1
    i = pos + 1
    while i < length and depth > 0:
        if tokens[i][0] == TOK_LBRACE:
            depth += 1
            i += 1
        elif tokens[i][0] == TOK_RBRACE:
            depth -= 1
            i += 1
        elif depth == 1 and tokens[i][0] == TOK_IDENT and tokens[i][1] == 'npcID':
            if i + 2 < length and tokens[i + 1][0] == TOK_EQUALS and tokens[i + 2][0] == TOK_NUMBER:
                try:
                    return int(tokens[i + 2][1])
                except ValueError:
                    pass
                i += 3
            else:
                i += 1
        elif depth == 1 and tokens[i][0] == TOK_IDENT and tokens[i][1] == 'g':
            # Skip g={...} to avoid descending
            if i + 2 < length and tokens[i + 1][0] == TOK_EQUALS and tokens[i + 2][0] == TOK_LBRACE:
                g_depth = 1
                j = i + 3
                while j < length and g_depth > 0:
                    if tokens[j][0] == TOK_LBRACE:
                        g_depth += 1
                    elif tokens[j][0] == TOK_RBRACE:
                        g_depth -= 1
                    j += 1
                i = j
            else:
                i += 1
        else:
            i += 1

    return None


def _scan_npc_list_field(tokens, i, length, array_npcs, array_num_lists):
    """
    Parse a field like crs={...} or qgs={...} or crs=a[N] or qgs=a[N].
    Expects i to point at the field name (crs/qgs). Returns (npc_ids, new_i).
    """
    npc_ids = []
    if i + 2 < length and tokens[i + 1][0] == TOK_EQUALS:
        if tokens[i + 2][0] == TOK_LBRACE:
            # field={num, num, ...}
            j = i + 3
            while j < length and tokens[j][0] != TOK_RBRACE:
                if tokens[j][0] == TOK_NUMBER:
                    try:
                        npc_ids.append(int(tokens[j][1]))
                    except ValueError:
                        pass
                j += 1
            return npc_ids, j + 1
        elif (tokens[i + 2][0] == TOK_IDENT and tokens[i + 2][1] == 'a' and
              i + 5 < length and tokens[i + 3][0] == TOK_LBRACKET and
              tokens[i + 4][0] == TOK_NUMBER and tokens[i + 5][0] == TOK_RBRACKET):
            # field=a[N] - resolve from array
            try:
                idx = int(tokens[i + 4][1])
                if idx in array_num_lists:
                    npc_ids.extend(array_num_lists[idx])
                elif idx in array_npcs:
                    npc_ids.append(array_npcs[idx])
            except ValueError:
                pass
            return npc_ids, i + 6
    return npc_ids, i + 1


def scan_crit_table(tokens, pos, array_npcs, array_num_lists):
    """
    Starting after `crit(ID,` at position pos, scan the table argument
    to extract achID and NPC IDs from crs={}, qgs={}, and providers={}.
    Returns (achID, npc_ids_list).
    """
    length = len(tokens)
    achID = None
    npc_ids = []

    if pos >= length or tokens[pos][0] != TOK_LBRACE:
        return achID, npc_ids

    depth = 1
    i = pos + 1
    while i < length and depth > 0:
        if tokens[i][0] == TOK_LBRACE:
            depth += 1
            i += 1
        elif tokens[i][0] == TOK_RBRACE:
            depth -= 1
            i += 1
        elif depth == 1 and tokens[i][0] == TOK_IDENT and tokens[i][1] == 'achID':
            if i + 2 < length and tokens[i + 1][0] == TOK_EQUALS and tokens[i + 2][0] == TOK_NUMBER:
                try:
                    achID = int(tokens[i + 2][1])
                except ValueError:
                    pass
                i += 3
            else:
                i += 1
        elif depth == 1 and tokens[i][0] == TOK_IDENT and tokens[i][1] in ('crs', 'qgs'):
            ids, i = _scan_npc_list_field(tokens, i, length, array_npcs, array_num_lists)
            npc_ids.extend(ids)
        elif depth == 1 and tokens[i][0] == TOK_IDENT and tokens[i][1] == 'providers':
            # providers={{"n", NPC_ID}, ...} or providers={a[N], ...}
            npcs = scan_providers(tokens, i + 1, array_npcs)
            npc_ids.extend(npcs)
            # Just advance past 'providers'
            i += 1
        else:
            i += 1

    return achID, npc_ids if npc_ids else None


def scan_providers(tokens, pos, array_npcs):
    """
    Starting at position pos (expecting = { ... }), extract NPC IDs from providers.
    Handles:
      providers={{"n", 12345}, {"i", 99999}}  -> extracts 12345
      providers={a[40], a[41]}                 -> looks up array_npcs[40], [41]
    Returns list of NPC IDs.
    """
    length = len(tokens)
    npc_ids = []

    if pos >= length or tokens[pos][0] != TOK_EQUALS:
        return npc_ids
    pos += 1

    if pos >= length or tokens[pos][0] != TOK_LBRACE:
        return npc_ids
    pos += 1

    # Scan elements inside providers={...}
    depth = 1
    i = pos
    while i < length and depth > 0:
        if tokens[i][0] == TOK_RBRACE:
            depth -= 1
            i += 1
        elif tokens[i][0] == TOK_LBRACE:
            depth += 1
            if depth == 2:
                # Inline provider entry: {"n", 12345}
                # Check for STRING("n"), COMMA, NUMBER
                j = i + 1
                if (j + 2 < length and
                    tokens[j][0] == TOK_STRING and tokens[j][1] == 'n' and
                    tokens[j + 1][0] == TOK_COMMA and
                    tokens[j + 2][0] == TOK_NUMBER):
                    try:
                        npc_ids.append(int(tokens[j + 2][1]))
                    except ValueError:
                        pass
                # Skip to closing }
                while i < length:
                    if tokens[i][0] == TOK_RBRACE:
                        depth -= 1
                        i += 1
                        break
                    elif tokens[i][0] == TOK_LBRACE:
                        depth += 1
                        i += 1
                    else:
                        i += 1
            else:
                i += 1
        elif depth == 1 and tokens[i][0] == TOK_IDENT and tokens[i][1] == 'a':
            # Array reference: a[N]
            if (i + 3 < length and tokens[i + 1][0] == TOK_LBRACKET and
                tokens[i + 2][0] == TOK_NUMBER and tokens[i + 3][0] == TOK_RBRACKET):
                try:
                    idx = int(tokens[i + 2][1])
                    if idx in array_npcs:
                        npc_ids.append(array_npcs[idx])
                except ValueError:
                    pass
                i += 4
            else:
                i += 1
        else:
            i += 1

    return npc_ids


def scan_ach_crs(tokens, pos, array_npcs, array_num_lists):
    """
    Starting after `ach(ID,` at position pos, scan for crs={...} and qgs={...}
    in the achievement's top-level table argument. Returns list of NPC IDs or None.
    """
    length = len(tokens)
    npc_ids = []

    if pos >= length or tokens[pos][0] != TOK_LBRACE:
        return None

    depth = 1
    i = pos + 1
    while i < length and depth > 0:
        if tokens[i][0] == TOK_LBRACE:
            depth += 1
            i += 1
        elif tokens[i][0] == TOK_RBRACE:
            depth -= 1
            i += 1
        elif depth == 1 and tokens[i][0] == TOK_IDENT and tokens[i][1] in ('crs', 'qgs'):
            ids, i = _scan_npc_list_field(tokens, i, length, array_npcs, array_num_lists)
            npc_ids.extend(ids)
        elif depth == 1 and tokens[i][0] == TOK_IDENT and tokens[i][1] == 'g':
            # Skip past g={...}
            if i + 2 < length and tokens[i + 1][0] == TOK_EQUALS and tokens[i + 2][0] == TOK_LBRACE:
                g_depth = 1
                j = i + 3
                while j < length and g_depth > 0:
                    if tokens[j][0] == TOK_LBRACE:
                        g_depth += 1
                    elif tokens[j][0] == TOK_RBRACE:
                        g_depth -= 1
                    j += 1
                i = j
            else:
                i += 1
        else:
            i += 1

    return npc_ids if npc_ids else None


# ============================================================================
# Step 4: Output generation
# ============================================================================

def write_output(npc_map, output_path):
    """Write the NPC -> achievement/criteria mapping as an intermediate file."""
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('-- Auto-generated NPC -> Achievement/Criteria mapping\n')
        f.write('-- Parsed from AllTheThings db/Standard/Categories/*.lua\n')
        f.write('--\n')
        f.write('-- This is an INTERMEDIATE format intended to be parsed and merged by another script.\n')
        f.write('-- It is NOT valid Lua.\n')
        f.write('--\n')
        f.write('-- Format: npcID = { achievementID, criteriaID }, { achievementID, criteriaID }, ...\n')
        f.write('-- Each line maps one NPC to one or more achievement/criteria pairs.\n')
        f.write('\n')

        for npc_id in sorted(npc_map.keys()):
            entries = sorted(npc_map[npc_id])
            pairs = ', '.join(f'{{ {ach_id}, {crit_id} }}' for ach_id, crit_id in entries)
            f.write(f'{npc_id} = {pairs}\n')


# ============================================================================
# Main
# ============================================================================

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    db_dir = os.path.join(script_dir, 'resources', 'AllTheThings', 'db', 'Standard', 'Categories')

    if not os.path.isdir(db_dir):
        print(f"ERROR: Database directory not found: {db_dir}")
        return

    lua_files = glob.glob(os.path.join(db_dir, '*.lua'))
    if not lua_files:
        print(f"ERROR: No .lua files found in {db_dir}")
        return

    print(f"Found {len(lua_files)} database files in {db_dir}")

    all_mappings = defaultdict(set)

    for filepath in sorted(lua_files):
        filename = os.path.basename(filepath)
        print(f"  Parsing {filename}...", end=' ', flush=True)

        with open(filepath, 'r', encoding='utf-8-sig') as f:
            content = f.read()

        tokens = tokenize(content)

        # Parse the local a={...} array for NPC provider references and number lists
        array_npcs, array_num_lists = parse_local_array(tokens)

        npc_map = parse_tokens(tokens, array_npcs, array_num_lists)

        count = sum(len(v) for v in npc_map.values())
        print(f"{len(npc_map)} NPCs, {count} mappings (array has {len(array_npcs)} NPC refs, {len(array_num_lists)} num lists)")

        for npc_id, entries in npc_map.items():
            all_mappings[npc_id].update(entries)

    total_npcs = len(all_mappings)
    total_mappings = sum(len(v) for v in all_mappings.values())
    print(f"\nTotal: {total_npcs} NPCs, {total_mappings} mappings")

    output_dir = os.path.join(script_dir, 'resources', 'intermediate')
    os.makedirs(output_dir, exist_ok=True)
    output_path = os.path.join(output_dir, 'npc_list.txt')
    write_output(all_mappings, output_path)
    print(f"Output written to: {output_path}")


if __name__ == '__main__':
    main()