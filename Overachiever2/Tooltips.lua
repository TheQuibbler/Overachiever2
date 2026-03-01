-- Overachiever2: Tooltips
-- Modern tooltip enhancement using TooltipDataProcessor

local _, ns = ...

local Utils = Overachiever2.Utils

local COLOR_COMPLETE = CreateColorFromHexString(Utils.BlizzardGreenColor)
local COLOR_INCOMPLETE = CreateColorFromHexString(Utils.BlizzardRedColor)
local COLOR_GRAY = CreateColorFromHexString(Utils.GrayColor)
local COLOR_ID = CreateColorFromHexString(Utils.WhiteColor)

-- Helper: Add a line with the achievement icon
local function AddAchievementLine(tooltip, match)
    local achName = match.achName
    local achStatusStr = match.achCompleted and Utils.CheckAtlasText() or Utils.RedxAtlasText()
    if Overachiever2_Settings.Debug then
        achName = achName .. " [achID: " .. match.achID .. "]"
    end
    tooltip:AddDoubleLine(Utils.AchievementIconText() .. " " .. Utils.BlizzardGoldText(achName), achStatusStr)

    -- The match result may not contain a valid criteria name.
    -- This means there's no valid criteria info. We don't display criteria info in this case.
    local critName = nil
    if match.criteriaString and match.criteriaString ~= "" then
        critName = match.criteriaString
    end
    if critName then
        critName = match.criteriaCompleted and Utils.WhiteText(critName) or Utils.GrayText(critName)
        critName = Utils.AchievementIconSpacerText() .. " " .. Utils.GrayText(Utils.DotIconText()) .. " " .. critName
        local critStatusStr = match.criteriaCompleted and Utils.CheckAtlasText() or Utils.RedxAtlasText()
        if Overachiever2_Settings.Debug then
            critName = critName .. " [critID: " .. match.criteriaID .. "]"
        end
        tooltip:AddDoubleLine(critName, critStatusStr)
    end
end

-- Helper: Add all criteria lines for an achievement
function ns.AddCriteriaLines(tooltip, achID)
    local numCriteria = GetAchievementNumCriteria(achID)
    if numCriteria == 0 then return end

    tooltip:AddLine(" ") -- Spacing

    local isSingleCriteria = numCriteria == 1
    local criteriaInfo = {} -- contains formatted lines to be added to tooltip
    local progressBarInfo = { enable = false, max = 0, value = 0, text = "" }
    local debugCriteriaInfo = {} -- contains all values of GetAchievementCriteriaInfo call

    for i = 1, numCriteria do
        local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = ns.GetAchievementCriteriaInfo(achID, i)

        -- If it's a single criteria achievement with a required quantity > 1, we should display a progress bar.
        -- E.g., "2500 World Quests Completed".
        if isSingleCriteria and reqQuantity > 1 then
            progressBarInfo.enable = true
            progressBarInfo.max = reqQuantity
            progressBarInfo.value = quantity
            progressBarInfo.text = quantityString
        end

        if criteriaString and (criteriaString ~= "") then
            local color = completed and COLOR_COMPLETE or COLOR_INCOMPLETE
            local text = criteriaString
            local statusIcon = completed and (" " .. Utils.CheckAtlasText()) or (" " .. Utils.RedxAtlasText())
            table.insert(criteriaInfo, { text = text .. statusIcon, color = color })
        end

        if Overachiever2_Settings.Debug then
            local debugLine = string.format("[%d]: 1=%s, 2=%s, 3=%s, 4=%s, 5=%s, 6=%s, 7=%s, 8=%s, 9=%s",
                i,
                Utils.ColorByType(criteriaString),
                Utils.ColorByType(criteriaType),
                Utils.ColorByType(completed),
                Utils.ColorByType(quantity),
                Utils.ColorByType(reqQuantity),
                Utils.ColorByType(charName),
                Utils.ColorByType(flags),
                Utils.ColorByType(assetID),
                Utils.ColorByType(quantityString)
            )
            table.insert(debugCriteriaInfo, debugLine)
        end
    end

    -- Display criteria in two columns
    for i = 1, #criteriaInfo, 2 do
        local left = criteriaInfo[i]
        local right = criteriaInfo[i+1]
        local lr, lg, lb = left.color:GetRGB()
        if right then
            local rr, rg, rb = right.color:GetRGB()
            tooltip:AddDoubleLine(left.text, right.text, lr, lg, lb, rr, rg, rb)
        else
            tooltip:AddLine(left.text, lr, lg, lb)
        end
    end

    -- Add progress bar
    if progressBarInfo.enable then
        GameTooltip_ShowStatusBar(tooltip, 0, progressBarInfo.max, progressBarInfo.value, progressBarInfo.text);
    end

    -- Display debug info for criteria
    if Overachiever2_Settings.Debug and #debugCriteriaInfo > 0 then
        tooltip:AddLine(" ")
        tooltip:AddLine(Utils.DebugIconText() .. " " .. Utils.BlizzardGreenText("Criteria Debug Info"), 1, 1, 1)
        tooltip:AddLine(Utils.DarkGrayText("1=criteriaString, 2=criteriaType, 3=completed, 4=quantity, 5=reqQuantity, 6=charName, 7=flags, 8=assetID, 9=quantityString"), 1, 1, 1)
        for _, line in ipairs(debugCriteriaInfo) do
            tooltip:AddLine(line, 0.7, 0.7, 0.7, false) -- false = don't wrap lines
        end
    end
