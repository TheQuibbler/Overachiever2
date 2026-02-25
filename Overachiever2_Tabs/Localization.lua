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

L["TAB_SEARCH"] = "Search"
L["TAB_SEARCH_DESC"] = "Search for achievements by name, description, criteria, or rewards."
L["SEARCH_SORT_BY"] = "Sort by:"
L["SEARCH_NAME"] = "Name/ID:"
L["SEARCH_DESC"] = "Description:"
L["SEARCH_CRITERIA"] = "Criteria:"
L["SEARCH_REWARD"] = "Reward:"
L["SEARCH_ANY"] = "Any field:"
L["SEARCH_TYPE"] = "Type:"
L["SEARCH_TYPE_ALL"] = "All"
L["SEARCH_TYPE_PERSONAL"] = "Personal"
L["SEARCH_TYPE_GUILD"] = "Guild"
L["SEARCH_TYPE_OTHER"] = "Unlisted"
L["SEARCH_INCLUDE_UNLISTED"] = "Include unlisted achievements"
L["SEARCH_INCLUDE_UNLISTED_TIP"] = "When checked, includes hidden achievements (e.g. Feats of Strength, faction-specific) that aren't normally shown in the achievement UI."
L["SEARCH_SUBMIT"] = "Search"
L["SEARCH_RESET"] = "Reset"
L["SEARCH_RESULTS"] = "Found %d achievement(s)"
L["SEARCH_SEARCHING"] = "Searching..."
L["SEARCH_EMPTY_TEXT"] = "Enter search terms and click Search.\nYou can search by achievement name, ID, description, criteria, or rewards."

local locale = GetLocale()

-- ============================================================================
-- Korean (koKR)
-- ============================================================================

if locale == "koKR" then
    L["TAB_WATCH"] = "감시"
    L["TAB_WATCH_DESC"] = "개인 감시 목록에 좋아하는 업적을 수집합니다.\nAlt+클릭으로 업적을 추가하세요."
    L["TAB_WATCH_SORT_BY"] = "정렬:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "감시 목록에서 업적 제거. 또는 마우스 오른쪽 버튼으로 제거할 수 있습니다."

    L["TAB_SEARCH"] = "검색"
    L["TAB_SEARCH_DESC"] = "이름, 설명, 조건 또는 보상으로 업적을 검색합니다."
    L["SEARCH_SORT_BY"] = "정렬:"
    L["SEARCH_NAME"] = "이름/ID:"
    L["SEARCH_DESC"] = "설명:"
    L["SEARCH_CRITERIA"] = "조건:"
    L["SEARCH_REWARD"] = "보상:"
    L["SEARCH_ANY"] = "모든 필드:"
    L["SEARCH_TYPE"] = "유형:"
    L["SEARCH_TYPE_ALL"] = "전체"
    L["SEARCH_TYPE_PERSONAL"] = "개인"
    L["SEARCH_TYPE_GUILD"] = "길드"
    L["SEARCH_TYPE_OTHER"] = "미등록"
    L["SEARCH_INCLUDE_UNLISTED"] = "숨겨진 업적 포함"
    L["SEARCH_INCLUDE_UNLISTED_TIP"] = "체크하면 일반적으로 업적 UI에 표시되지 않는 숨겨진 업적(예: 업적 점수 미포함, 진영 전용)을 포함합니다."
    L["SEARCH_SUBMIT"] = "검색"
    L["SEARCH_RESET"] = "초기화"
    L["SEARCH_RESULTS"] = "%d개의 업적을 찾았습니다"
    L["SEARCH_SEARCHING"] = "검색 중..."
    L["SEARCH_EMPTY_TEXT"] = "검색어를 입력하고 검색 버튼을 클릭하세요.\n업적 이름, ID, 설명, 조건 또는 보상으로 검색할 수 있습니다."
end

-- ============================================================================
-- Simplified Chinese (zhCN)
-- ============================================================================

