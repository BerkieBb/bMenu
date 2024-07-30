--#region Variables

local currentlySpectating = -1
local previousPos = vec3(0, 0, 0)
local playerBlips = {}
local itemsOnYourself = {
    'kill',
}

--#endregion Variables

--#region Menu Registration

lib.registerMenu({
    id = 'bMenu_online_players',
    title = 'Online Players',
    position = MenuPosition,
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'bMenu_main')
    end,
    onSelected = function(selected)
        MenuIndexes['bMenu_online_players'] = selected
    end,
    options = {
        {label = 'No Players Online', icon = 'face-sad-tear', args = {'return'}, close = false}
    }
}, function(_, _, args)
    if args[1] == 'return' then
        lib.hideMenu(true)
        return
    end
    lib.showMenu(args[1], MenuIndexes[args[1]])
end)

--#endregion Menu Registration

--#region Functions

function CreatePlayerMenu()
    local id = 'bMenu_online_players'
    lib.setMenuOptions(id, {{label = 'No Players Online', icon = 'face-sad-tear', args = {'none'}}})
    local onlinePlayers = lib.callback.await('bMenu:server:getOnlinePlayers', false)
    local messageArg = 'message'
    local teleportArg = 'teleport'
    local teleportVehicleArg = 'teleport_vehicle'
    local summonArg = 'summon'
    local spectateArg = 'spectate'
    local waypointArg = 'waypoint'
    local blipArg = 'blip'
    local killArg = 'kill'
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, 'OnlinePlayers', {'Message', 'Teleport_To', 'Teleport_In_Vehicle', 'Summon', 'Spectate', 'Waypoint', 'Blip', 'Kill'})
    local menuOptions = {
        {label = 'You don\'t have access to any options', icon = 'face-sad-tear', args = {'return'}, close = false}
    }

    local index = 1
    if perms.Message then
        menuOptions[index] = {label = 'Send Message', icon = 'comment-dots', description = 'Send a message to this player, note that staff can see these', args = {messageArg}, close = true}
        index += 1
    end

    if perms.Teleport_To then
        menuOptions[index] = {label = 'Teleport To Player', icon = 'hat-wizard', description = 'Teleport to the player', args = {teleportArg}, close = false}
        index += 1
    end

    if perms.Teleport_In_Vehicle then
        menuOptions[index] = {label = 'Teleport Into Vehicle', icon = 'car-side', description = 'Teleport into the vehicle of the player', args = {teleportVehicleArg}, close = false}
        index += 1
    end

    if perms.Summon then
        menuOptions[index] = {label = 'Summon Player', icon = 'hat-wizard', description = 'Summon the player to your location', args = {summonArg}, close = false}
        index += 1
    end

    if perms.Spectate then
        menuOptions[index] = {label = 'Spectate Player', icon = 'glasses', description = 'Spectate the player', args = {spectateArg}, close = false}
        index += 1
    end

    if perms.Waypoint then
        menuOptions[index] = {label = 'Set Waypoint', icon = 'location-dot', description = 'Set your waypoint on the player', args = {waypointArg}, close = false}
        index += 1
    end

    if perms.Blip then
        menuOptions[index] = {label = 'Toggle Blip', icon = 'magnifying-glass-location', description = 'Toggle a blip on the map following the player', args = {blipArg}, close = false}
        index += 1
    end

    if perms.Kill then
        menuOptions[index] = {label = 'Kill Player', icon = 'bullseye', description = 'Kill the player, just because you can', args = {killArg}, close = false}
        index += 1
    end

    for i = 1, #onlinePlayers do
        local data = onlinePlayers[i]
        local formattedId = ('%s_%s'):format(id, i)
        lib.registerMenu({
            id = formattedId,
            title = ('%s (%s/%s)'):format(data.name, i, #onlinePlayers),
            position = MenuPosition,
            onClose = function(keyPressed)
                CloseMenu(false, keyPressed, id)
            end,
            onSelected = function(selected)
                MenuIndexes[formattedId] = selected
            end,
            options = menuOptions
        }, function(_, _, args)
            if args[1] == 'return' then
                lib.hideMenu(true)
                return
            end

            local canActOnSelf = ArrayIncludes(args[1], itemsOnYourself)
            if data.source == ServerId and not canActOnSelf then
                lib.notify({
                    description = 'You can\'t do this on yourself',
                    type = 'error'
                })
                if args[1] == messageArg then
                    lib.showMenu(formattedId, MenuIndexes[formattedId])
                end

                return
            end

            local message = args[1] == messageArg and lib.hideMenu(true) and lib.inputDialog(('Send a message to %s'):format(data.name), {'Message'})

            if args[1] == messageArg and (not message or not message[1] or message[1] == '') then
                Wait(500)
                lib.showMenu(formattedId, MenuIndexes[formattedId])
                return
            end

            ---@diagnostic disable-next-line: need-check-nil
            local success, reason, extraArg1 = lib.callback.await('bMenu:server:playerListAction', false, args[1], data.source, canActOnSelf, message and message[1] or nil)

            if args[1] == teleportVehicleArg and success then
                local veh = NetToVeh(extraArg1)
                if not AreAnyVehicleSeatsFree(veh) then
                    success = false
                    reason = 'There are no seats available'
                end

                local found = false

                for i2 = -1, GetVehicleModelNumberOfSeats(GetEntityModel(veh)) do
                    if IsVehicleSeatFree(veh, i2) then
                        found = true
                        TaskWarpPedIntoVehicle(cache.ped, veh, i2)
                        break
                    end
                end

                if not found then
                    success = false
                    reason = 'There are no seats available'
                end
            elseif args[1] == waypointArg and success then
                SetNewWaypoint(extraArg1.x, extraArg1.y)
            elseif args[1] == blipArg and success then
                if playerBlips[data.source] then
                    if DoesBlipExist(playerBlips[data.source]) then
                        RemoveBlip(playerBlips[data.source])
                    end

                    playerBlips[data.source] = nil
                else
                    local ent = NetToEnt(extraArg1)
                    playerBlips[data.source] = AddBlipForEntity(ent)
                    SetBlipNameToPlayerName(playerBlips[data.source], NetworkGetPlayerIndexFromPed(ent))
                    SetBlipCategory(playerBlips[data.source], 7)
                    SetBlipColour(playerBlips[data.source], 0)
                    ShowHeadingIndicatorOnBlip(playerBlips[data.source], true)
                    ShowHeightOnBlip(playerBlips[data.source], true)
                end
            elseif args[1] == killArg and success then
                SetEntityHealth(NetToEnt(extraArg1), 0)
            elseif args[1] == spectateArg and success then
                local player = GetPlayerFromServerId(data.source)
                local playerPed = GetPlayerPed(player)

                if NetworkIsInSpectatorMode() then
                    if currentlySpectating ~= player and playerPed ~= 0 then
                        DoScreenFadeOut(500)
                        while IsScreenFadingOut() do
                            Wait(0)
                        end

                        RequestCollisionAtCoord(extraArg1.x, extraArg1.y, extraArg1.z + 3)
                        SetEntityVisible(cache.ped, false, false)
                        NetworkSetEntityInvisibleToNetwork(cache.ped, true)
                        SetEntityCollision(cache.ped, false, true)
                        FreezeEntityPosition(cache.ped, true)
                        SetEntityCoords(cache.ped, extraArg1.x, extraArg1.y, extraArg1.z + 3, true, false, false, false)

                        NetworkSetInSpectatorMode(false, 0)
                        NetworkSetInSpectatorMode(true, playerPed)

                        DoScreenFadeIn(500)
                        currentlySpectating = player
                    else
                        DoScreenFadeOut(500)
                        while IsScreenFadingOut() do
                            Wait(0)
                        end

                        RequestCollisionAtCoord(previousPos.x, previousPos.y, previousPos.z)

                        NetworkSetInSpectatorMode(false, 0)

                        SetEntityCoords(cache.ped, previousPos.x, previousPos.y, previousPos.z, true, false, false, false)
                        previousPos = vec3(0, 0, 0)
                        SetEntityVisible(cache.ped, true, false)
                        NetworkSetEntityInvisibleToNetwork(cache.ped, false)
                        SetEntityCollision(cache.ped, true, true)
                        FreezeEntityPosition(cache.ped, false)

                        DoScreenFadeIn(500)
                        reason = 'Successfully stopped spectating'
                        currentlySpectating = -1
                    end
                else
                    if playerPed ~= 0 then
                        DoScreenFadeOut(500)
                        while IsScreenFadingOut() do
                            Wait(0)
                        end

                        RequestCollisionAtCoord(extraArg1.x, extraArg1.y, extraArg1.z + 3)

                        SetEntityVisible(cache.ped, false, false)
                        NetworkSetEntityInvisibleToNetwork(cache.ped, true)
                        SetEntityCollision(cache.ped, false, true)
                        FreezeEntityPosition(cache.ped, true)
                        previousPos = GetEntityCoords(cache.ped)
                        SetEntityCoords(cache.ped, extraArg1.x, extraArg1.y, extraArg1.z + 3, true, false, false, false)

                        NetworkSetInSpectatorMode(false, 0)
                        NetworkSetInSpectatorMode(true, playerPed)

                        DoScreenFadeIn(500)
                        currentlySpectating = player
                    end
                end
            end

            lib.notify({
                description = reason,
                type = success and 'success' or 'error'
            })

            if args[1] ~= messageArg then return end

            Wait(500)
            lib.showMenu(formattedId, MenuIndexes[formattedId])
        end)

        lib.setMenuOptions(id, {label = ('[%s] %s'):format(data.source, data.name), args = {formattedId}}, i)
    end
end

--#endregion Functions