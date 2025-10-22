local obj = nil
local containerSpawned = false
local containerNetId = nil
local blip = nil
local netObject = nil
local GUARD_GROUP = "GuardPeds"
local spawnedGuards = {}

---------------------------------------
-- When the server sends us the container NetID
---------------------------------------
RegisterNetEvent('liquid_container:client:SpawnContainer', function(container, zone)
    createContainer(container)
    createBlip(container)
end)

RegisterNetEvent('liquid_container:client:Announce', function(zone, netId)
    Wait(200)
    netObject = NetToObj(netId)
    exports['qb-target']:AddTargetEntity(netObject, {
        options = {
            {
                icon = "fas fa-box",
                label = "Open Container",
                action = function(entity)
                    OpenContainer(entity)
                end,
            },
        },
        distance = 2.5,
    })
    spawnNPC(zone)
    TriggerEvent("chat:addMessage", {
        color = { 0, 0, 0 },
        multiline = true,
        args = { 'MERRY WEATHER', 'There is an container' }
    })
    PlaySoundFrontend(-1, "5s_To_Event_Start_Countdown", "GTAO_FM_Events_Soundset", true)
    Wait(1000)
end)

function createContainer(container)
    local model = GetHashKey(Config.Container.Model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    obj = CreateObject(model, container.coord.x, container.coord.y, container.coord.z - 1.0, true, true, true)
    SetEntityHeading(obj, container.coord.w or 0.0)
    FreezeEntityPosition(obj, true)
    SetEntityInvincible(obj, true)
    containerNetId = NetworkGetNetworkIdFromEntity(obj)
    SetNetworkIdCanMigrate(containerNetId, true)
    TriggerServerEvent('liquid_container:server:broadcastObject', container, containerNetId)
    print()
end

function createBlip(container)
    blip = AddBlipForRadius(container.coord.x, container.coord.y, container.coord.z, 350.0)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 128)
end

RegisterNetEvent('liquid_container:client:RemoveContainer', function()
    local entity = NetworkGetEntityFromNetworkId(containerNetId)
    if containerNetId and DoesEntityExist(containerNetId) then
        DeleteEntity(containerNetId)
        containerNetId = nil
    end
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
        blip = nil
    end
    -- print('[Liquid] Container removed from client.')
end)


CreateThread(function()
    AddRelationshipGroup(GUARD_GROUP)
    SetRelationshipBetweenGroups(5, GetHashKey(GUARD_GROUP), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey(GUARD_GROUP))
end)

function spawnNPC(placeId)
    if not Config.Container.Locations[placeId] or not Config.Container.Locations[placeId].npc then
        print("[Liquid] Invalid or missing NPC config for location:", placeId)
        return
    end

    for id, guard in pairs(Config.Container.Locations[placeId].npc) do
        RequestModel(guard.ped)
        while not HasModelLoaded(guard.ped) do Wait(0) end

        local ped = CreatePed(
            26,
            GetHashKey(guard.ped),
            guard.pos.x, guard.pos.y, guard.pos.z,
            guard.pos.w or 0.0,
            true, true
        )

        if not DoesEntityExist(ped) then
            print(("[Liquid] Failed to create guard %s at #%s"):format(guard.ped, id))
            goto continue
        end

        GiveWeaponToPed(ped, GetHashKey(guard.weapon), 255, false, false)
        SetPedAccuracy(ped, guard.accuracy or 60)
        SetPedAlertness(ped, guard.alertness or 2)
        SetPedCombatMovement(ped, guard.aggressiveness or 1)
        SetPedMaxHealth(ped, guard.health or 200)
        SetEntityHealth(ped, guard.health or 200)
        SetPedDropsWeaponsWhenDead(ped, false)
        SetEntityVisible(ped, true)
        SetPedRelationshipGroupHash(ped, GetHashKey(GUARD_GROUP))

        -- combat behavior setup
        SetPedAsEnemy(ped, true)
        SetPedKeepTask(ped, true)
        SetPedCombatAttributes(ped, 46, true)  -- always fight
        SetPedCombatAttributes(ped, 5, true)   -- fight armed players
        SetPedCombatAttributes(ped, 0, false)  -- don't flee
        SetPedSeeingRange(ped, 90.0)
        SetPedHearingRange(ped, 70.0)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatRange(ped, 2)
        SetPedCombatAbility(ped, 2)
        SetBlockingOfNonTemporaryEvents(ped, true)

        -- assign combat task to all active players
        local players = GetActivePlayers()
        for _, ply in pairs(players) do
            local targetPed = GetPlayerPed(ply)
            if DoesEntityExist(targetPed) and targetPed ~= ped then
                TaskCombatPed(ped, targetPed, 0, 16)
            end
        end

        -- keep re-engaging nearby players automatically
        -- CreateThread(function()
        --     while DoesEntityExist(ped) and not IsPedDeadOrDying(ped) do
        --         Wait(2000)
        --         local players = GetActivePlayers()
        --         for _, ply in pairs(players) do
        --             local targetPed = GetPlayerPed(ply)
        --             if DoesEntityExist(targetPed) and targetPed ~= ped then
        --                 local dist = #(GetEntityCoords(ped) - GetEntityCoords(targetPed))
        --                 if dist < 90.0 then
        --                     TaskCombatPed(ped, targetPed, 0, 16)
        --                 end
        --             end
        --         end
        --     end
        -- end)

        table.insert(spawnedGuards, ped)
        ::continue::
    end
end

-- optional cleanup function
function removeGuards()
    for _, ped in pairs(spawnedGuards) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    spawnedGuards = {}
end

---------------------------------------
-- laptop
---------------------------------------
RegisterNetEvent('liquid_container:client:OpenLapTop', function()
    openUI()
end)

CreateThread(function()
    exports.interact:AddInteraction({
        coords = vector3(1276.61, -1710.27, 54.81),
        distance = 5.0,          -- optional
        interactDst = 2.0,       -- optional
        id = 'liquid_container', -- needed for removing interactions
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
    -- print_r(zone)
    if zone then
        TriggerServerEvent('liquid_container:server:startContainer', zone.id)
    end
    cb({ ok = true })
end)


---------------------------------------
-- Cleanup if resource stops
---------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    exports.interact:RemoveInteraction('liquid_container')
    if obj and DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end)
