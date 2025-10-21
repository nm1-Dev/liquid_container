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
RegisterNetEvent('liquid_container:client:ReceiveContainer', function(netId, coords)
    print(('[Liquid] Container received on client. NetID: %s'):format(netId))

    local obj = NetToObj(netId)
    local timeout = GetGameTimer() + 5000

    while not DoesEntityExist(obj) and GetGameTimer() < timeout do
        Wait(100)
        obj = NetToObj(netId)
    end

    if not DoesEntityExist(obj) then
        print('[Liquid] Warning: container entity not found after 5s.')
        return
    end

    containerEntity = obj
    FreezeEntityPosition(containerEntity, true)
    SetEntityInvincible(containerEntity, true)

    ---------------------------------------
    --  Add blips
    ---------------------------------------
    blip = AddBlipForRadius(coords.x, coords.y, coords.z, 350.0)
    SetBlipColour(blip, 1)
    SetBlipAlpha(blip, 128)
    print('[Liquid] Container blip added.')

    exports['qb-target']:AddTargetEntity(containerEntity, {
        options = {
            {
                icon = "fas fa-box",
                label = "Open Container",
                action = function(entity)
                    print('[Liquid] Container opened. ==> ' .. entity)
                    OpenContainer(entity)
                end,
            },
        },
        distance = 2.5,
    })
end)

---------------------------------------
-- Open Container Function
---------------------------------------

function OpenContainer(entity)
    TriggerCallback('liquid_container:server:CanOpen', function(can)
        if can then
            print('[Liquid] Opening container...')
            OpenAnimation(entity)
        else
            notify('You cannot open the container right now.', 'error')
        end
    end)
end

function OpenAnimation(entity)
    if not DoesEntityExist(entity) then print('OpenContainer: Entity does not exist') return end

    while NetworkGetEntityOwner(entity) ~= PlayerId() do
        NetworkRequestControlOfEntity(entity)
        Wait(100)
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(entity)
    local rotation = GetEntityRotation(entity)
    local dict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    local bagModel = GetHashKey('hei_p_m_bag_var22_arm_s')
    local grinderModel = GetHashKey('tr_prop_tr_grinder_01a')
    local lockModel = GetHashKey('tr_prop_tr_lock_01a')
    local heading = GetEntityHeading(entity)

    -- Request animation dictionary
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
    Wait(0)
    end

    -- Request models
    RequestModel(bagModel)
    while not HasModelLoaded(bagModel) do
    Wait(0)
    end

    RequestModel(grinderModel)
    while not HasModelLoaded(grinderModel) do
    Wait(0)
    end

    RequestModel(lockModel)
    while not HasModelLoaded(lockModel) do
    Wait(0)
    end

    -- Request particle effect asset
    RequestNamedPtfxAsset('scr_tn_tr')
    while not HasNamedPtfxAssetLoaded('scr_tn_tr') do
    Wait(0)
    end


    local bagProp = CreateObject(bagModel, coords.x, coords.y, coords.z, true, true, true)
    local grinderProp = CreateObject(grinderModel, coords.x, coords.y, coords.z, true, true, true)
    local lockProp = CreateObject(lockModel, coords.x, coords.y, coords.z, true, true, true)

    SetEntityCollision(bagProp, false, true)
    SetEntityCollision(grinderProp, false, true)
    SetEntityCollision(lockProp, false, true)

    local scene = NetworkCreateSynchronisedScene(coords.xy, coords.z - 0.05, rotation, 2, true, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(ped, scene, dict, "action", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bagProp, scene, dict, "action_bag", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(grinderProp, scene, dict, "action_angle_grinder", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(lockProp, scene, dict, "action_lock", 1.0, 1.0, 1)
    
    local propScene = NetworkCreateSynchronisedScene(coords.xy, coords.z - 0.05, rotation, 2, true, false, -1, 0, 1.0)
    NetworkAddEntityToSynchronisedScene(entity, propScene, dict, "action_container", 1.0, 1.0, 1)

    NetworkStartSynchronisedScene(scene)
    NetworkStartSynchronisedScene(propScene)

    Wait(4000)
    UseParticleFxAssetNextCall('scr_tn_tr')
    local particles = StartParticleFxLoopedOnEntity("scr_tn_tr_angle_grinder_sparks", grinderProp, 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
    Wait(1000)
    StopParticleFxLooped(particles, 1)

    Wait(2000)

    Wait(3400)
    TriggerServerEvent('liquid_container:server:ContainerOpened')
    DeleteEntity(bagProp)
    DeleteEntity(grinderProp)
    DeleteEntity(lockProp)

    SetEntityCollision(entity, false, true)

    RemoveAnimDict(dict)
    SetModelAsNoLongerNeeded(bagModel)
    SetModelAsNoLongerNeeded(grinderModel)
    SetModelAsNoLongerNeeded(lockModel)
    RemoveNamedPtfxAsset('scr_tn_tr')
end

---------------------------------------
-- Cleanup if resource stops
---------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    if containerEntity and DoesEntityExist(containerEntity) then
        DeleteEntity(containerEntity)
    end
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end)
