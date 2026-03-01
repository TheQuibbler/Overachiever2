-- Overachiever2: Compatibility Layer

local _, ns = ...

local Utils = Overachiever2.Utils

-- Modern API aliases
ns.GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

-- Achievement API Wrap (Future-proofing against global removal)
ns.GetAchievementInfo = function(id)
    return GetAchievementInfo(id)
end

-- Safe wrapper for GetAchievementCriteriaInfo that doesn't throw errors
ns.GetAchievementCriteriaInfo = function(achievementID, index)
    local ok, criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = pcall(GetAchievementCriteriaInfo, achievementID, index)
    if ok then
        return criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString
    end
    if Overachiever2_Settings.Debug then
        print(Utils.RedText("OA2: GetAchievementCriteriaInfo failed:") .. " achID=" .. tostring(achievementID) .. ", index=" .. tostring(index))
    end
    return nil
end

-- Safe wrapper for GetAchievementCriteriaInfoByID that doesn't throw errors
ns.GetAchievementCriteriaInfoByID = function(achievementID, criteriaID)
    local ok, criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = pcall(GetAchievementCriteriaInfoByID, achievementID, criteriaID)
    if ok then
        return criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString
    end
    if Overachiever2_Settings.Debug then
        print(Utils.RedText("OA2: GetAchievementCriteriaInfoByID failed:") .. " achID=" .. tostring(achievementID) .. ", critID=" .. tostring(criteriaID))
    end
    return nil
end
