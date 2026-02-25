-- Overachiever2: Compatibility Layer

local _, ns = ...

-- Modern API aliases
ns.GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

-- Achievement API Wrap (Future-proofing against global removal)
ns.GetAchievementInfo = function(id)
    return GetAchievementInfo(id)
end

-- Safe wrapper for GetAchievementCriteriaInfo that doesn't throw errors
ns.GetAchievementCriteriaInfo = function(achievementID, index)
    local success, criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = pcall(GetAchievementCriteriaInfo, achievementID, index)
    if success then
        return criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString
    end
    print("!! Overachiever2: GetAchievementCriteriaInfo failed: achievement=" .. tostring(achievementID) .. ", index=" .. tostring(index))
    return nil
end
