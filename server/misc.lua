--#region Events

RegisterNetEvent('bMenu:server:clearArea', function(pos)
    TriggerClientEvent('bMenu:client:clearArea', -1, pos)
end)

--#endregion Events

--#region Callbacks

lib.callback.register('bMenu:server:getMaxClients', function()
    return GetConvarInt('sv_maxclients', 48)
end)

--#endregion Callbacks