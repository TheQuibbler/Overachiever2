-- Overachiever2: Data

local _, ns = ...

ns.ACHID = {
    -- To All The Squirrels I've Loved Before series
    LoveCritters = 1206,
    LoveCritters2 = 2557,
    LoveCritters3 = 5548,
    LoveCritters4 = 6350,
    LoveCritters5 = 14728,
    LoveCritters6 = 14729,
    LoveCritters7 = 14730,
    LoveCritters8 = 14731,

    PestControl = 2556, -- Pest Control
    WellRead = 1244,    -- Well Read

    -- Gourmet Achievements
    GourmetOutland = 1800,
    GourmetNorthrend = 1779,
    GourmetCataclysm = 5473,
    GourmetPandaren = 7327,
    GourmetDraenor = 9501,
    GourmetLegion = 10762,

    -- Drinks
    HappyHour = 1833,
    DrownYourSorrows = 5754,
}

-- List of achievements to scan for items (Gourmet/Happy Hour)
ns.ItemAchievements = {
    ns.ACHID.GourmetOutland,
    ns.ACHID.GourmetNorthrend,
    ns.ACHID.GourmetCataclysm,
    ns.ACHID.GourmetPandaren,
    ns.ACHID.GourmetDraenor,
    ns.ACHID.GourmetLegion,
    ns.ACHID.HappyHour,
    ns.ACHID.DrownYourSorrows,
}

-- Critter names mapping to the meta achievement they belong to
-- In a real implementation, we'd have a full list.
-- For the first version, let's focus on the first "Love Critters"
ns.CritterAchievements = {
    ns.ACHID.LoveCritters,
    ns.ACHID.LoveCritters2,
    ns.ACHID.LoveCritters3,
    ns.ACHID.LoveCritters4,
    ns.ACHID.LoveCritters5,
    ns.ACHID.LoveCritters6,
    ns.ACHID.LoveCritters7,
    ns.ACHID.LoveCritters8,
}
