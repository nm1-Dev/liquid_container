local QBCore = exports['qb-core']:GetCoreObject()
local containerId = nil
local containerCoords = nil
local isSpawned = false
local busy = false

QBCore.Commands.Add('laptop', '', {}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local gangData = Player.PlayerData.gang

    if Config.ContainerStart.anyPlayer then
        print("[Liquid] Any player can start the container event.")
        return
    end

    if Config.ContainerStart.gangBoss and not gangData.isboss then
        print("[Liquid] Only gang bosses can start the event.")
        return
    end

    if Config.ContainerStart.specificGangBoss and Config.ContainerStart.specificGangBoss ~= false then
        if gangData.name ~= Config.ContainerStart.specificGangBoss or not gangData.isboss then
            print(("[Liquid] Only the '%s' gang boss can start the event."):format(Config.ContainerStart.specificGangBoss))
            return
        end
    end


    -- print(("[Liquid] %s started the container event."):format(Player.PlayerData.charinfo.firstname))
    TriggerClientEvent('liquid_container:client:OpenLapTop', src)
end)

RegisterNetEvent("liquid_container:server:startContainer", function(zone)
    local containerPlace = Config.Container.Locations[zone]
    if not containerPlace then return print('Invalid Zone Number') end
    print_r(containerPlace)

    if isSpawned then
        return QBCore.Functions.Notify('There is a Container Are being raided currently, try again after: ' .. 'time goes here', 'error', 4000)
    end

    isSpawned = true

    local model  = GetHashKey(Config.Container.Model)
    local obj = CreateObject(model, containerPlace.coord.x, containerPlace.coord.y, containerPlace.coord.z - 1.0, true, true, false)

    SetEntityHeading(obj, containerPlace.coord.w or 90)
    FreezeEntityPosition(obj, true)
    Wait(200)

    containerId     = NetworkGetNetworkIdFromEntity(obj)
    containerCoords = containerPlace.coord
    print(('[Liquid] Container spawned on server. NetID: %s'):format(containerId))

    TriggerClientEvent('liquid_container:client:SpawnObject', -1, containerId, zone)
end)

RegisterNetEvent('liquid_container:server:RequestOrSpawn', function()
    local src = source
    if containerId and containerCoords then
        TriggerClientEvent('liquid_container:client:ReceiveContainer', src, containerId, containerCoords)
        return
    end
    if isSpawned then
        return QBCore.Functions.Notify('There is a Container Are being raided currently try again after: ' .. 'time goes here', 'error', 4000)
    end
    -- lock
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

CreateCallback('liquid_container:server:ResetStatus', function(source, cb)
    busy = false
    Wait(5000)
    if busy then
        print('[Liquid] Warning: busy flag still set after 5s.')
    end
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
