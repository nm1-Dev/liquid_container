---------------------------------------
-- Open Container Function
---------------------------------------
function OpenContainer(entity)
    QBCore.Functions.TriggerCallback('liquid_container:server:CanOpen', function(can)
        if can then
            print('[Liquid] Opening container...')
            OpenAnimation(entity)
        else
            notify('You cannot open the container right now.', 'error')
        end
    end)
end

---------------------------------------
-- Open Container Animation
---------------------------------------
function OpenAnimation(entity)
    if not DoesEntityExist(entity) then
        print('OpenContainer: Entity does not exist')
        return
    end

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
    local particles = StartParticleFxLoopedOnEntity("scr_tn_tr_angle_grinder_sparks", grinderProp, 0.0, 0.25, 0.0, 0.0,
        0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
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
-- Table Print
---------------------------------------
function print_r(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            Citizen.Trace(indent .. "*" .. tostring(t) .. "\n")
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        Citizen.Trace(indent .. "[" .. pos .. "] => " .. tostring(t) .. " {" .. "\n")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        Citizen.Trace(indent .. string.rep(" ", string.len(pos) + 6) .. "}" .. "\n")
                    else
                        Citizen.Trace(indent .. "[" .. pos .. "] => " .. tostring(val) .. "\n")
                    end
                end
            else
                Citizen.Trace(indent .. tostring(t) .. "\n")
            end
        end
    end
    sub_print_r(t, "  ")
end