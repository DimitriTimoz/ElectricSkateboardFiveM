local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('skate', function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent('longboard:start', src)
    end
end)

RegisterServerEvent('shareImOnSkate')
AddEventHandler('shareImOnSkate', function(source) 
    local src = source
    TriggerClientEvent('shareHeIsOnSkate', -1, src)
end)
