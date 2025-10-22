local QBCore = exports['qb-core']:GetCoreObject()
local isSpawned = false
local busy = false
local rewardCooldown = {}
local canStart = true

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
    TriggerClientEvent('liquid_container:client:OpenLapTop', src)
end)

QBCore.Commands.Add('resetcontainer', '', {}, false, function(source, args)
    local src = source
    if isSpawned then
        isSpawned = false
        TriggerClientEvent('liquid_container:client:RemoveContainer', -1)
        QBCore.Functions.Notify(src, 'Container has been reset')
    end
end, 'admin')

RegisterNetEvent('liquid_container:server:broadcastObject', function(zone, netId)
    if netId then
        TriggerClientEvent('liquid_container:client:Announce', -1, zone, netId)
    else
        print('[Liquid] No netId found')
    end
end)

RegisterNetEvent("liquid_container:server:startContainer", function(zone)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local containerPlace = Config.Container.Locations[zone]
    if not containerPlace then return print('[Liquid] Invalid Zone Number') end

    if not canStart then
        QBCore.Functions.Notify(src, 'You must wait before starting another container.', 'error')
        return
    end

    if isSpawned then
        QBCore.Functions.Notify(src, 'There is a container are being raided currently')
        return
    end

    isSpawned = true
    canStart = false
    TriggerEvent('qb-log:server:CreateLog', 'container', 'Container Started', 'green', 
        string.format("%s (%s) started a container in zone %s", GetPlayerName(src), Player.PlayerData.citizenid, zone))
    QBCore.Functions.Notify(src, 'Container has been started')
    TriggerClientEvent('liquid_container:client:SpawnContainer', src, containerPlace)

    CreateThread(function()
        local cooldown = Config.TimeBetweenContainers * 60 * 1000
        Wait(cooldown)
        canStart = true
        print('[Liquid] Container cooldown expired, can start again.')
    end)
end)

---------------------------------------
-- Event to handle opened container
---------------------------------------
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
    TriggerEvent('qb-log:server:CreateLog', 'container', 'Container Looted', 'green', string.format("%s (%s) looted a container and received rewards.", GetPlayerName(src), Player.PlayerData.citizenid))
    isSpawned = false
    TriggerClientEvent('liquid_container:client:RemoveContainer', -1)
end)

---------------------------------------
-- Callback to check if can open
---------------------------------------
QBCore.Functions.CreateCallback('liquid_container:server:CanOpen', function(source, cb)
    if busy then
        cb(false)
        return
    end
    busy = true
    cb(true)
end)

---------------------------------------
-- Cleanup cooldown when player leaves
---------------------------------------
AddEventHandler('playerDropped', function()
    rewardCooldown[source] = nil
end)