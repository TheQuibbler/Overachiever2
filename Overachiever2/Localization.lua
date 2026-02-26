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
L["SLASH_CMD_SEARCH"] = "/oa search <query>: Search achievements by name or ID (for debug)."

L["SCANNER_INIT_MSG"] = "Scanner initialized via %s. (%.2f ms)"
L["SCANNER_REBUILT"] = "Achievement scanner memory rebuilt."

L["OPT_DEBUG_TITLE"] = "Tooltip ID Display (Debug Mode)"
L["OPT_DEBUG_DESC"] = "Show NPC, Item, and Achievement IDs in tooltips."

L["SERIESTIP"] = "Part of a series:"
L["CRITERIA_OF"] = "Criteria of:"

local locale = GetLocale()

-- ============================================================================
-- Korean (koKR)
-- ============================================================================

if locale == "koKR" then
    L["CORE_INIT"] = "초기화가 완료되었습니다."
    L["DEBUG_ENABLED"] = "디버그 모드가 활성화되었습니다."
    L["DEBUG_DISABLED"] = "디버그 모드가 비활성화되었습니다."

    L["SLASH_CMD_HELP"] = "Overachiever2 명령어:"
    L["SLASH_CMD_REBUILD"] = "/oa rebuild: 업적 스캐너 캐시를 강제로 다시 생성합니다."
    L["SLASH_CMD_DEBUG"] = "/oa debug: 디버그 모드(툴팁 ID 표시)를 켜거나 끕니다."
    L["SLASH_CMD_SEARCH"] = "/oa search <검색어>: 이름 또는 ID로 업적을 검색합니다 (디버그용)."

    L["SCANNER_INIT_MSG"] = "스캐너를 %s를 통해 초기화했습니다. (%.2f ms)"
    L["SCANNER_REBUILT"] = "모든 업적 스캐너 정보를 다시 생성했습니다."

    L["OPT_DEBUG_TITLE"] = "툴팁 ID 표시 (디버그 모드)"
    L["OPT_DEBUG_DESC"] = "NPC, 아이템, 업적 ID를 툴팁에 추가로 표시합니다."

    L["SERIESTIP"] = "업적 세트:"
    L["CRITERIA_OF"] = "다음의 조건:"
end

-- ============================================================================
-- Simplified Chinese (zhCN)
-- ============================================================================

if locale == "zhCN" then
    L["CORE_INIT"] = "初始化完成。"
    L["DEBUG_ENABLED"] = "调试模式已启用。"
    L["DEBUG_DISABLED"] = "调试模式已禁用。"

    L["SLASH_CMD_HELP"] = "Overachiever2 命令："
    L["SLASH_CMD_REBUILD"] = "/oa rebuild：强制重建成就扫描器缓存。"
    L["SLASH_CMD_DEBUG"] = "/oa debug：切换调试模式（显示提示信息ID）。"
    L["SLASH_CMD_SEARCH"] = "/oa search <查询>：按名称或ID搜索成就（用于调试）。"

    L["SCANNER_INIT_MSG"] = "扫描器已通过 %s 初始化（耗时 %.2f 毫秒）。"
    L["SCANNER_REBUILT"] = "成就扫描器缓存已重建。"

    L["OPT_DEBUG_TITLE"] = "显示提示信息ID（调试模式）"
    L["OPT_DEBUG_DESC"] = "在提示信息中显示NPC、物品与成就的ID。"

    L["SERIESTIP"] = "系列成就的一部分："
    L["CRITERIA_OF"] = "条件所属："
end

-- ============================================================================
-- Traditional Chinese (zhTW)
-- ============================================================================

if locale == "zhTW" then
    L["CORE_INIT"] = "初始化完成。"
    L["DEBUG_ENABLED"] = "除錯模式已啟用。"
    L["DEBUG_DISABLED"] = "除錯模式已停用。"

    L["SLASH_CMD_HELP"] = "Overachiever2 指令："
    L["SLASH_CMD_REBUILD"] = "/oa rebuild：強制重建成就掃描器快取。"
    L["SLASH_CMD_DEBUG"] = "/oa debug：切換除錯模式（顯示提示資訊ID）。"
    L["SLASH_CMD_SEARCH"] = "/oa search <查詢>：按名稱或ID搜尋成就（用於除錯）。"

    L["SCANNER_INIT_MSG"] = "掃描器已透過 %s 初始化（耗時 %.2f 毫秒）。"
    L["SCANNER_REBUILT"] = "成就掃描器快取已重建。"

    L["OPT_DEBUG_TITLE"] = "顯示提示資訊ID（除錯模式）"
    L["OPT_DEBUG_DESC"] = "在提示資訊中顯示NPC、物品與成就的ID。"

    L["SERIESTIP"] = "系列成就的一部分："
    L["CRITERIA_OF"] = "條件所屬："
end

-- ============================================================================
-- German (deDE)
-- ============================================================================

