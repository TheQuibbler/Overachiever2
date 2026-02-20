-- Overachiever2: Core
-- Modern rewritten initialization

local addonName, ns = ...

local Utils = Overachiever2.Utils

-- Global access (table already created in Utils.lua)
Overachiever2 = Overachiever2 or {}
Overachiever2_Settings = Overachiever2_Settings or {}

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
    msg = msg:lower():trim()
    if msg == "rebuild" then
        ns.ForceRebuildScanner()
    elseif msg == "debug" then
        ns.ToggleDebugMode()
    else
        -- Default: print help
        print(Utils.BlizzardGreenText(ns.L["SLASH_CMD_HELP"]))
        print(ns.L["SLASH_CMD_REBUILD"])
        print(ns.L["SLASH_CMD_DEBUG"])
    end
end
