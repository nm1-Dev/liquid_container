local containerId = nil
local containerCoords = nil
local isSpawned = false
local busy = false

-- RegisterNetEvent('liquid_container:server:SpawnToServer', function()
--     local src = source
--     if containerId then
--         print(('[Liquid] %s requested spawn but container already exists.'):format(GetPlayerName(src)))
--         return
--     end
--     if containerSpawned then
--         print(('[Liquid] %s requested spawn but container is already being spawned.'):format(GetPlayerName(src)))
--         return
--     end

--     ---------------------------------------
--     -- Spawn container
--     ---------------------------------------
--     local coords = Config.Container.randomCoords[math.random(1, #Config.Container.randomCoords)]
--     local model = GetHashKey(Config.Container.Model)

--     local obj = CreateObject(model, coords.x, coords.y, coords.z - 1.0, true, true, false)
--     SetEntityHeading(obj, coords.w)
--     FreezeEntityPosition(obj, true)
--     Wait(200)
--     containerId = NetworkGetNetworkIdFromEntity(obj)
--     containerCoords = coords
--     containerSpawned = true
--     print(('[Liquid] Container spawned on server. NetID: %s'):format(containerId))

--     ---------------------------------------
--     -- Sync to all current players
--     ---------------------------------------
--     TriggerClientEvent('liquid_container:client:ReceiveContainer', -1, containerId, containerCoords)
-- end)

RegisterNetEvent('liquid_container:server:RequestOrSpawn', function()
    local src = source

    -- if it already exists, just sync to this player
    if containerId and isSpawned then
        TriggerClientEvent('liquid_container:client:ReceiveContainer', src, containerId, containerCoords)
        return
    end

    -- lock immediately to avoid races when multiple players join together
    isSpawned = true

    -- pick coords and create once
    local coords = Config.Container.randomCoords[math.random(1, #Config.Container.randomCoords)]
    local model  = GetHashKey(Config.Container.Model)

    local obj = CreateObject(model, coords.x, coords.y, coords.z - 1.0, true, true, false)
    SetEntityHeading(obj, coords.w)
    FreezeEntityPosition(obj, true)
    Wait(200)

    containerId     = NetworkGetNetworkIdFromEntity(obj)
    containerCoords = coords

    print(('[Liquid] Container spawned on server. NetID: %s'):format(containerId))

    -- broadcast to everyone (including the requester)
    TriggerClientEvent('liquid_container:client:ReceiveContainer', -1, containerId, containerCoords)
end)

-- CreateThread(function()
--     Wait(1000)
--     local coords = Config.Container.randomCoords[math.random(1, #Config.Container.randomCoords)]
--     local model = GetHashKey(Config.Container.Model)

--     ---------------------------------------
--     -- create on server
--     ---------------------------------------

--     local obj = CreateObject(model, coords.x, coords.y, coords.z - 1.0, true, true, false)
--     SetEntityHeading(obj, coords.w)
--     FreezeEntityPosition(obj, true)
--     Wait(200)
--     containerId = NetworkGetNetworkIdFromEntity(obj)
--     containerCoords = coords

--     print(('[Liquid] Container spawned on server. NetID: %s'):format(containerId))

--     ---------------------------------------
--     -- Sync to all current players
--     ---------------------------------------
--     TriggerClientEvent('liquid_container:client:ReceiveContainer', -1, containerId, containerCoords)
--     ---------------------------------------
--     -- Blip
--     ---------------------------------------
--     -- TriggerClientEvent('liquid_container:client:AddContainerBlip', -1, coords)
-- end)

---------------------------------------
-- Callback to check if can open
---------------------------------------
CreateCallback('liquid_container:server:CanOpen', function(source, cb)
    if busy then
        cb(false)
        return
    end
    busy = true
    cb(true)
end)

RegisterNetEvent('liquid_container:server:ContainerOpened', function()
    busy = false
end)

---------------------------------------
-- Late joiners: ask and receive
---------------------------------------
RegisterNetEvent('liquid_container:server:RequestContainer', function()
    local src = source
    if containerId then
        print(containerCoords)
        TriggerClientEvent('liquid_container:client:ReceiveContainer', src, containerId, containerCoords)
    else
        print(('[Liquid] %s requested container before it existed.'):format(GetPlayerName(src)))
    end
end)

---------------------------------------
-- Cleanup on resource stop
---------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    if containerId then
        local entity = NetworkGetEntityFromNetworkId(containerId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
        print('[Liquid] Container deleted on resource stop.')
    end
end)