if locale == "zhCN" then
    L["TAB_WATCH"] = "关注"
    L["TAB_WATCH_DESC"] = "将喜爱的成就加入个人关注列表。\n按住Alt键点击任意成就即可添加。"
    L["TAB_WATCH_SORT_BY"] = "排序："
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "从关注列表中移除此成就。您也可通过鼠标右键点击直接移除。"

    L["TAB_SEARCH"] = "搜索"
    L["TAB_SEARCH_DESC"] = "按名称、描述、条件或奖励搜索成就。"
    L["SEARCH_SORT_BY"] = "排序："
    L["SEARCH_NAME"] = "名称/ID："
    L["SEARCH_DESC"] = "描述："
    L["SEARCH_CRITERIA"] = "条件："
    L["SEARCH_REWARD"] = "奖励:"
    L["SEARCH_ANY"] = "任意字段："
    L["SEARCH_TYPE"] = "类型："
    L["SEARCH_TYPE_ALL"] = "全部"
    L["SEARCH_TYPE_PERSONAL"] = "个人"
    L["SEARCH_TYPE_GUILD"] = "公会"
    L["SEARCH_TYPE_OTHER"] = "未列出"
    L["SEARCH_INCLUDE_UNLISTED"] = "包含未列出的成就"
    L["SEARCH_INCLUDE_UNLISTED_TIP"] = "勾选后将包含通常不在成就界面显示的隐藏成就（如：壮举、阵营专属）。"
    L["SEARCH_SUBMIT"] = "搜索"
    L["SEARCH_RESET"] = "重置"
    L["SEARCH_RESULTS"] = "找到 %d 个成就"
    L["SEARCH_SEARCHING"] = "搜索中..."
    L["SEARCH_EMPTY_TEXT"] = "输入搜索条件后点击搜索。\n您可以按成就名称、ID、描述、条件或奖励进行搜索。"
end

-- ============================================================================
-- Traditional Chinese (zhTW)
-- ============================================================================

if locale == "zhTW" then
    L["TAB_WATCH"] = "關注"
    L["TAB_WATCH_DESC"] = "將喜愛的成就加入個人關注清單。\n按住Alt鍵點擊任意成就即可新增。"
    L["TAB_WATCH_SORT_BY"] = "排序："
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "從關注清單中移除此成就。您也可透過滑鼠右鍵點擊直接移除。"

    L["TAB_SEARCH"] = "搜尋"
    L["TAB_SEARCH_DESC"] = "按名稱、描述、條件或獎勵搜尋成就。"
    L["SEARCH_SORT_BY"] = "排序："
    L["SEARCH_NAME"] = "名稱/ID："
    L["SEARCH_DESC"] = "描述："
    L["SEARCH_CRITERIA"] = "條件："
    L["SEARCH_REWARD"] = "獎勵："
    L["SEARCH_ANY"] = "任意欄位："
    L["SEARCH_TYPE"] = "類型："
    L["SEARCH_TYPE_ALL"] = "全部"
    L["SEARCH_TYPE_PERSONAL"] = "個人"
    L["SEARCH_TYPE_GUILD"] = "公會"
    L["SEARCH_TYPE_OTHER"] = "未列出"
    L["SEARCH_INCLUDE_UNLISTED"] = "包含未列出的成就"
    L["SEARCH_INCLUDE_UNLISTED_TIP"] = "勾選後將包含通常不在成就介面顯示的隱藏成就（如：壯舉、陣營專屬）。"
    L["SEARCH_SUBMIT"] = "搜尋"
    L["SEARCH_RESET"] = "重置"
    L["SEARCH_RESULTS"] = "找到 %d 個成就"
    L["SEARCH_SEARCHING"] = "搜尋中..."
    L["SEARCH_EMPTY_TEXT"] = "輸入搜尋條件後點擊搜尋。\n您可以按成就名稱、ID、描述、條件或獎勵進行搜尋。"
end

-- ============================================================================
-- German (deDE)
-- ============================================================================

