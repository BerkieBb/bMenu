--#region Callbacks

lib.callback.register('bMenu:server:getOnlinePlayers', function()
    local players = GetPlayers()
    local data = {}
    for i = 1, #players do
        local src = players[i]
        data[#data + 1] = {
            source = tonumber(src),
            name = GetPlayerName(src)
        }
    end
    return data
end)

lib.callback.register('bMenu:server:playerListAction', function(source, action, playerSource, canActOnSelf, message)
    if source == playerSource and not canActOnSelf then return false, 'You can\'t act on yourself' end

    local messageArg = action == 'message'
    local teleportVehicleArg = action == 'teleport_vehicle'
    local teleportArg = action == 'teleport'
    local summonArg = action == 'summon'
    local spectateArg = action == 'spectate'
    local waypointArg = action == 'waypoint'
    local blipArg = action == 'blip'
    local killArg = action == 'kill'
    local playerName = GetPlayerName(playerSource)
    local playerPed = GetPlayerPed(playerSource)
    local ped = GetPlayerPed(source)

    if messageArg then
        local canSendMessage = lib.callback.await('bMenu:client:canSendMessage', playerSource)
        if not canSendMessage then
            return false, ('%s has their PMs disabled'):format(playerName)
        end
        TriggerClientEvent('chat:addMessage', playerSource, {
            color = { 255, 0, 0 },
            multiline = true,
            args = { ('PM from %s'):format(GetPlayerName(source)), message }
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
        return true, ('Successfully spectating %s'):format(playerName), GetEntityCoords(playerPed)
    elseif waypointArg then
        return true, ('Successfully set your waypoint to %s'):format(playerName), GetEntityCoords(playerPed).xy
    elseif blipArg then
        return true, ('Successfully toggled the blip to %s'):format(playerName), NetworkGetNetworkIdFromEntity(playerPed)
    elseif killArg then
        return true, ('Successfully killed %s'):format(playerName), NetworkGetNetworkIdFromEntity(playerPed)
    end

    return false, ('Invalid action %s'):format(action)
end)

--#endregion Callbacks