end

-- 1. Unit Tooltips (Critters, etc.)
local function OnTooltipSetUnit(tooltip, data)
    local _, unit = tooltip:GetUnit() -- returns "{name}", "mouseover"

    -- Players don't have NPC achievements, so early return.
    -- UnitIsPlayer can fail with "secret values" error inside securecallfunction (12.0+)
    if not unit then return end
    local okP, isPlayer = pcall(UnitIsPlayer, unit)
    if okP and isPlayer then return end

    if Overachiever2_Settings.EnableNPCTooltip then
        local matches = ns.GetUnitAchievements(unit)
        for _, match in ipairs(matches) do
            AddAchievementLine(tooltip, match)
        end
    end

    -- Show NPC ID if available (Debug Mode Only)
    local ok, guid = pcall(UnitGUID, unit)
    if not ok then return end
    local npcID = ns.GetIDFromGUID(guid)
    if Overachiever2_Settings.Debug and npcID then
        local r, g, b = COLOR_ID:GetRGB()
        tooltip:AddLine(" ") -- Spacing
        tooltip:AddDoubleLine(Utils.DebugIconText() .. " " .. Utils.BlizzardGreenText("NPC ID"), npcID, nil, nil, nil, r, g, b)
    end
end

-- 2. Item Tooltips (Food, Drink, etc.)
local function OnTooltipSetItem(tooltip, data)
    local itemID = data.id
    if not itemID then return end

    local itemName = GetItemInfo(itemID)
    local matches = ns.GetItemAchievements(itemID, itemName)
    for _, match in ipairs(matches) do
        AddAchievementLine(tooltip, match)
    end

    -- Show Item ID (Debug Mode Only)
    if Overachiever2_Settings.Debug then
        local r, g, b = COLOR_ID:GetRGB()
        tooltip:AddDoubleLine(Utils.DebugIconText() .. " " .. Utils.BlizzardGreenText("Item ID"), itemID, nil, nil, nil, r, g, b)
    end
end

