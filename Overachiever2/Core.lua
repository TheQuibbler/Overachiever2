-- Overachiever2: Core
-- Modern rewritten initialization

local addonName, ns = ...

local Utils = Overachiever2.Utils

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == addonName then
        Utils.Print(ns.L["CORE_INIT"])
        -- Setup default settings
        Overachiever2_Settings = Overachiever2_Settings or {}
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Initial cache check or UI hooks could go here later
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", OnEvent)

ns.MainFrame = frame

-- SLASH COMMANDS
-------------------

SLASH_Overachiever21 = "/oa"
SlashCmdList["Overachiever2"] = function(msg)
    msg = msg:trim()
    local cmd, args = msg:match("^(%S*)%s*(.-)$")
    cmd = cmd:lower()

    if cmd == "rebuild" then
        ns.ForceRebuildScanner()
    elseif cmd == "debug" then
        ns.ToggleDebugMode()
    elseif cmd == "search" then
        if args == "" then
            print("|cff00ff00Overachiever2 Search Debug|r")
            print("Usage: /oa search <query>")
            print("Example: /oa search 20 Dungeon Quests Completed")
        else
            local start = debugprofilestop()
            local results = Overachiever2.SearchAchievementByNameOrID(Overachiever2.GetAllAchievementIDs(), args, false)
            local elapsed = debugprofilestop() - start

            print(string.format("|cff00ff00Found %d achievements in %.2fms|r", #results, elapsed))
            for i = 1, math.min(5, #results) do
                local id, name = GetAchievementInfo(results[i])
                print(string.format("  [%d] %s", id, name))
            end
            if #results > 5 then
                print(string.format("  ... and %d more", #results - 5))
            end
        end
    else
        -- Default: print help
        print(Utils.BlizzardGreenText(ns.L["SLASH_CMD_HELP"]))
        print(ns.L["SLASH_CMD_REBUILD"])
        print(ns.L["SLASH_CMD_DEBUG"])
        print(ns.L["SLASH_CMD_SEARCH"])
    end
end
