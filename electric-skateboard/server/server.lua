local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("skate", function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(item.name) then
        TriggerClientEvent("longboard:start", src)
    end
end)
