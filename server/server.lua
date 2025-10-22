local QBCore = exports['qb-core']:GetCoreObject()
local containerId = nil
local containerCoords = nil
local isSpawned = false
local busy = false
local rewardCooldown = {}

-- QBCore.Commands.Add('laptop', '', {}, false, function(source, args)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     local gangData = Player.PlayerData.gang

--     if Config.ContainerStart.anyPlayer then
--         print("[Liquid] Any player can start the container event.")
--         return
--     end

--     if Config.ContainerStart.gangBoss and not gangData.isboss then
--         print("[Liquid] Only gang bosses can start the event.")
--         return
--     end

--     if Config.ContainerStart.specificGangBoss and Config.ContainerStart.specificGangBoss ~= false then
--         if gangData.name ~= Config.ContainerStart.specificGangBoss or not gangData.isboss then
--             print(("[Liquid] Only the '%s' gang boss can start the event."):format(Config.ContainerStart.specificGangBoss))
--             return
--         end
--     end
--     TriggerClientEvent('liquid_container:client:OpenLapTop', src)
-- end)

RegisterNetEvent('liquid_container:server:broadcastObject', function(zone, netId)
    if netId then
        TriggerClientEvent('liquid_container:client:Announce', -1, zone, netId)
    else
        print('[Liquid] No netId found')
    end
end)


RegisterNetEvent("liquid_container:server:startContainer", function(zone)
    local src = source
    local containerPlace = Config.Container.Locations[zone]
    if not containerPlace then return print('[Liquid] Invalid Zone Number') end

    if isSpawned then
        QBCore.Functions.Notify(src, 'There is a container are being raided currently')
        return
    end

    isSpawned = true
    TriggerEvent('qb-log:server:CreateLog', 'container', 'Container Started', 'green', 
        string.format("%s (%s) started a container in zone %s", GetPlayerName(src), Player.PlayerData.citizenid, zone))
    QBCore.Functions.Notify(src, 'Container has been started')
    TriggerClientEvent('liquid_container:client:SpawnContainer', src, containerPlace)
end)

QBCore.Commands.Add('resetcontainer', '', {}, false, function(source, args)
    if isSpawned then
        isSpawned = false
        TriggerClientEvent('liquid_container:client:RemoveContainer', -1)
        QBCore.Functions.Notify(source, 'Container has been reset')
    end
end, 'admin')

RegisterNetEvent("liquid_container:server:ContainerOpened", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- ✅ Prevent exploit spam (10s cooldown per player)
    if rewardCooldown[src] and rewardCooldown[src] > os.time() then
        print(("[Liquid] %s tried to reopen the container too soon."):format(GetPlayerName(src)))
        return
    end
    rewardCooldown[src] = os.time() + 10
    -- ✅ Item rewards
    if Config.Reward.items.enabled then
        for _, reward in pairs(Config.Reward.items.list) do
            if math.random(1, 100) <= reward.chance then
                local amount = math.random(reward.amount.min, reward.amount.max)
                Player.Functions.AddItem(reward.item, amount)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reward.item], 'add')
                print(("[Liquid] Gave %sx %s to %s"):format(amount, reward.item, GetPlayerName(src)))
            end
        end
    end

    -- ✅ Money rewards
    if Config.Reward.money.enabled then
        local amount = math.random(Config.Reward.money.min, Config.Reward.money.max)
        local moneyType = Config.Reward.money.type or "cash"
        Player.Functions.AddMoney(moneyType, amount, "container-reward")
        print(("[Liquid] Gave $%s (%s) to %s"):format(amount, moneyType, GetPlayerName(src)))
    end

    -- ✅ Notify player
    TriggerClientEvent('QBCore:Notify', src, 'You looted the container successfully.', 'success')

    -- ✅ Optional: server log for audit
    TriggerEvent('qb-log:server:CreateLog', 'container', 'Container Looted', 'green', 
        string.format("%s (%s) looted a container and received rewards.", GetPlayerName(src), Player.PlayerData.citizenid))
    isSpawned = false
    TriggerClientEvent('liquid_container:client:RemoveContainer', -1)
    print('[Liquid] Container reset.')
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

-- Cleanup cooldown when player leaves
AddEventHandler('playerDropped', function()
    rewardCooldown[source] = nil
end)