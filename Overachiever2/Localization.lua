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

L["OPT_NPC_TOOLTIP_TITLE"] = "Enable NPC tooltip"
L["OPT_NPC_TOOLTIP_DESC"] = "Show achievement progress lines when hovering over NPCs."

L["OPT_ACH_TOOLTIP_TITLE"] = "Enable achievement tooltip"
L["OPT_ACH_TOOLTIP_DESC"] = "Show enhanced achievement tooltips with additional details."

L["SERIESTIP"] = "Part of a series"
L["META_ACHIEVEMENT"] = "Meta-achievement"

L["CTXMENU_LINK_CHAT"] = "Link to Chat"
L["CTXMENU_WATCH_ADD"] = "Add to Watch List"
L["CTXMENU_WATCH_REMOVE"] = "Remove from Watch List"
L["CTXMENU_TRACK"] = "Track Achievement"
L["CTXMENU_UNTRACK"] = "Untrack Achievement"

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

    L["OPT_NPC_TOOLTIP_TITLE"] = "NPC 툴팁 활성화"
    L["OPT_NPC_TOOLTIP_DESC"] = "NPC에 마우스를 올렸을 때 업적 진행 상황을 표시합니다."

    L["OPT_ACH_TOOLTIP_TITLE"] = "업적 툴팁 활성화"
    L["OPT_ACH_TOOLTIP_DESC"] = "추가 정보가 포함된 향상된 업적 툴팁을 표시합니다."

    L["SERIESTIP"] = "업적 세트"
    L["META_ACHIEVEMENT"] = "상위 업적"

    L["CTXMENU_LINK_CHAT"] = "채팅에 링크"
    L["CTXMENU_WATCH_ADD"] = "관심 목록에 추가"
    L["CTXMENU_WATCH_REMOVE"] = "관심 목록에서 제거"
    L["CTXMENU_TRACK"] = "업적 추적"
    L["CTXMENU_UNTRACK"] = "업적 추적 해제"
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

    L["OPT_NPC_TOOLTIP_TITLE"] = "启用NPC提示信息"
    L["OPT_NPC_TOOLTIP_DESC"] = "鼠标悬停在NPC上时显示成就进度。"

    L["OPT_ACH_TOOLTIP_TITLE"] = "启用成就提示信息"
    L["OPT_ACH_TOOLTIP_DESC"] = "显示包含额外详情的增强成就提示信息。"

    L["SERIESTIP"] = "系列成就的一部分"
    L["META_ACHIEVEMENT"] = "综合成就"

    L["CTXMENU_LINK_CHAT"] = "链接到聊天"
    L["CTXMENU_WATCH_ADD"] = "添加到关注列表"
    L["CTXMENU_WATCH_REMOVE"] = "从关注列表移除"
    L["CTXMENU_TRACK"] = "追踪成就"
    L["CTXMENU_UNTRACK"] = "取消追踪成就"
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

    L["OPT_NPC_TOOLTIP_TITLE"] = "啟用NPC提示資訊"
    L["OPT_NPC_TOOLTIP_DESC"] = "滑鼠懸停在NPC上時顯示成就進度。"

    L["OPT_ACH_TOOLTIP_TITLE"] = "啟用成就提示資訊"
    L["OPT_ACH_TOOLTIP_DESC"] = "顯示包含額外詳情的增強成就提示資訊。"

    L["SERIESTIP"] = "系列成就的一部分"
    L["META_ACHIEVEMENT"] = "綜合成就"

    L["CTXMENU_LINK_CHAT"] = "連結到聊天"
    L["CTXMENU_WATCH_ADD"] = "加入關注列表"
    L["CTXMENU_WATCH_REMOVE"] = "從關注列表移除"
    L["CTXMENU_TRACK"] = "追蹤成就"
    L["CTXMENU_UNTRACK"] = "取消追蹤成就"
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

    L["OPT_NPC_TOOLTIP_TITLE"] = "NPC-Tooltip aktivieren"
    L["OPT_NPC_TOOLTIP_DESC"] = "Erfolgsfortschritt anzeigen, wenn die Maus über einen NPC bewegt wird."

    L["OPT_ACH_TOOLTIP_TITLE"] = "Erfolgs-Tooltip aktivieren"
    L["OPT_ACH_TOOLTIP_DESC"] = "Erweiterte Erfolgs-Tooltips mit zusätzlichen Details anzeigen."

    L["SERIESTIP"] = "Teil einer Serie"
    L["META_ACHIEVEMENT"] = "Meta-Erfolg"

    L["CTXMENU_LINK_CHAT"] = "Im Chat verlinken"
    L["CTXMENU_WATCH_ADD"] = "Zur Beobachtungsliste hinzufügen"
    L["CTXMENU_WATCH_REMOVE"] = "Von Beobachtungsliste entfernen"
    L["CTXMENU_TRACK"] = "Erfolg verfolgen"
    L["CTXMENU_UNTRACK"] = "Erfolgsverfolgung aufheben"
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

    L["OPT_NPC_TOOLTIP_TITLE"] = "Activer l'infobulle PNJ"
    L["OPT_NPC_TOOLTIP_DESC"] = "Afficher la progression des hauts faits au survol des PNJ."

    L["OPT_ACH_TOOLTIP_TITLE"] = "Activer l'infobulle de haut fait"
    L["OPT_ACH_TOOLTIP_DESC"] = "Afficher des infobulles de hauts faits améliorées avec des détails supplémentaires."

    L["SERIESTIP"] = "Fait partie d'une série"
    L["META_ACHIEVEMENT"] = "Méta haut fait"

    L["CTXMENU_LINK_CHAT"] = "Lier dans le chat"
    L["CTXMENU_WATCH_ADD"] = "Ajouter à la liste de suivi"
    L["CTXMENU_WATCH_REMOVE"] = "Retirer de la liste de suivi"
    L["CTXMENU_TRACK"] = "Suivre le haut fait"
    L["CTXMENU_UNTRACK"] = "Ne plus suivre le haut fait"
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

    L["OPT_NPC_TOOLTIP_TITLE"] = "Включить подсказки для НПС"
    L["OPT_NPC_TOOLTIP_DESC"] = "Показывать прогресс достижений при наведении на НПС."

    L["OPT_ACH_TOOLTIP_TITLE"] = "Включить подсказки достижений"
    L["OPT_ACH_TOOLTIP_DESC"] = "Показывать расширенные подсказки достижений с дополнительными деталями."

    L["SERIESTIP"] = "Часть серии"
    L["META_ACHIEVEMENT"] = "Мета-достижение"

    L["CTXMENU_LINK_CHAT"] = "Ссылка в чат"
    L["CTXMENU_WATCH_ADD"] = "Добавить в список наблюдения"
    L["CTXMENU_WATCH_REMOVE"] = "Убрать из списка наблюдения"
    L["CTXMENU_TRACK"] = "Отслеживать достижение"
    L["CTXMENU_UNTRACK"] = "Прекратить отслеживание"
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

    L["OPT_NPC_TOOLTIP_TITLE"] = "Activar información emergente de PNJ"
    L["OPT_NPC_TOOLTIP_DESC"] = "Mostrar el progreso de logros al pasar el cursor sobre los PNJ."

    L["OPT_ACH_TOOLTIP_TITLE"] = "Activar información emergente de logros"
    L["OPT_ACH_TOOLTIP_DESC"] = "Mostrar información emergente mejorada de logros con detalles adicionales."

    L["SERIESTIP"] = "Parte de una serie"
    L["META_ACHIEVEMENT"] = "Meta-logro"

    L["CTXMENU_LINK_CHAT"] = "Enlazar en el chat"
    L["CTXMENU_WATCH_ADD"] = "Añadir a lista de seguimiento"
    L["CTXMENU_WATCH_REMOVE"] = "Quitar de lista de seguimiento"
    L["CTXMENU_TRACK"] = "Seguir logro"
    L["CTXMENU_UNTRACK"] = "Dejar de seguir logro"
end
