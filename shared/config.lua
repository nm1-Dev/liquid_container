Config = {}

Config.Framework = "qb" -- "qb" or "esx"

Config.SpawnTime = 1

Config.Container = {
    Model = "tr_prop_tr_container_01a",
    randomCoords = {
        vector4(-2347.33, 3051.14, 32.82, 19.62),
        vector4(-2345.36, 3047.58, 32.82, 112.91)
    }
}

Config.Reward = {
    items = {
        enabled = true,
        list = { "water_bottle", "sandwich", "cola", "coffee" },
        min = 1,   -- minimum amount per item
        max = 3,   -- maximum amount per item
    },

    money = {
        enabled = true,       -- easy toggle for debugging or balance tweaks
        type = "cash",        -- "cash" or "bank"
        min = 50,
        max = 200,
    },
}