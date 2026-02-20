-- Overachiever2: Compatibility Layer

local _, ns = ...

-- Modern API aliases
ns.GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

-- Achievement API Wrap (Future-proofing against global removal)
ns.GetAchievementInfo = function(id)
    return GetAchievementInfo(id)
end

ns.GetAchievementCriteriaInfo = function(id, criteria)
    return GetAchievementCriteriaInfo(id, criteria)
end
