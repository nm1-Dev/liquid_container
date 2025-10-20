if Config.Framework ~= "qb" then
    return
end

local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayer(src)
    return QBCore.Functions.GetPlayer(src)
end

function AddItem(src, item, amount, info, slot)
    local Player = GetPlayer(src)
    Player.Functions.AddItem(item, amount, slot, info)
end

function RegisterUseableItem(name, cb)
    QBCore.Functions.CreateUseableItem(name, cb)
end

function CreateCallback(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end