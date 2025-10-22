Config = {}

Config.Framework = "qb" -- "qb" or "esx"

Config.ContainerStart = {
    anyPlayer = false,           -- set to false if you want any player to start the container event from the npc (lecter house)
    gangBoss = false,            -- set to true if you want only gang bosses to start the container event
    specificGangBoss = 'ballas', -- or set a gang name like 'godfather'
}

Config.TimeBetweenContainers = 10 -- in minutes

Config.Container = {
    Model = "tr_prop_tr_container_01a",
    Locations = {
        [1] = {
            id = 1,
            name = "Merryweather Dock",
            coord = vector4(2206.86, 5591.48, 53.81, 157.38),
            radius = 150.0,
            showBlip = true,
            npc = {
                [1] = {
                    pos = vector4(2223.769, 5604.547, 54.719, 108.38),
                    model ='g_f_y_vagos_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
                [2] = {
                    pos = vector4(2202.253, 5605.660, 53.697, 217.77),
                    model ='g_f_importexport_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
                [3] = {
                    pos = vector4(2197.329, 5585.471, 53.814, 294.16),
                    model ='g_m_y_salvagoon_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
                [4] = {
                    pos = vector4(2198.070, 5569.223, 53.870, 326.07),
                    model ='g_m_y_mexgoon_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
                [5] = {
                    pos = vector4(2214.575, 5561.529, 53.909, 42.78),
                    model ='g_m_y_pologoon_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
                [6] = {
                    pos = vector4(2235.117, 5587.979, 53.951, 74.92),
                    model ='g_m_y_ballasout_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
                [7] = {
                    pos = vector4(2220.310, 5622.069, 54.484, 153.70),
                    model ='g_m_y_famca_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
                [8] = {
                    pos = vector4(2219.637, 5628.614, 55.675, 167.86),
                    model ='g_m_y_famdnf_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
                [9] = {
                    pos = vector4(2192.858, 5597.632, 53.753, 57.68),
                    model ='g_m_y_famfor_01',
                    weapon = 'WEAPON_PISTOL_MK2',
                    health = 3000,
                    accuracy = 60,
                    alertness = 3,
                    aggressiveness = 3,
                },
            }
        },
        -- [2] = {
        --     id = 2,
        --     name = "Pacific Bluffs",
        --     coord = vector4(-2261.11, 314.5, 174.6, 120.0),
        --     radius = 120.0,
        --     showBlip = true,
        --     npc = {} -- no NPCs here yet
        -- },
        -- [3] = {
        --     id = 3,
        --     name = "La Puerta Farm",
        --     coord = vector4(1423.09, 1110.63, 114.47, 120.0),
        --     radius = 120.0,
        --     showBlip = true,
        --     npc = {} -- no NPCs here yet
        -- }
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
