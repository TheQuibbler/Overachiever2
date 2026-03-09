-- Overachiever2: SessionState
-- Purpose: Track the current AchievementFrame selection for the current session so the addon can restore the last-viewed category/achievement when the frame is re-opened. 
-- This file keeps minimal, in-memory state only, nothing is persisted between game sessions.

local addonName, ns = ...

-- ==========================================================================
-- Locals / cached UI state
-- ==========================================================================

-- Cached values kept up-to-date by hooks so callers can read the selection even when Blizzard getter functions are unavailable or return nil/0.
local cachedCategoryID

-- ==========================================================================
-- Cache update handlers (hooked to Blizzard UI element selection)
-- ==========================================================================

-- Update cached category selection. When the category changes we clear the cached achievement to avoid carrying a stale achievement id across categories.
local function CacheCategorySelection(elementData)
    local newID
    if elementData and elementData.id and elementData.id ~= "summary" then
        newID = elementData.id
    elseif elementData and elementData.id == "summary" then
        newID = "summary"
    end
    if newID and newID ~= cachedCategoryID then
        cachedCategoryID = newID
    end
end


-- ==========================================================================
-- Getters: prefer cached values, fall back to guarded Blizzard getters
-- ==========================================================================
local function GetCategoryID()
    if cachedCategoryID then
        return cachedCategoryID
    end
    if AchievementFrameCategories and AchievementFrameCategories.GetSelectedCategory then
        local ok, id = pcall(AchievementFrameCategories.GetSelectedCategory, AchievementFrameCategories)
        if ok and id and id ~= 0 then
            return id
        end
    end
    return nil
end

local function GetAchievementID()
    if AchievementFrameAchievements and AchievementFrameAchievements.GetSelectedAchievement then
        local ok, id = pcall(AchievementFrameAchievements.GetSelectedAchievement, AchievementFrameAchievements)
        if ok and id and id ~= 0 then
            return id
        end
    end
    return nil
end


-- ==========================================================================
-- State capture / restore
-- CaptureState: take a snapshot of the current selection (called on hide).
-- RestoreSavedState: reapply the saved selection when the frame is shown.
-- ==========================================================================
local state = {
    categoryID = nil,
    achievementID = nil,
}

local function CaptureState()
    state.categoryID = GetCategoryID()
    state.achievementID = GetAchievementID()
end

local function RestoreSavedState()
    if Overachiever2_Settings and Overachiever2_Settings.DisableSessionState then
        return
    end
    if state.achievementID and AchievementFrame_SelectAchievement then
        pcall(AchievementFrame_SelectAchievement, state.achievementID)
    end
    if state.categoryID and AchievementFrame_UpdateAndSelectCategory then
        pcall(AchievementFrame_UpdateAndSelectCategory, state.categoryID)
    end
end

-- ==========================================================================
-- Hooks
-- Hook small handlers into the Blizzard UI to keep caches and saved state synchronized with user interaction.
-- ==========================================================================

local function OnAchievementShow()
    RestoreSavedState()
end

local function OnAchievementHide()
    CaptureState()
end

local hooksInstalled = false
local function InstallHooks()
    if hooksInstalled or not AchievementFrame then
        return
    end
    if Overachiever2_Settings and Overachiever2_Settings.DisableSessionState then
        return
    end
    hooksInstalled = true

    AchievementFrame:HookScript("OnShow", OnAchievementShow)
    AchievementFrame:HookScript("OnHide", OnAchievementHide)

    hooksecurefunc("AchievementFrameCategories_SelectElementData", CacheCategorySelection)
end

-- ==========================================================================
-- Initialization
-- Register loader and install hooks once the Blizzard Achievement UI is available.
-- ==========================================================================

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and (arg1 == addonName or arg1 == "Blizzard_AchievementUI") then
        InstallHooks()
    end
end)

if C_AddOns and C_AddOns.IsAddOnLoaded then
    if C_AddOns.IsAddOnLoaded("Blizzard_AchievementUI") then
        InstallHooks()
    end
end

-- Export the in-memory session state for other modules to query.
ns.SessionState = state