-- 3. Achievement Tooltips (Links in chat)
local function OnTooltipSetAchievement(tooltip, data)
    if not Overachiever2_Settings.EnableAchievementTooltip then return end

    local achID = data.id
    if not achID then return end

    -- Clear existing lines built by Blizzard
    tooltip:ClearLines()

    -- Achievement Name
    local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(achID)
    local achievementName = Utils.AchievementIconText() .. " " .. (name or "???")
    local completeness = ""
    if completed then
        local completionDate = FormatShortDate(day, month, year)
        if earnedBy and (earnedBy ~= "") then
            completionDate = completionDate .. " - " .. earnedBy
        end
        completeness = Utils.BlizzardGreenText(_G.ACHIEVEMENT_UNLOCKED .. " " .. completionDate)
    else
        completeness = Utils.GrayText(_G.IN_PROGRESS)
    end
    if Overachiever2_Settings.Debug then
        -- Append an achievement ID to the achievement name
        achievementName = achievementName .. " (" .. Utils.DebugIconText() .. Utils.BlizzardGreenText("Achievement ID:") .. " " .. achID .. ")"
    end
    tooltip:AddLine(achievementName)
    tooltip:AddLine(completeness)

    -- Description
    tooltip:AddLine(" ") -- Spacing
    local r, g, b = COLOR_ID:GetRGB()
    tooltip:AddLine(description, r, g, b, true)

    -- Display debug info for achievement
    if Overachiever2_Settings.Debug then
        tooltip:AddLine(" ") -- Spacing
        tooltip:AddLine(Utils.DebugIconText() .. " " .. Utils.BlizzardGreenText("Achievement Debug Info"), 1, 1, 1)
        tooltip:AddLine(Utils.DarkGrayText("1=id, 2=name, 3=points, 4=completed, 5=month, 6=day, 7=year, 8=description, 9=flags, 10=icon, 11=rewardText, 12=isGuild, 13=wasEarnedByMe, 14=earnedBy"), 1, 1, 1)
        local debugLine = string.format("1=%s, 2=%s, 3=%s, 4=%s, 5=%s, 6=%s, 7=%s, 8=%s, 9=%s, 10=%s, 11=%s, 12=%s, 13=%s, 14=%s",
            Utils.ColorByType(achID),
            Utils.ColorByType(name),
            Utils.ColorByType(points),
            Utils.ColorByType(completed),
            Utils.ColorByType(month),
            Utils.ColorByType(day),
            Utils.ColorByType(year),
            Utils.ColorByType(description),
            Utils.ColorByType(flags),
            Utils.ColorByType(icon),
            Utils.ColorByType(rewardText),
            Utils.ColorByType(isGuild),
            Utils.ColorByType(wasEarnedByMe),
            Utils.ColorByType(earnedBy)
        )
        tooltip:AddLine(debugLine, 0.7, 0.7, 0.7, false) -- false = don't wrap lines
    end

    -- Criteria
    ns.AddCriteriaLines(tooltip, achID)

    -- Series
    if GetNextAchievement(achID) or GetPreviousAchievement(achID) then
        tooltip:AddLine(" ") -- Spacing
        tooltip:AddLine(ns.L["SERIESTIP"])
        local curAchID = GetPreviousAchievement(achID)
        local first
        while (curAchID) do  -- Find first achievement in the series:
            first = curAchID
            curAchID = GetPreviousAchievement(curAchID)
        end
        curAchID = first or achID
        local curCompleted = select(4, GetAchievementInfo(curAchID))
        local curAchNum = 1
        while (curAchID) do
            local _, curAchName = GetAchievementInfo(curAchID)
            local color;
            curAchName = curAchNum .. ". " .. curAchName
            if (curAchID == achID) then
                color = COLOR_ID
            elseif (curCompleted) then
                color = COLOR_COMPLETE
            else
                color = COLOR_GRAY
            end

            if curCompleted then
                curAchName = curAchName .. " " .. Utils.CheckAtlasText()
            end

            local r, g, b = color:GetRGB()
            tooltip:AddLine(curAchName, r, g, b, false) -- false = don't wrap lines
            curAchID, curCompleted = GetNextAchievement(curAchID)
            curAchNum = curAchNum + 1
        end
    end

    -- Criteria of
    local entries = ns.DB.Meta[achID]
    if entries then
        tooltip:AddLine(" ") -- Spacing
        tooltip:AddLine(ns.L["CRITERIA_OF"])
        for _, parentAchID in ipairs(entries) do
            local _, name, _, completed = GetAchievementInfo(parentAchID)
            local color;
            if (completed) then
                color = COLOR_COMPLETE
                name = name .. " " .. Utils.CheckAtlasText()
            else
                color = COLOR_GRAY
            end

            name = Utils.DotIconText() .. " " .. name

            local r, g, b = color:GetRGB()
            tooltip:AddLine(name, r, g, b, false) -- false = don't wrap lines
        end
    end

    -- Reward
    if rewardText and rewardText ~= "" then
        tooltip:AddLine(" ") -- Spacing
        tooltip:AddLine(rewardText)
    end

    -- Add ID to tooltip (like original ShowID option, Debug Mode Only)
    if Overachiever2_Settings.Debug then
        tooltip:AddLine(" ") -- Spacing
        tooltip:AddDoubleLine(Utils.DebugIconText() .. " " .. Utils.BlizzardGreenText("Achievement ID"), tostring(achID), nil, nil, nil, r, g, b)
        local categoryID = GetAchievementCategory(achID)
        tooltip:AddDoubleLine(Utils.DebugIconText() .. " " .. Utils.BlizzardGreenText("Category ID"), tostring(categoryID), nil, nil, nil, r, g, b)
    end
end

-- Register hooks for modern WoW (10.0.2+)
if TooltipDataProcessor then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Achievement, OnTooltipSetAchievement)
end

-- 4. Achievement Category Tooltips (Achievement UI Side Menu)
-- These don't use TooltipDataProcessor, so we hook the Blizzard function directly.

