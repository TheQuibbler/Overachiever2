-- Overachiever2: Utils
-- General utility functions and constants
-- Exposed globally via Overachiever2.Utils for cross-module access.

local appName, ns = ...

Overachiever2 = Overachiever2 or {}
Overachiever2.Utils = {}

local Utils = Overachiever2.Utils

-- Colors (AARRGGBB)
Utils.WhiteColor = "ffffffff"
Utils.BlizzardGreenColor = "ff7eff00"
Utils.BlizzardRedColor = "ffff3D3D"
Utils.GoldColor = "ffffd100"
Utils.RedColor = "ffff0000"
Utils.GreenColor = "ff00ff00"
Utils.BlueColor = "ff0000ff"
Utils.GrayColor = "ff868686"
Utils.DarkGrayColor = "ff404040"

Utils.DebugIconPath = "Interface\\HelpFrame\\HelpIcon-Bug"
Utils.AchievementIconPath = "Interface\\Icons\\Achievement_General"

function Utils.WhiteText(text)
    return "|c" .. Utils.WhiteColor .. text .. "|r"
end

function Utils.BlizzardGreenText(text)
    return "|c" .. Utils.BlizzardGreenColor .. text .. "|r"
end

function Utils.BlizzardRedText(text)
    return "|c" .. Utils.BlizzardRedColor .. text .. "|r"
end

function Utils.GoldText(text)
    return "|c" .. Utils.GoldColor .. text .. "|r"
end

function Utils.RedText(text)
    return "|c" .. Utils.RedColor .. text .. "|r"
end

function Utils.GreenText(text)
    return "|c" .. Utils.GreenColor .. text .. "|r"
end

function Utils.BlueText(text)
    return "|c" .. Utils.BlueColor .. text .. "|r"
end

function Utils.GrayText(text)
    return "|c" .. Utils.GrayColor .. text .. "|r"
end

function Utils.DarkGrayText(text)
    return "|c" .. Utils.DarkGrayColor .. text .. "|r"
end

function Utils.DebugIconText()
    return "|T" .. Utils.DebugIconPath .. ":0|t"
end

function Utils.AchievementIconText()
    return "|T" .. Utils.AchievementIconPath .. ":0|t"
end

function Utils.CheckAtlasText()
    return "|A:common-icon-checkmark:12:12|a"
end

function Utils.RedxAtlasText()
    return "|A:common-icon-redx:12:12|a"
end

-- Global Message Helper
function Utils.Print(msg)
    print(Utils.BlizzardGreenText(appName .. ":") .. " " .. msg)
end

function Utils.ColorByType(val)
    local t = type(val)
    if t == "number" then
        return Utils.GoldText(tostring(val))
    elseif t == "boolean" then
        return (val and Utils.GreenText("true") or Utils.RedText("false"))
    elseif t == "string" then
        return Utils.WhiteText("\"" .. val .. "\"")
    else
        return Utils.DarkGrayText(tostring(val))
    end
end
