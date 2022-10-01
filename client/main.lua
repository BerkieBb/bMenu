local menuOpen = false
local playerId = PlayerId()
local serverId = GetPlayerServerId(playerId)
local playerBlips = {}
local itemsOnYourself = { -- Put the last part of the argument of the option that you want to be able to use on yourself in here
    '_kill',
}
local vehicleClassNames = {
    [0] = 'Compacts',
    [1] = 'Sedans',
    [2] = 'SUVs',
    [3] = 'Coupes',
    [4] = 'Muscle',
    [5] = 'Sports Classics',
    [6] = 'Sports',
    [7] = 'Super',
    [8] = 'Motorcycles',
    [9] = 'Off-road',
    [10] = 'Industrial',
    [11] = 'Utility',
    [12] = 'Vans',
    [13] = 'Cycles',
    [14] = 'Boats',
    [15] = 'Helicopters',
    [16] = 'Planes',
    [17] = 'Service',
    [18] = 'Emergency',
    [19] = 'Military',
    [20] = 'Commercial',
    [21] = 'Trains',
    [22] = 'Open Wheel'
}
local vehicleClassNumbers  = {}

for k, v in pairs(vehicleClassNames) do
    vehicleClassNumbers[v] = k
end

local function arrayIncludes(value, array, useFormat)
    for i = 1, #array do
        local arrayVal = array[i]
        if useFormat and string.find(value, arrayVal) or value == arrayVal then
            return true
        end
    end

    return false
end

local function closeMenu(isFullMenuClose, keyPressed, previousMenu)
    if isFullMenuClose or not keyPressed or keyPressed == 'Escape' then
        lib.hideMenu(false)
        menuOpen = false
        return
    end

    lib.showMenu(previousMenu)
end

local function createPlayerMenu()
    local id = 'berkie_menu_online_players'
    local onlinePlayers = lib.callback.await('berkie_menu:server:getOnlinePlayers', false)
    for i = 1, #onlinePlayers do
        local data = onlinePlayers[i]
        local formattedId = ('%s_%s'):format(id, i)
        local messageArg = ('%s_message'):format(formattedId)
        local teleportArg = ('%s_teleport'):format(formattedId)
        local teleportVehicleArg = ('%s_teleport_vehicle'):format(formattedId)
        local summonArg = ('%s_summon'):format(formattedId)
        local spectateArg = ('%s_spectate'):format(formattedId)
        local waypointArg = ('%s_waypoint'):format(formattedId)
        local blipArg = ('%s_blip'):format(formattedId)
        local killArg = ('%s_kill'):format(formattedId)
        lib.registerMenu({
            id = formattedId,
            title = data.name,
            position = 'top-right',
            onClose = function(keyPressed)
                closeMenu(false, keyPressed, id)
            end,
            options = {
                {label = 'Send Message', icon = 'comment-dots', description = 'Send a message to this player, note that staff can see these', args = messageArg, close = true},
                {label = 'Teleport To Player', icon = 'hat-wizard', description = 'Teleport to the player', args = teleportArg, close = false},
                {label = 'Teleport Into Vehicle', icon = 'car-side', description = 'Teleport into the vehicle of the player', args = teleportVehicleArg, close = false},
                {label = 'Summon Player', icon = 'hat-wizard', description = 'Summon the player to your location', args = summonArg, close = false},
                {label = 'Spectate Player', icon = 'glasses', description = 'Spectate the player', args = spectateArg, close = false},
                {label = 'Set Waypoint', icon = 'location-dot', description = 'Set your waypoint on the player', args = waypointArg, close = false},
                {label = 'Toggle Blip', icon = 'magnifying-glass-location', description = 'Toggle a blip on the map following the player', args = blipArg, close = false},
                {label = 'Kill Player', icon = 'bullseye', description = 'Kill the player, just because you can', args = killArg, close = false}
            }
        }, function(_, _, args)
            local canActOnSelf = arrayIncludes(args, itemsOnYourself, true)
            if data.source == serverId and not canActOnSelf then
                lib.notify({
                    description = 'You can\'t act on yourself',
                    type = 'error'
                })
                return
            end

            local message = args == messageArg and lib.hideMenu(true) and lib.inputDialog(('Send a message to %s'):format(data.name), {'Message'})

            if args == messageArg and (not message or not message[1] or message[1] == '') then
                Wait(500)
                lib.showMenu(formattedId)
                return
            end

            ---@diagnostic disable-next-line: need-check-nil
            local success, reason, extraArg1 = lib.callback.await('berkie_menu:server:playerListAction', false, args, data.source, canActOnSelf, message and message[1] or nil)

            if args == teleportVehicleArg then
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
            elseif args == waypointArg then
                SetNewWaypoint(extraArg1.x, extraArg1.y)
            elseif args == blipArg then
                if playerBlips[data.source] and DoesBlipExist(playerBlips[data.source]) then
                    RemoveBlip(playerBlips[data.source])
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
            elseif args == killArg then
                SetEntityHealth(NetToEnt(extraArg1), 0)
            end

            lib.notify({
                description = reason,
                type = success and 'success' or 'error'
            })

            if args ~= messageArg then return end

            Wait(500)
            lib.showMenu(formattedId)
        end)

        lib.setMenuOptions(id, {label = ('[%s] %s'):format(data.source, data.name), args = formattedId}, i)
    end
