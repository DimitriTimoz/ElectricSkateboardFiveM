RegisterServerEvent("shareImOnSkate")
AddEventHandler("shareImOnSkate", function() 
    print("Shareando!")
    local _source = source
    TriggerClientEvent("shareHeIsOnSkate", -1, _source)
end)