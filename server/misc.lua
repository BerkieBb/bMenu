RegisterNetEvent('bMenu:server:clearArea', function(pos)
    TriggerClientEvent('bMenu:client:clearArea', -1, pos)
end)