-- Overachiever2_Tabs: Localization
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

L["TAB_WATCH"] = "Watch"
L["TAB_WATCH_DESC"] = "Collect favorite achievements in a personal watch list.\nAlt+Click any achievement to add it."
L["TAB_WATCH_SORT_BY"] = "Sort by:"

L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Remove achievement from watch list. Or you can remove it by right-clicking with the mouse."

-- ============================================================================
-- Korean (koKR)
-- ============================================================================

if GetLocale() == "koKR" then
    L["TAB_WATCH"] = "감시"
    L["TAB_WATCH_DESC"] = "개인 감시 목록에 좋아하는 업적을 수집합니다.\nAlt+클릭으로 업적을 추가하세요."
    L["TAB_WATCH_SORT_BY"] = "정렬:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "감시 목록에서 업적 제거. 또는 마우스 오른쪽 버튼으로 제거할 수 있습니다."
end

-- ============================================================================
-- Simplified Chinese (zhCN)
-- ============================================================================

if GetLocale() == "zhCN" then
    L["TAB_WATCH"] = "关注"
    L["TAB_WATCH_DESC"] = "将喜爱的成就加入个人关注列表。\n按住Alt键点击任意成就即可添加。"
    L["TAB_WATCH_SORT_BY"] = "排序："
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "从关注列表中移除此成就。您也可通过鼠标右键点击直接移除。"
end
