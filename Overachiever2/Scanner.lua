-- Overachiever2: Scanner
-- Logic for matching game objects (Items, NPCs) to achievement criteria

local _, ns = ...

-- Helper to get the ID from a GUID
function ns.GetIDFromGUID(guid)
    if not guid then return end
    local unitType, _, _, _, _, id = strsplit("-", guid)
    if unitType == "Creature" or unitType == "Vehicle" then
        return tonumber(id)
    end
end

-- Public API: Find achievements related to an Item
-- TODO: Implement with prebuilt item DB
function ns.GetItemAchievements(itemID, itemName)
    return {}
end

-- Public API: Find achievements related to a Unit (NPC)
-- Uses prebuilt DB lookup (no runtime scanning needed)
-- Format: each entry in DB is {achID, criteriaID}
function ns.GetUnitAchievements(unit)
    local ok, guid = pcall(UnitGUID, unit)
    if not ok then return {} end
    local npcID = ns.GetIDFromGUID(guid)
    if not npcID then return {} end

    local entries = ns.DB.NpcAchievements[npcID]
    if not entries then return {} end

    -- Deduplicate by achievement ID (one NPC can match multiple criteria of the same achievement)
    local seen = {}
    local matches = {}
    for _, entry in ipairs(entries) do
        local achID, criteriaID = entry[1], entry[2]
        if not seen[achID] then
            seen[achID] = true
            local _, achName, _, achCompleted = ns.GetAchievementInfo(achID)
            if achName then
                -- Get criteria-specific completion via criteriaID
                local criteriaString, _, critCompleted = GetAchievementCriteriaInfoByID(achID, criteriaID)
                table.insert(matches, {
                    achID = achID,
                    achName = achName,
                    achCompleted = achCompleted,
                    criteriaID = criteriaID,
                    criteriaString = criteriaString,
                    criteriaCompleted = critCompleted,
                })
            end
        end
    end

    return matches
end
