--#region Variables

local currentlySpectating = -1
local previousPos = vec3(0)
local playerBlips = {}
local itemsOnYourself = {
    'kill',
}

--#endregion Variables

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_online_players',
    title = 'Online Players',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_online_players'] = selected
    end,
    options = {}
}, function(_, _, args)
    lib.showMenu(args[1], MenuIndexes[args[1]])
end)

--#endregion Menu Registration

--#region Functions

function CreatePlayerMenu()
    local id = 'berkie_menu_online_players'
    lib.setMenuOptions(id, {[1] = true})
    local onlinePlayers = lib.callback.await('berkie_menu:server:getOnlinePlayers', false)
    for i = 1, #onlinePlayers do
        local data = onlinePlayers[i]
        local formattedId = ('%s_%s'):format(id, i)
        local messageArg = 'message'
        local teleportArg = 'teleport'
        local teleportVehicleArg = 'teleport_vehicle'
        local summonArg = 'summon'
        local spectateArg = 'spectate'
        local waypointArg = 'waypoint'
        local blipArg = 'blip'
        local killArg = 'kill'
        lib.registerMenu({
            id = formattedId,
            title = data.name,
            position = 'top-right',
            onClose = function(keyPressed)
                CloseMenu(false, keyPressed, id)
            end,
            onSelected = function(selected)
                MenuIndexes[formattedId] = selected
            end,
            options = {
                {label = 'Send Message', icon = 'comment-dots', description = 'Send a message to this player, note that staff can see these', args = {messageArg}, close = true},
                {label = 'Teleport To Player', icon = 'hat-wizard', description = 'Teleport to the player', args = {teleportArg}, close = false},
                {label = 'Teleport Into Vehicle', icon = 'car-side', description = 'Teleport into the vehicle of the player', args = {teleportVehicleArg}, close = false},
                {label = 'Summon Player', icon = 'hat-wizard', description = 'Summon the player to your location', args = {summonArg}, close = false},
                {label = 'Spectate Player', icon = 'glasses', description = 'Spectate the player', args = {spectateArg}, close = false},
                {label = 'Set Waypoint', icon = 'location-dot', description = 'Set your waypoint on the player', args = {waypointArg}, close = false},
                {label = 'Toggle Blip', icon = 'magnifying-glass-location', description = 'Toggle a blip on the map following the player', args = {blipArg}, close = false},
                {label = 'Kill Player', icon = 'bullseye', description = 'Kill the player, just because you can', args = {killArg}, close = false}
            }
        }, function(_, _, args)
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
            local success, reason, extraArg1 = lib.callback.await('berkie_menu:server:playerListAction', false, args, data.source, canActOnSelf, message and message[1] or nil)

            if args[1] == teleportVehicleArg then
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
            elseif args[1] == waypointArg then
                SetNewWaypoint(extraArg1.x, extraArg1.y)
            elseif args[1] == blipArg then
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
            elseif args[1] == killArg then
                SetEntityHealth(NetToEnt(extraArg1), 0)
            elseif args[1] == spectateArg then
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
                        previousPos = vec3(0)
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

            if args ~= messageArg then return end

            Wait(500)
            lib.showMenu(formattedId, MenuIndexes[formattedId])
        end)

        lib.setMenuOptions(id, {label = ('[%s] %s'):format(data.source, data.name), args = {formattedId}}, i)
    end
end

--#endregion Functions