if locale == "deDE" then
    L["TAB_WATCH"] = "Beobachten"
    L["TAB_WATCH_DESC"] = "Sammle Lieblingserfolge in einer persönlichen Beobachtungsliste.\nAlt+Klick auf einen Erfolg, um ihn hinzuzufügen."
    L["TAB_WATCH_SORT_BY"] = "Sortieren nach:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Erfolg von der Beobachtungsliste entfernen. Oder per Rechtsklick entfernen."

    L["TAB_SEARCH"] = "Suche"
    L["TAB_SEARCH_DESC"] = "Erfolge nach Name, Beschreibung, Kriterien oder Belohnungen suchen."
    L["SEARCH_SORT_BY"] = "Sortieren nach:"
    L["SEARCH_NAME"] = "Name/ID:"
    L["SEARCH_DESC"] = "Beschreibung:"
    L["SEARCH_CRITERIA"] = "Kriterien:"
    L["SEARCH_REWARD"] = "Belohnung:"
    L["SEARCH_ANY"] = "Beliebiges Feld:"
    L["SEARCH_TYPE"] = "Typ:"
    L["SEARCH_TYPE_ALL"] = "Alle"
    L["SEARCH_TYPE_PERSONAL"] = "Persönlich"
    L["SEARCH_TYPE_GUILD"] = "Gilde"
    L["SEARCH_TYPE_OTHER"] = "Nicht aufgeführt"
    L["SEARCH_INCLUDE_UNLISTED"] = "Nicht aufgeführte Erfolge einbeziehen"
    L["SEARCH_INCLUDE_UNLISTED_TIP"] = "Wenn aktiviert, werden versteckte Erfolge (z.B. Ruhmestaten, fraktionsspezifische) einbezogen, die normalerweise nicht in der Erfolgs-UI angezeigt werden."
    L["SEARCH_SUBMIT"] = "Suchen"
    L["SEARCH_RESET"] = "Zurücksetzen"
    L["SEARCH_RESULTS"] = "%d Erfolg(e) gefunden"
    L["SEARCH_SEARCHING"] = "Suche läuft..."
    L["SEARCH_EMPTY_TEXT"] = "Geben Sie Suchbegriffe ein und klicken Sie auf Suchen.\nSie können nach Erfolgsname, ID, Beschreibung, Kriterien oder Belohnungen suchen."
end

-- ============================================================================
-- French (frFR)
-- ============================================================================

if locale == "frFR" then
    L["TAB_WATCH"] = "Suivi"
    L["TAB_WATCH_DESC"] = "Ajoutez vos hauts faits favoris à une liste de suivi personnelle.\nAlt+Clic sur un haut fait pour l'ajouter."
    L["TAB_WATCH_SORT_BY"] = "Trier par :"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Retirer le haut fait de la liste de suivi. Vous pouvez aussi le retirer par un clic droit."

    L["TAB_SEARCH"] = "Recherche"
    L["TAB_SEARCH_DESC"] = "Rechercher des hauts faits par nom, description, critères ou récompenses."
    L["SEARCH_SORT_BY"] = "Trier par :"
    L["SEARCH_NAME"] = "Nom/ID :"
    L["SEARCH_DESC"] = "Description :"
    L["SEARCH_CRITERIA"] = "Critères :"
    L["SEARCH_REWARD"] = "Récompense :"
    L["SEARCH_ANY"] = "N'importe quel champ :"
    L["SEARCH_TYPE"] = "Type :"
    L["SEARCH_TYPE_ALL"] = "Tous"
    L["SEARCH_TYPE_PERSONAL"] = "Personnel"
    L["SEARCH_TYPE_GUILD"] = "Guilde"
    L["SEARCH_TYPE_OTHER"] = "Non listé"
    L["SEARCH_INCLUDE_UNLISTED"] = "Inclure les hauts faits non listés"
    L["SEARCH_INCLUDE_UNLISTED_TIP"] = "Si coché, inclut les hauts faits cachés (par ex. Exploits, spécifiques aux factions) qui ne sont normalement pas affichés dans l'interface des hauts faits."
    L["SEARCH_SUBMIT"] = "Rechercher"
    L["SEARCH_RESET"] = "Réinitialiser"
    L["SEARCH_RESULTS"] = "%d haut(s) fait(s) trouvé(s)"
    L["SEARCH_SEARCHING"] = "Recherche en cours..."
    L["SEARCH_EMPTY_TEXT"] = "Entrez des termes de recherche et cliquez sur Rechercher.\nVous pouvez rechercher par nom, ID, description, critères ou récompenses."
end

-- ============================================================================
-- Russian (ruRU)
-- ============================================================================

