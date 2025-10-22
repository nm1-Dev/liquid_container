local containerEntity = nil
local containerSpawned = false
local blip = nil
---------------------------------------
-- When player joins, ask for the container
---------------------------------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    TriggerServerEvent('liquid_container:server:RequestOrSpawn')
end)

---------------------------------------
-- When the server sends us the container NetID
---------------------------------------
RegisterNetEvent('liquid_container:client:SpawnObject', function(netId, zone)
    print_r(zone)

    -- local obj = NetToObj(netId)
    -- local timeout = GetGameTimer() + 5000

    -- while not DoesEntityExist(obj) and GetGameTimer() < timeout do
    --     Wait(100)
    --     obj = NetToObj(netId)
    -- end

    -- if not DoesEntityExist(obj) then
    --     print('[Liquid] Warning: container entity not found after 5s.')
    --     return
    -- end

    -- containerEntity = obj
    -- FreezeEntityPosition(containerEntity, true)
    -- SetEntityInvincible(containerEntity, true)

    -- ---------------------------------------
    -- --  Add blips
    -- ---------------------------------------
    -- blip = AddBlipForRadius(coords.x, coords.y, coords.z, 350.0)
    -- SetBlipColour(blip, 1)
    -- SetBlipAlpha(blip, 128)
    -- print('[Liquid] Container blip added.')

    -- exports['qb-target']:AddTargetEntity(containerEntity, {
    --     options = {
    --         {
    --             icon = "fas fa-box",
    --             label = "Open Container",
    --             action = function(entity)
    --                 print('[Liquid] Container opened. ==> ' .. entity)
    --                 OpenContainer(entity)
    --             end,
    --         },
    --     },
    --     distance = 2.5,
    -- })
end)

---------------------------------------
-- laptop
---------------------------------------
RegisterNetEvent('liquid_container:client:OpenLapTop', function()
    openUI()
end)

CreateThread(function()
    exports.interact:AddInteraction({
        coords = vector3(1276.61, -1710.27, 54.81),
        distance = 5.0,           -- optional
        interactDst = 2.0,        -- optional
        id = 'liquid_container',    -- needed for removing interactions
        options = {
            {
                label = 'Boot up System',
                action = function(entity, coords, args)
                    openUI()
                end,
            },
        }
    })
end)

local rewards = {
  { icon = "fa-gun",   label = "Random Weapon" },
  { icon = "fa-coins", label = "Cash & Ammo" },
}

function openUI()
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "open",
        zones = Config.Container.Locations,
        rewards = rewards
    })
end

RegisterNUICallback('closeUI', function(_, cb)
  SetNuiFocus(false, false)
  SendNUIMessage({ type = "close" })
  cb({ ok = true })
end)

RegisterNUICallback('startContainerWar', function(data, cb)
    local zone = Config.Container.Locations[tonumber(data.zoneId or 1)]
    print_r(zone)
    if zone then
        TriggerServerEvent('liquid_container:server:startContainer', zone.id)
    end
    cb({ ok = true })
end)

-- RegisterNetEvent('liquid_container:client:SpawnObject', function()

-- end)


---------------------------------------
-- Cleanup if resource stops
---------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    exports.interact:RemoveInteraction('liquid_container')
    if containerEntity and DoesEntityExist(containerEntity) then
        DeleteEntity(containerEntity)
    end
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end)