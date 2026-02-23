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

local locale = GetLocale()

-- ============================================================================
-- Korean (koKR)
-- ============================================================================

if locale == "koKR" then
    L["TAB_WATCH"] = "감시"
    L["TAB_WATCH_DESC"] = "개인 감시 목록에 좋아하는 업적을 수집합니다.\nAlt+클릭으로 업적을 추가하세요."
    L["TAB_WATCH_SORT_BY"] = "정렬:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "감시 목록에서 업적 제거. 또는 마우스 오른쪽 버튼으로 제거할 수 있습니다."
end

-- ============================================================================
-- Simplified Chinese (zhCN)
-- ============================================================================

if locale == "zhCN" then
    L["TAB_WATCH"] = "关注"
    L["TAB_WATCH_DESC"] = "将喜爱的成就加入个人关注列表。\n按住Alt键点击任意成就即可添加。"
    L["TAB_WATCH_SORT_BY"] = "排序："
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "从关注列表中移除此成就。您也可通过鼠标右键点击直接移除。"
end

-- ============================================================================
-- Traditional Chinese (zhTW)
-- ============================================================================

if locale == "zhTW" then
    L["TAB_WATCH"] = "關注"
    L["TAB_WATCH_DESC"] = "將喜愛的成就加入個人關注清單。\n按住Alt鍵點擊任意成就即可新增。"
    L["TAB_WATCH_SORT_BY"] = "排序："
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "從關注清單中移除此成就。您也可透過滑鼠右鍵點擊直接移除。"
end

-- ============================================================================
-- German (deDE)
-- ============================================================================

if locale == "deDE" then
    L["TAB_WATCH"] = "Beobachten"
    L["TAB_WATCH_DESC"] = "Sammle Lieblingserfolge in einer persönlichen Beobachtungsliste.\nAlt+Klick auf einen Erfolg, um ihn hinzuzufügen."
    L["TAB_WATCH_SORT_BY"] = "Sortieren nach:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Erfolg von der Beobachtungsliste entfernen. Oder per Rechtsklick entfernen."
end

-- ============================================================================
-- French (frFR)
-- ============================================================================

if locale == "frFR" then
    L["TAB_WATCH"] = "Suivi"
    L["TAB_WATCH_DESC"] = "Ajoutez vos hauts faits favoris à une liste de suivi personnelle.\nAlt+Clic sur un haut fait pour l'ajouter."
    L["TAB_WATCH_SORT_BY"] = "Trier par :"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Retirer le haut fait de la liste de suivi. Vous pouvez aussi le retirer par un clic droit."
end

-- ============================================================================
-- Russian (ruRU)
-- ============================================================================

if locale == "ruRU" then
    L["TAB_WATCH"] = "Избранное"
    L["TAB_WATCH_DESC"] = "Собирайте любимые достижения в персональном списке.\nAlt+Клик по достижению, чтобы добавить его."
    L["TAB_WATCH_SORT_BY"] = "Сортировка:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Убрать достижение из списка. Также можно убрать правым кликом мыши."
end

-- ============================================================================
-- Spanish (esES / esMX)
-- ============================================================================

if locale == "esES" or locale == "esMX" then
    L["TAB_WATCH"] = "Seguimiento"
    L["TAB_WATCH_DESC"] = "Recopila logros favoritos en una lista de seguimiento personal.\nAlt+Clic en cualquier logro para añadirlo."
    L["TAB_WATCH_SORT_BY"] = "Ordenar por:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Eliminar logro de la lista de seguimiento. También puedes eliminarlo con clic derecho."
end
