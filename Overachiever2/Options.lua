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
    if Overachiever2_Settings.EnableNPCTooltip == nil then
        Overachiever2_Settings.EnableNPCTooltip = true
    end
    if Overachiever2_Settings.EnableAchievementTooltip == nil then
        Overachiever2_Settings.EnableAchievementTooltip = true
    end
end

-- Modern Settings API (Retail / 10.0+)
local function RegisterOptions()
    local category, layout = Settings.RegisterVerticalLayoutCategory("Overachiever2")
    Settings.RegisterAddOnCategory(category)

    -- Enable NPC Tooltip checkbox
    do
        local variable = "EnableNPCTooltip"
        local name = ns.L["OPT_NPC_TOOLTIP_TITLE"]
        local tooltip = ns.L["OPT_NPC_TOOLTIP_DESC"]

        local setting = Settings.RegisterProxySetting(category, "Overachiever2_" .. variable,
            Settings.VarType.Boolean, name, Overachiever2_Settings.EnableNPCTooltip,
            function() return Overachiever2_Settings[variable] end,
            function(value) Overachiever2_Settings[variable] = value end)

        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Enable Achievement Tooltip checkbox
    do
        local variable = "EnableAchievementTooltip"
        local name = ns.L["OPT_ACH_TOOLTIP_TITLE"]
        local tooltip = ns.L["OPT_ACH_TOOLTIP_DESC"]

        local setting = Settings.RegisterProxySetting(category, "Overachiever2_" .. variable,
            Settings.VarType.Boolean, name, Overachiever2_Settings.EnableAchievementTooltip,
            function() return Overachiever2_Settings[variable] end,
            function(value) Overachiever2_Settings[variable] = value end)

        Settings.CreateCheckbox(category, setting, tooltip)
    end

    ns.OptionsCategory = category
end

function ns.ToggleDebugMode()
    Overachiever2_Settings.Debug = not Overachiever2_Settings.Debug
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