if locale == "ruRU" then
    L["TAB_WATCH"] = "Избранное"
    L["TAB_WATCH_DESC"] = "Собирайте любимые достижения в персональном списке.\nAlt+Клик по достижению, чтобы добавить его."
    L["TAB_WATCH_SORT_BY"] = "Сортировка:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Убрать достижение из списка. Также можно убрать правым кликом мыши."

    L["TAB_SEARCH"] = "Поиск"
    L["TAB_SEARCH_DESC"] = "Поиск достижений по имени, описанию, критериям или наградам."
    L["SEARCH_SORT_BY"] = "Сортировка:"
    L["SEARCH_NAME"] = "Имя/ID:"
    L["SEARCH_DESC"] = "Описание:"
    L["SEARCH_CRITERIA"] = "Критерии:"
    L["SEARCH_REWARD"] = "Награда:"
    L["SEARCH_ANY"] = "Любое поле:"
    L["SEARCH_TYPE"] = "Тип:"
    L["SEARCH_TYPE_ALL"] = "Все"
    L["SEARCH_TYPE_PERSONAL"] = "Личные"
    L["SEARCH_TYPE_GUILD"] = "Гильдия"
    L["SEARCH_TYPE_OTHER"] = "Неперечисленные"
    L["SEARCH_INCLUDE_UNLISTED"] = "Включить неперечисленные достижения"
    L["SEARCH_INCLUDE_UNLISTED_TIP"] = "Если отмечено, включает скрытые достижения (например, подвиги, специфичные для фракций), которые обычно не отображаются в интерфейсе достижений."
    L["SEARCH_SUBMIT"] = "Поиск"
    L["SEARCH_RESET"] = "Сброс"
    L["SEARCH_RESULTS"] = "Найдено достижений: %d"
    L["SEARCH_SEARCHING"] = "Поиск..."
    L["SEARCH_EMPTY_TEXT"] = "Введите условия поиска и нажмите Поиск.\nВы можете искать по имени, ID, описанию, критериям или наградам."
end

-- ============================================================================
-- Spanish (esES / esMX)
-- ============================================================================

if locale == "esES" or locale == "esMX" then
    L["TAB_WATCH"] = "Seguimiento"
    L["TAB_WATCH_DESC"] = "Recopila logros favoritos en una lista de seguimiento personal.\nAlt+Clic en cualquier logro para añadirlo."
    L["TAB_WATCH_SORT_BY"] = "Ordenar por:"
    L["TAB_WATCH_REMOVE_ACHIEVEMENT"] = "Eliminar logro de la lista de seguimiento. También puedes eliminarlo con clic derecho."

    L["TAB_SEARCH"] = "Búsqueda"
    L["TAB_SEARCH_DESC"] = "Buscar logros por nombre, descripción, criterios o recompensas."
    L["SEARCH_SORT_BY"] = "Ordenar por:"
    L["SEARCH_NAME"] = "Nombre/ID:"
    L["SEARCH_DESC"] = "Descripción:"
    L["SEARCH_CRITERIA"] = "Criterios:"
    L["SEARCH_REWARD"] = "Recompensa:"
    L["SEARCH_ANY"] = "Cualquier campo:"
    L["SEARCH_TYPE"] = "Tipo:"
    L["SEARCH_TYPE_ALL"] = "Todos"
    L["SEARCH_TYPE_PERSONAL"] = "Personal"
    L["SEARCH_TYPE_GUILD"] = "Hermandad"
    L["SEARCH_TYPE_OTHER"] = "No listados"
    L["SEARCH_INCLUDE_UNLISTED"] = "Incluir logros no listados"
    L["SEARCH_INCLUDE_UNLISTED_TIP"] = "Si está marcado, incluye logros ocultos (por ejemplo, Proezas, específicos de facción) que normalmente no se muestran en la interfaz de logros."
    L["SEARCH_SUBMIT"] = "Buscar"
    L["SEARCH_RESET"] = "Restablecer"
    L["SEARCH_RESULTS"] = "Se encontraron %d logro(s)"
    L["SEARCH_SEARCHING"] = "Buscando..."
    L["SEARCH_EMPTY_TEXT"] = "Ingresa términos de búsqueda y haz clic en Buscar.\nPuedes buscar por nombre, ID, descripción, criterios o recompensas de logros."
end
