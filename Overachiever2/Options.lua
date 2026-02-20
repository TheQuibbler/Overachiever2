-- Overachiever2: Options
-- Modern Options UI using Settings API

local addonName, ns = ...

local Utils = Overachiever2.Utils

-- Default settings
local function SetDefaultSettings()
    Overachiever2_Settings = Overachiever2_Settings or {}
    if Overachiever2_Settings.Debug == nil then
        Overachiever2_Settings.Debug = false
    end
end

-- Modern Settings API (Retail / 10.0+)
local function RegisterOptions()
    local category, layout = Settings.RegisterVerticalLayoutCategory("Overachiever2")
    Settings.RegisterAddOnCategory(category)

    -- 1. Debug Mode Setting
    local variable = "Debug"
    local defaultValue = false

    local setting = Settings.RegisterAddOnSetting(category, "Overachiever2_Debug", variable, Overachiever2_Settings, Settings.VarType.Boolean, ns.L["OPT_DEBUG_TITLE"], defaultValue)
    Settings.CreateCheckbox(category, setting, ns.L["OPT_DEBUG_TITLE"], ns.L["OPT_DEBUG_DESC"])

    ns.OptionsCategory = category
end

function ns.ToggleDebugMode()
    Overachiever2_Settings.Debug = not Overachiever2_Settings.Debug
    -- Sync with modern Settings UI if it's already registered
    local setting = Settings.GetSetting("Overachiever2_Debug")
    if setting then
        setting:SetValue(Overachiever2_Settings.Debug)
    end
    local msg = Overachiever2_Settings.Debug and ns.L["DEBUG_ENABLED"] or ns.L["DEBUG_DISABLED"]
    Utils.Print(msg)
end

-- Initialization
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, name)
    if name == addonName then
        SetDefaultSettings()
        -- Ensure Settings API is available (Retail)
        if Settings and Settings.RegisterAddOnCategory then
            RegisterOptions()
        end
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