local function HookCategoryTooltips()
    local function addonHook(button)
        if not Overachiever2_Settings.Debug then return end
        -- categoryID is set on the parent frame (AchievementCategoryTemplate)
        local frame = button:GetParent()
        local id = button.categoryID or (frame and frame.categoryID)

        if id then
            local r, g, b = COLOR_ID:GetRGB()
            GameTooltip:AddLine(" ") -- Spacing
            GameTooltip:AddDoubleLine(Utils.DebugIconText() .. " " .. Utils.BlizzardGreenText("Category ID"), tostring(id), nil, nil, nil, r, g, b)
            GameTooltip:Show()
        end
    end

    if AchievementFrameCategory_StatusBarTooltip then
        hooksecurefunc("AchievementFrameCategory_StatusBarTooltip", addonHook)
    end
    if AchievementFrameCategory_FeatOfStrengthTooltip then
        hooksecurefunc("AchievementFrameCategory_FeatOfStrengthTooltip", addonHook)
    end
end

-- 5. Main Achievement List Tooltips
local function OnAchievementListEnter(self)
    if not Overachiever2_Settings.EnableAchievementTooltip then return end

    local achID = self.id
    if not achID then return end

    -- if DevTool and Overachiever2_Settings.Debug then
    --     DevTool:AddData(self, "OA2 Ach: " .. self.Label:GetText())
    -- end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

    -- this raises `Enum.TooltipDataType.Achievement` event, so `OnTooltipSetAchievement` is called.
    GameTooltip:SetAchievementByID(achID)

    if Overachiever2_Settings.Debug then
        GameTooltip:AddLine(" ") -- Spacing
        local r, g, b = COLOR_ID:GetRGB()
        GameTooltip:AddDoubleLine(Utils.DebugIconText() .. " " .. Utils.BlizzardGreenText("List Index"), tostring(self.index), nil, nil, nil, r, g, b)
    end

    GameTooltip:Show()
end

local function OnAchievementListLeave(self)
    GameTooltip:Hide()
end

local function HookAchievementList()
    if AchievementTemplateMixin then
        hooksecurefunc(AchievementTemplateMixin, "OnEnter", OnAchievementListEnter)
        hooksecurefunc(AchievementTemplateMixin, "OnLeave", OnAchievementListLeave)
    end
end

-- 6. Meta Achievement Objective Tooltips (sub-achievements inside expanded objectives)
local function OnMetaCriteriaEnter(self)
    local achID = self.id
    if not achID then return end

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetAchievementByID(achID)
    GameTooltip:Show()
end

local function OnMetaCriteriaLeave(self)
    GameTooltip:Hide()
end

local function HookMetaCriteria()
    if AchievementMetaCriteriaMixin then
        hooksecurefunc(AchievementMetaCriteriaMixin, "OnEnter", OnMetaCriteriaEnter)
        hooksecurefunc(AchievementMetaCriteriaMixin, "OnLeave", OnMetaCriteriaLeave)
    end
end

-- 7. Tracked Achievement Objective Tooltips (right-side objective tracker)
-- Hook the HeaderButton's OnEnter/OnLeave (ObjectiveTrackerBlockHeaderMixin).
-- The HeaderButton is the invisible button covering the achievement name text.
local function OnTrackedAchievementHeaderEnter(headerButton)
    local block = headerButton:GetParent()
    -- Only handle achievement blocks; quest, bonus objective, and other tracker blocks are ignored.
    if not block.parentModule or block.parentModule ~= AchievementObjectiveTracker then return end

    local achID = block.id
    if not achID then return end

    GameTooltip:ClearAllPoints()
    GameTooltip:SetPoint("TOPRIGHT", block, "TOPLEFT", 0, 0)
    GameTooltip:SetOwner(block, "ANCHOR_PRESERVE")
    GameTooltip:SetAchievementByID(achID)
    GameTooltip:Show()
end

local function OnTrackedAchievementHeaderLeave(headerButton)
    local block = headerButton:GetParent()
    if not block.parentModule or block.parentModule ~= AchievementObjectiveTracker then return end
    GameTooltip:Hide()
end

local function HookTrackedAchievements()
    if ObjectiveTrackerBlockHeaderMixin then
        hooksecurefunc(ObjectiveTrackerBlockHeaderMixin, "OnEnter", OnTrackedAchievementHeaderEnter)
        hooksecurefunc(ObjectiveTrackerBlockHeaderMixin, "OnLeave", OnTrackedAchievementHeaderLeave)
    end
end

local function HookAllAchievementUI()
    HookCategoryTooltips()
    HookAchievementList()
    HookMetaCriteria()
    HookTrackedAchievements()
end

if C_AddOns.IsAddOnLoaded("Blizzard_AchievementUI") then
    HookAllAchievementUI()
else
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")
    f:SetScript("OnEvent", function(self, event, addonName)
        if addonName == "Blizzard_AchievementUI" then
            HookAllAchievementUI()
            self:UnregisterAllEvents()
        end
    end)
end
