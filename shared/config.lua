Config = {}

Config.Framework = "qb" -- "qb" or "esx"

Config.ContainerStart = {
    anyPlayer = false, -- set to false if you want any player to start the container event from the npc (lecter house)
    gangBoss = false, -- set to true if you want only gang bosses to start the container event
    specificGangBoss = 'ballas', -- or set a gang name like 'godfather'
}

Config.Container = {
    Model = "tr_prop_tr_container_01a",
    Locations = {
        [1] = { id = 1, name = "Pacific Bluffs", coord = vector4(-2261.11, 314.5, 174.6, 120.0), radius = 120.0, showBlip = true },
        [2] = { id = 2, name = "La Puerta Farm", coord = vector4(1423.09, 1110.63, 114.47, 120.0), radius = 120.0, showBlip = true },
    }
}

Config.Reward = {
    items = {
        enabled = true, -- toggle item rewards
        list = {
            {
                item = "pistol_ammo",
                chance = 100, -- 100% guaranteed
                amount = { min = 1, max = 1 },
            },
            {
                item = "sandwich",
                chance = 50, -- 50% chance
                amount = { min = 1, max = 2 },
            },
        },
    },

    money = {
        enabled = true, -- easy toggle for debugging or balance tweaks
        type = "cash",  -- "cash" or "bank"
        min = 50,
        max = 200,
    },
}
