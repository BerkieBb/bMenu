RegisterNetEvent('berkie_menu:server:clearArea', function(pos)
    TriggerClientEvent('berkie_menu:client:clearArea', -1, pos)
end)