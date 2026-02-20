-- Overachiever2: Localization
-- Centralized string management for different languages

local _, ns = ...

-- Metatable to return the key itself if no translation is found
local L = setmetatable({}, {
    __index = function(t, k)
        return k
    end
})

ns.L = L

-- ============================================================================
-- Default: English (enUS / enGB)
-- ============================================================================

L["CORE_INIT"] = "Initialization complete."
L["DEBUG_ENABLED"] = "Debug mode enabled."
L["DEBUG_DISABLED"] = "Debug mode disabled."

L["SLASH_CMD_HELP"] = "Overachiever2 Commands:"
L["SLASH_CMD_REBUILD"] = "/oa rebuild: Force rebuild achievement scanner cache."
L["SLASH_CMD_DEBUG"] = "/oa debug: Toggle debug mode (Tooltip ID display)."

L["SCANNER_INIT_MSG"] = "Scanner initialized via %s. (%.2f ms)"
L["SCANNER_REBUILT"] = "Achievement scanner memory rebuilt."

L["OPT_DEBUG_TITLE"] = "Tooltip ID Display (Debug Mode)"
L["OPT_DEBUG_DESC"] = "Show NPC, Item, and Achievement IDs in tooltips."

L["SERIESTIP"] = "Part of a series:"

-- ============================================================================
-- Korean (koKR)
-- ============================================================================

if GetLocale() == "koKR" then
    L["CORE_INIT"] = "초기화가 완료되었습니다."
    L["DEBUG_ENABLED"] = "디버그 모드가 활성화되었습니다."
    L["DEBUG_DISABLED"] = "디버그 모드가 비활성화되었습니다."

    L["SLASH_CMD_HELP"] = "Overachiever2 명령어:"
    L["SLASH_CMD_REBUILD"] = "/oa rebuild: 업적 스캐너 캐시를 강제로 다시 생성합니다."
    L["SLASH_CMD_DEBUG"] = "/oa debug: 디버그 모드(툴팁 ID 표시)를 켜거나 끕니다."

    L["SCANNER_INIT_MSG"] = "스캐너를 %s를 통해 초기화했습니다. (%.2f ms)"
    L["SCANNER_REBUILT"] = "모든 업적 스캐너 정보를 다시 생성했습니다."

    L["OPT_DEBUG_TITLE"] = "툴팁 ID 표시 (디버그 모드)"
    L["OPT_DEBUG_DESC"] = "NPC, 아이템, 업적 ID를 툴팁에 추가로 표시합니다."

    L["SERIESTIP"] = "업적 세트:";
end
