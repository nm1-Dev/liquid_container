if Config.Framework ~= "esx" then
    return
end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayer(src)
    return ESX.GetPlayerFromId(src)
end

function AddItem(src, item, amount, info, slot)
    local Player = GetPlayer(src)
    Player.addInventoryItem(item, amount, info, slot)
end

function RegisterUseableItem(name, cb)
    ESX.RegisterUsableItem(name, cb)
end

function CreateCallback(name, cb)
    ESX.RegisterServerCallback(name, cb)
end