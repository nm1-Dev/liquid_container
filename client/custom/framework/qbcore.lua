if Config.Framework ~= "qb" then
    return
end

local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayerData()
    return QBCore.Functions.GetPlayerData()
end

function notify(text, type, duration)
    QBCore.Functions.Notify(text, type or "primary", duration or 5000)
end

function TriggerCallback(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end