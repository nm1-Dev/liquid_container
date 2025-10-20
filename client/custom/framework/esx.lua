if Config.Framework ~= "esx" then
    return
end

local ESX = exports['es_extended']:getSharedObject()

function GetPlayerData()
    return ESX.GetPlayerData()
end

function notify(text, type, duration)
    ESX.ShowNotification(text, type or "primary", duration or 5000)
end

function TriggerCallback(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
end