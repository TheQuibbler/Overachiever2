-- Overachiever2_Tabs: ContextMenu
-- Achievement-specific context menu provider registry and hooks.
-- Depends on Overachiever2.ContextMenu (generic utility) for menu rendering.

local _, ns = ...

local Overachiever2 = _G["Overachiever2"]
local Utils = Overachiever2 and Overachiever2.Utils
local OA2_L = Overachiever2 and Overachiever2.L

---------------------------------------------------------------------------
-- Achievement-specific provider registry
---------------------------------------------------------------------------

local providers = {}

-- Register a provider: function(achievementID) -> items table (or nil).
-- All registered providers are merged when an achievement is right-clicked.
ns.ContextMenu = {}

function ns.ContextMenu.RegisterAchievementProvider(callback)
    table.insert(providers, callback)
end

-- Collect items from all providers and show the unified menu.
function ns.ContextMenu.ShowForAchievement(achievementID, ownerButton)
    local allItems = {}
    for _, provider in ipairs(providers) do
        local items = provider(achievementID)
        if items then
            if #allItems > 0 then
                table.insert(allItems, { separator = true })
            end
            for _, item in ipairs(items) do
                table.insert(allItems, item)
            end
        end
    end
    if #allItems > 0 then
        Overachiever2.ContextMenu.Show(ownerButton, allItems, { id = achievementID })
    end
end

---------------------------------------------------------------------------
-- Default achievement menu provider
---------------------------------------------------------------------------

local function IsTrackingAchievement(ctx)
    return C_ContentTracking.IsTracking(Enum.ContentTrackingType.Achievement, ctx.id)
end

local function IsAchievementIncomplete(ctx)
    local _, _, _, completed = GetAchievementInfo(ctx.id)
    return not completed
end

ns.ContextMenu.RegisterAchievementProvider(function(achievementID)
    local _, name = GetAchievementInfo(achievementID)
    return {
        -- Title (always visible)
        {
            title = Utils.AchievementIconText() .. " " .. name,
        },
        -- Link to Chat (always visible)
        {
            text = OA2_L["CTXMENU_LINK_CHAT"],
            onClick = function(ctx)
                local link = GetAchievementLink(ctx.id)
                if link then
                    local editBox = ChatFrame1EditBox
                    if editBox then
                        if not editBox:IsShown() then
                            -- Edit box is closed: open fresh with the link
                            ChatFrame_OpenChat(link)
                        else
                            -- Edit box is already open: insert without replacing
                            editBox:Insert(link)
                        end
                        editBox:SetFocus()
                    end
                end
            end,
        },
        -- Add to/Remove from Watch List (always visible)
        { separator = true },
        {
            text = OA2_L["CTXMENU_WATCH_ADD"],
            visible = function() return not ns.IsWatchTabShown or not ns.IsWatchTabShown() end,
            onClick = function(ctx)
                if ns.AddToWatchList then
                    ns.AddToWatchList(ctx.id)
                end
            end,
        },
        {
            text = OA2_L["CTXMENU_WATCH_REMOVE"],
            visible = function() return ns.IsWatchTabShown and ns.IsWatchTabShown() end,
            onClick = function(ctx)
                if ns.RemoveFromWatchList then
                    ns.RemoveFromWatchList(ctx.id)
                end
            end,
        },
        -- Track/Untrack Achievement toggle (visible for incomplete achievements)
        {
            text = OA2_L["CTXMENU_TRACK"],
            visible = function(ctx) return IsAchievementIncomplete(ctx) and not IsTrackingAchievement(ctx) end,
            onClick = function(ctx)
                C_ContentTracking.StartTracking(Enum.ContentTrackingType.Achievement, ctx.id)
            end,
        },
        {
            text = OA2_L["CTXMENU_UNTRACK"],
            visible = function(ctx) return IsAchievementIncomplete(ctx) and IsTrackingAchievement(ctx) end,
            onClick = function(ctx)
                C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, ctx.id, Enum.ContentTrackingStopType.Manual)
            end,
        },

    }
end)

---------------------------------------------------------------------------
-- Achievement series provider
---------------------------------------------------------------------------

ns.ContextMenu.RegisterAchievementProvider(function(achievementID)
    -- Check if this achievement is part of a series
    if not GetNextAchievement(achievementID) and not GetPreviousAchievement(achievementID) then
        return nil
    end

    -- Walk back to find the first achievement in the series
    local first = achievementID
    local prev = GetPreviousAchievement(achievementID)
    while prev do
        first = prev
        prev = GetPreviousAchievement(first)
    end

    -- Build the list (current achievement shown as disabled)
    local items = {}
    local cur = first
    while cur do
        local _, name, _, completed = GetAchievementInfo(cur)
        if name then
            local label = name
            if completed then
                label = label .. " " .. Utils.CheckAtlasText()
            end
            local isCurrent = (cur == achievementID)
            local clickID = cur
            table.insert(items, {
                text = isCurrent and ("> " .. label) or label,
                disabled = isCurrent and function() return true end or nil,
                onClick = not isCurrent and function()
                    if AchievementFrame_SelectAchievement then
                        AchievementFrame_SelectAchievement(clickID)
                    end
                end or nil,
            })
        end
        cur = GetNextAchievement(cur)
    end

    if #items == 0 then return nil end

    if #items == 1 then
        return {
            { title = OA2_L["SERIESTIP"] },
            items[1],
        }
    else
        return {
            {
                text = OA2_L["SERIESTIP"],
                children = items,
            },
        }
    end
end)

---------------------------------------------------------------------------
-- Parent (meta) achievements provider
---------------------------------------------------------------------------

ns.ContextMenu.RegisterAchievementProvider(function(achievementID)
    local metaDB = Overachiever2.DB and Overachiever2.DB.Meta
    if not metaDB then return nil end

    local parents = metaDB[achievementID]
    if not parents or #parents == 0 then return nil end

    local items = {}
    for _, parentID in ipairs(parents) do
        local _, name = GetAchievementInfo(parentID)
        if name then
            table.insert(items, {
                text = name,
                onClick = function()
                    if AchievementFrame_SelectAchievement then
                        AchievementFrame_SelectAchievement(parentID)
                    end
                end,
            })
        end
    end

    if #items == 0 then return nil end

    if #items == 1 then
        -- Single parent: show as a direct button
        return {
            { title = OA2_L["META_ACHIEVEMENT"] },
            items[1],
        }
    else
        -- Multiple parents: show as a submenu
        return {
            {
                text = OA2_L["META_ACHIEVEMENT"],
                children = items,
            },
        }
    end
end)

---------------------------------------------------------------------------
-- Hook: Blizzard's first tab (AchievementTemplateMixin.ProcessClick)
---------------------------------------------------------------------------

if AchievementTemplateMixin then
    -- Blizzard's buttons only register LeftButtonUp by default.
    -- Hook Init to also register RightButtonUp so OnClick fires for right-clicks.
    local orig_Init = AchievementTemplateMixin.Init
    AchievementTemplateMixin.Init = function(self, ...)
        orig_Init(self, ...)
        self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    end

    -- Intercept right-clicks to show the context menu.
    local orig_ProcessClick = AchievementTemplateMixin.ProcessClick
    AchievementTemplateMixin.ProcessClick = function(self, buttonName, down)
        if self.id and buttonName == "RightButton" then
            ns.ContextMenu.ShowForAchievement(self.id, self)
            return
        end
        return orig_ProcessClick(self, buttonName, down)
    end
end