if locale == "deDE" then
    L["CORE_INIT"] = "Initialisierung abgeschlossen."
    L["DEBUG_ENABLED"] = "Debug-Modus aktiviert."
    L["DEBUG_DISABLED"] = "Debug-Modus deaktiviert."

    L["SLASH_CMD_HELP"] = "Overachiever2-Befehle:"
    L["SLASH_CMD_REBUILD"] = "/oa rebuild: Erfolgscanner-Cache neu erstellen."
    L["SLASH_CMD_DEBUG"] = "/oa debug: Debug-Modus umschalten (Tooltip-ID-Anzeige)."
    L["SLASH_CMD_SEARCH"] = "/oa search <Suchbegriff>: Erfolge nach Name oder ID suchen (für Debugging)."

    L["SCANNER_INIT_MSG"] = "Scanner über %s initialisiert. (%.2f ms)"
    L["SCANNER_REBUILT"] = "Erfolgscanner-Cache wurde neu erstellt."

    L["OPT_DEBUG_TITLE"] = "Tooltip-ID-Anzeige (Debug-Modus)"
    L["OPT_DEBUG_DESC"] = "NPC-, Gegenstands- und Erfolgs-IDs in Tooltips anzeigen."

    L["SERIESTIP"] = "Teil einer Serie:"
    L["CRITERIA_OF"] = "Kriterium von:"
end

-- ============================================================================
-- French (frFR)
-- ============================================================================

if locale == "frFR" then
    L["CORE_INIT"] = "Initialisation terminée."
    L["DEBUG_ENABLED"] = "Mode débogage activé."
    L["DEBUG_DISABLED"] = "Mode débogage désactivé."

    L["SLASH_CMD_HELP"] = "Commandes Overachiever2 :"
    L["SLASH_CMD_REBUILD"] = "/oa rebuild : Forcer la reconstruction du cache du scanner de hauts faits."
    L["SLASH_CMD_DEBUG"] = "/oa debug : Activer/désactiver le mode débogage (affichage des ID dans les infobulles)."
    L["SLASH_CMD_SEARCH"] = "/oa search <requête> : Rechercher des hauts faits par nom ou ID (pour débogage)."

    L["SCANNER_INIT_MSG"] = "Scanner initialisé via %s. (%.2f ms)"
    L["SCANNER_REBUILT"] = "Cache du scanner de hauts faits reconstruit."

    L["OPT_DEBUG_TITLE"] = "Affichage des ID dans les infobulles (Mode débogage)"
    L["OPT_DEBUG_DESC"] = "Afficher les ID des PNJ, objets et hauts faits dans les infobulles."

    L["SERIESTIP"] = "Fait partie d'une série :"
    L["CRITERIA_OF"] = "Critère de :"
end

-- ============================================================================
-- Russian (ruRU)
-- ============================================================================

if locale == "ruRU" then
    L["CORE_INIT"] = "Инициализация завершена."
    L["DEBUG_ENABLED"] = "Режим отладки включён."
    L["DEBUG_DISABLED"] = "Режим отладки отключён."

    L["SLASH_CMD_HELP"] = "Команды Overachiever2:"
    L["SLASH_CMD_REBUILD"] = "/oa rebuild: Принудительно пересоздать кэш сканера достижений."
    L["SLASH_CMD_DEBUG"] = "/oa debug: Переключить режим отладки (отображение ID в подсказках)."
    L["SLASH_CMD_SEARCH"] = "/oa search <запрос>: Поиск достижений по имени или ID (для отладки)."

    L["SCANNER_INIT_MSG"] = "Сканер инициализирован через %s. (%.2f мс)"
    L["SCANNER_REBUILT"] = "Кэш сканера достижений пересоздан."

    L["OPT_DEBUG_TITLE"] = "Отображение ID в подсказках (Режим отладки)"
    L["OPT_DEBUG_DESC"] = "Показывать ID НПС, предметов и достижений в подсказках."

    L["SERIESTIP"] = "Часть серии:"
    L["CRITERIA_OF"] = "Критерий для:"
end

-- ============================================================================
-- Spanish (esES / esMX)
-- ============================================================================

if locale == "esES" or locale == "esMX" then
    L["CORE_INIT"] = "Inicialización completada."
    L["DEBUG_ENABLED"] = "Modo de depuración activado."
    L["DEBUG_DISABLED"] = "Modo de depuración desactivado."

    L["SLASH_CMD_HELP"] = "Comandos de Overachiever2:"
    L["SLASH_CMD_REBUILD"] = "/oa rebuild: Forzar la reconstrucción de la caché del escáner de logros."
    L["SLASH_CMD_DEBUG"] = "/oa debug: Alternar el modo de depuración (mostrar ID en información emergente)."
    L["SLASH_CMD_SEARCH"] = "/oa search <consulta>: Buscar logros por nombre o ID (para depuración)."

    L["SCANNER_INIT_MSG"] = "Escáner inicializado a través de %s. (%.2f ms)"
    L["SCANNER_REBUILT"] = "Caché del escáner de logros reconstruida."

    L["OPT_DEBUG_TITLE"] = "Mostrar ID en información emergente (Modo de depuración)"
    L["OPT_DEBUG_DESC"] = "Mostrar ID de PNJ, objetos y logros en la información emergente."

    L["SERIESTIP"] = "Parte de una serie:"
    L["CRITERIA_OF"] = "Criterio de:"
end
