--#region Startup

-- I don't want you renaming this because this uses kvp and that requires the resource name to be the same across servers to work correctly
if GetCurrentResourceName() ~= 'bMenu' then
    error('Please don\'t rename this resource, change the folder name (back) to \'bMenu\' (case sensitive) to make sure the saved data can be saved and fetched accordingly from the cache.')
    return
end

--#endregion Startup

--#region Callbacks

lib.callback.register('berkie_menu:server:setConvar', function(_, convar, value, replicated, sendUpdate, menuId, option, optionId)
    if sendUpdate then
        TriggerClientEvent('berkie_menu:client:updateConvar', -1, convar, value, menuId, option, optionId)
    end
    return replicated and SetConvarReplicated(convar, value) or SetConvar(convar, value)
end)

--#endregion Callbacks
