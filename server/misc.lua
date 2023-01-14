RegisterNetEvent('berkie_menu:server:clearArea', function(pos)
    TriggerClientEvent('berkie_menu:client:clearArea', -1, pos)
end)

lib.callback.register('berkie_menu:server:setConvar', function(_, convar, value, replicated, sendUpdate)
    if sendUpdate then
        TriggerClientEvent('berkie_menu:client:updateConvar', -1, convar, value)
    end
    return replicated and SetConvarReplicated(convar, value) or SetConvar(convar, value)
end)