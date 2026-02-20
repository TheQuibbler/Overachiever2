-- Overachiever2: Scanner
-- Logic for matching game objects (Items, NPCs) to achievement criteria

local _, ns = ...

local Utils = Overachiever2.Utils

local npcLookup -- References to cache in Overachiever2_DB
local itemLookup -- References to cache in Overachiever2_DB
local isInitialized = false

-- Achievement Criteria Types (from Blizzard API)
local CRITERIA_TYPE_KILL_CREATURE = 0
local CRITERIA_TYPE_ITEM = 27
local CRITERIA_TYPE_USE_ITEM = 28
local CRITERIA_TYPE_DO_EMOTE = 54

-- Helper to get the ID from a GUID
function ns.GetIDFromGUID(guid)
    if not guid then return end
    local unitType, _, _, _, _, id = strsplit("-", guid)
    if unitType == "Creature" or unitType == "Vehicle" then
        return tonumber(id)
    end
end

-- Helper to add to lookup tables (handles multiple achievements per ID/Name)
local function AddToLookup(lookup, key, achID, critIndex)
    if not key then return end
    lookup[key] = lookup[key] or {}
    -- Avoid duplicate entries for the same achievement on the same target
    for _, info in ipairs(lookup[key]) do
        if info.id == achID and info.critIndex == critIndex then
            return
        end
    end
    table.insert(lookup[key], { id = achID, critIndex = critIndex })
end

-- Build lookup tables from achievement data
local function InitializeScanner()
    if isInitialized then return end

    local startTime = debugprofilestop()
    local method = "cache"

    -- Initialize SavedVariable if not present
    Overachiever2_DB = Overachiever2_DB or {}
    Overachiever2_DB.ScannerCache = Overachiever2_DB.ScannerCache or {}
    local cache = Overachiever2_DB.ScannerCache

    local currentBuild = select(4, GetBuildInfo())
    local currentLocale = GetLocale()

    -- Check if we can use the cached data
    if cache.build == currentBuild and cache.locale == currentLocale and cache.npc and cache.item then
        npcLookup = cache.npc
        itemLookup = cache.item
    else
        -- If no valid cache, perform full scan
        method = "scan"
        npcLookup = {}
        itemLookup = {}

        -- Get all categories (Personal + Guild)
        local categories = GetCategoryList()
        local guildCategories = GetGuildCategoryList()

        -- Combine categories
        local allCategories = {}
        for _, catID in ipairs(categories) do table.insert(allCategories, catID) end
        for _, catID in ipairs(guildCategories) do table.insert(allCategories, catID) end

        -- Scan each category
        for _, catID in ipairs(allCategories) do
            local numAchievements = GetCategoryNumAchievements(catID)
            for i = 1, numAchievements do
                local achID = GetAchievementInfo(catID, i)
                if achID then
                    local numCriteria = GetAchievementNumCriteria(achID)
                    for j = 1, numCriteria do
                        local critName, critType, completed, _, _, _, _, assetID = ns.GetAchievementCriteriaInfo(achID, j)

                        -- NPC/Unit Related Types
                        if critType == CRITERIA_TYPE_KILL_CREATURE or critType == CRITERIA_TYPE_DO_EMOTE then
                            if assetID and assetID > 0 then
                                AddToLookup(npcLookup, assetID, achID, j)
                            end
                            if critName and critName ~= "" then
                                AddToLookup(npcLookup, critName, achID, j)
                            end

                        -- Item Related Types
                        elseif critType == CRITERIA_TYPE_ITEM or critType == CRITERIA_TYPE_USE_ITEM then
                            if assetID and assetID > 0 then
                                AddToLookup(itemLookup, assetID, achID, j)
                            end
                            if critName and critName ~= "" then
                                AddToLookup(itemLookup, critName, achID, j)
                            end
                        end
                    end
                end
            end
        end

        -- Save to cache
        cache.npc = npcLookup
        cache.item = itemLookup
        cache.build = currentBuild
        cache.locale = currentLocale
    end

    isInitialized = true

    local duration = debugprofilestop() - startTime
    Utils.Print(string.format(ns.L["SCANNER_INIT_MSG"], method, duration))
end

-- Public API: Find achievements related to an Item
function ns.GetItemAchievements(itemID, itemName)
    if not isInitialized then InitializeScanner() end
    if not itemLookup then return {} end -- Should not happen after init

    local matches = {}
    -- Try matching by ID first, then by name
    local dataID = itemID and itemLookup[itemID]
    local dataName = itemName and itemLookup[itemName]

    local function process(list)
        if not list then return end
        for _, info in ipairs(list) do
            local _, achName, _, achCompleted = ns.GetAchievementInfo(info.id)
            local _, _, critCompleted = ns.GetAchievementCriteriaInfo(info.id, info.critIndex)

            -- Avoid duplicates if both ID and Name matched same achievement
            local found = false
            for _, m in ipairs(matches) do
                if m.id == info.id and m.critIndex == info.critIndex then
                    found = true
                    break
                end
            end

            if not found then
                table.insert(matches, {
                    id = info.id,
                    name = achName,
                    critIndex = info.critIndex,
                    completed = critCompleted
                })
            end
        end
    end

    process(dataID)
    process(dataName)

    return matches
end

-- Public API: Find achievements related to a Unit (NPC)
function ns.GetUnitAchievements(unit)
    if not isInitialized then InitializeScanner() end
    if not npcLookup then return {} end -- Should not happen after init

    local ok, guid = pcall(UnitGUID, unit)
    if not ok then return {} end
    local npcID = ns.GetIDFromGUID(guid)
    local name = UnitName(unit)

    local matches = {}
    local dataID = npcID and npcLookup[npcID]
    local dataName = name and npcLookup[name]

    local function process(list)
        if not list then return end
        for _, info in ipairs(list) do
            local _, achName, _, achCompleted = ns.GetAchievementInfo(info.id)
            local _, _, critCompleted = ns.GetAchievementCriteriaInfo(info.id, info.critIndex)

            local found = false
            for _, m in ipairs(matches) do
                if m.id == info.id and m.critIndex == info.critIndex then
                    found = true
                    break
                end
            end

            if not found then
                table.insert(matches, {
                    id = info.id,
                    name = achName,
                    critIndex = info.critIndex,
                    completed = critCompleted
                })
            end
        end
    end

    process(dataID)
    process(dataName)

    return matches
end

-- Public API: Force a complete rebuild of the scanner cache
function ns.ForceRebuildScanner()
    if Overachiever2_DB and Overachiever2_DB.ScannerCache then
        Overachiever2_DB.ScannerCache = {}
    end
    isInitialized = false
    InitializeScanner()
    Utils.Print(ns.L["SCANNER_REBUILT"])
end
