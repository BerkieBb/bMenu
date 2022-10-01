if type(MenuPermission) == 'string' and not IsPrincipalAceAllowed(MenuPermission --[[@as string]], 'command.berkiemenu') then
    lib.addAce(MenuPermission, 'command.berkiemenu')
end

lib.callback.register('berkie_menu:server:getOnlinePlayers', function()
    local players = GetPlayers()
    local data = {}
    for i = 1, #players do
        local src = players[i]
        data[#data+1] = {
            source = tonumber(src),
            name = GetPlayerName(src)
        }
    end
    return data
end)

lib.callback.register('berkie_menu:server:playerListAction', function(source, action, playerSource, canActOnSelf, message)
    if source == playerSource and not canActOnSelf then return false, 'You can\'t act on yourself' end

    local messageArg = string.find(action, '_message')
    local teleportVehicleArg = string.find(action, '_teleport_vehicle')
    local teleportArg = not teleportVehicleArg and string.find(action, 'teleport')
    local summonArg = string.find(action, '_summon')
    local spectateArg = string.find(action, '_spectate')
    local waypointArg = string.find(action, '_waypoint')
    local blipArg = string.find(action, '_blip')
    local killArg = string.find(action, '_kill')
    local playerName = GetPlayerName(playerSource)
    local playerPed = GetPlayerPed(playerSource)
    local ped = GetPlayerPed(source)

    if messageArg then
        TriggerClientEvent('chat:addMessage', playerSource, {
            color = { 255, 0, 0 },
            multiline = true,
            args = {('PM from %s'):format(GetPlayerName(source)), message}
        })
        return true, ('Successfully sent a message to %s'):format(playerName)
    elseif teleportArg then
        local playerCoords = GetEntityCoords(playerPed)
        SetEntityCoords(ped, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false, false)
        return true, ('Successfully teleported to %s'):format(playerName)
    elseif teleportVehicleArg then
        local veh = GetVehiclePedIsIn(playerPed, false)
        if veh == 0 then return false, ('%s is not in a vehicle'):format(playerName) end
        return true, ('Successfully teleported into the vehicle of %s'):format(playerName), NetworkGetNetworkIdFromEntity(veh)
    elseif summonArg then
        local playerCoords = GetEntityCoords(ped)
        SetEntityCoords(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false, false)
        return true, ('Successfully summoned %s'):format(playerName)
    elseif spectateArg then
        return false, ('Not implemented yet')
    elseif waypointArg then
        return true, ('Successfully set your waypoint to %s'):format(playerName), GetEntityCoords(playerPed).xy
    elseif blipArg then
        return true, ('Successfully toggled the blip to %s'):format(playerName), NetworkGetNetworkIdFromEntity(playerPed)
    elseif killArg then
        return true, ('Successfully killed %s'):format(playerName), NetworkGetNetworkIdFromEntity(playerPed)
    end

    return false, ('Invalid action %s'):format(action)
end)