end

lib.registerMenu({
    id = 'berkie_menu_main',
    title = 'Berkie Menu',
    position = 'top-right',
    onSideScroll = function(_, scrollIndex, args)
        if args then return end
        ShowEffects = scrollIndex == 1
        lib.setMenuOptions('berkie_menu_main', {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', values = {'Yes', 'No'}, defaultIndex = ShowEffects and 1 or 2}, 6)
    end,
    onClose = function()
        closeMenu(true)
    end,
    options = {
        {label = 'Online Players', icon = 'user-group', description = 'Show all online players', args = 'berkie_menu_online_players'},
        {label = 'Players Options', icon = 'user-gear', description = 'Show all player related options', args = 'berkie_menu_player_options'},
        {label = 'Vehicle Options', icon = 'car', description = 'Show all vehicle related options', args = 'berkie_menu_vehicle_options'},
        {label = 'Recording Options', icon = 'video', description = 'Show all recording related options', args = 'berkie_menu_recording_options'},
        {label = 'Miscellaneous Options', icon = 'gear', description = 'Show all options that don\'t fit in the other categories', args = 'berkie_menu_miscellaneous_options'}
    }
}, function(_, _, args)
    if args == 'berkie_menu_online_players' then
        createPlayerMenu()
    end

    lib.showMenu(args)
end)

lib.registerMenu({
    id = 'berkie_menu_online_players',
    title = 'Online Players',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_main')
    end,
    options = {}
}, function(_, _, args)
    lib.showMenu(args)
end)

lib.registerMenu({
    id = 'berkie_menu_miscellaneous_options',
    title = 'Miscellaneous Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_main')
    end,
    options = {
        {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', values = {'Yes', 'No'}, defaultIndex = ShowEffects and 1 or 2, close = false}
    }
}, function(_, scrollIndex, args)
    if not args then
        ShowEffects = scrollIndex == 1
        lib.setMenuOptions('berkie_menu_miscellaneous_options', {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', values = {'Yes', 'No'}, defaultIndex = ShowEffects and 1 or 2, close = false}, 1)
        return
    end

    lib.showMenu(args)
end)

RegisterCommand('berkiemenu', function()
    menuOpen = not menuOpen

    if menuOpen then
        lib.showMenu('berkie_menu_main')
    else
        lib.hideMenu(true)
    end
end, type(MenuPermission) == 'string')
RegisterKeyMapping('berkiemenu', 'Open Menu', 'KEYBOARD', 'M')

exports('getCurrentMenuId', lib.getOpenMenu)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() or not menuOpen then return end

    closeMenu(true)
end)

CreateThread(function()
    local vehicleModels = GetAllVehicleModels()
    for i = 1, #vehicleModels do
        local modelName = vehicleModels[i]
        local model = joaat(modelName)
        local vehicleClass = GetVehicleClassFromName(model)
        local vehicleClassName = vehicleClassNames[vehicleClass]
        if not vehicleClassName then
            vehicleClassName = 'Unknown'
        end
    end
end)