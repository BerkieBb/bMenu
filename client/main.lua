local menuOpen = false
local playerId = PlayerId()
local serverId = GetPlayerServerId(playerId)
local playerBlips = {}
local itemsOnYourself = { -- Put the last part of the argument of the option that you want to be able to use on yourself in here
    '_kill',
}
local vehicles = {}
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
    [22] = 'Open Wheel',
    [69] = 'Misc'
}
local showEffects = true -- Show effects when going in and out of noclip or when teleporting
local spawnInVehicle = true -- Teleport into the vehicle you're spawning
local replacePreviousVehicle = false -- Replace the previous vehicle you were in when spawning a new vehicle

local function firstToUpper(str)
    return str:gsub("^%l", string.upper)
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

local function getVehiclesFromClassName(className)
    local result = {}
    for _, v in pairs(vehicles) do
        if v.className == className then
            result[#result+1] = v
        end
    end
    return result
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

local function spawnVehicleOnPlayer(model)
    if not IsModelAVehicle(model) then return end

    local speed = 0.0
    local rpm = 0.0

    if IsPedInAnyVehicle(cache.ped, false) and spawnInVehicle then
        local oldVeh = GetVehiclePedIsIn(cache.ped, false)
        speed = GetEntitySpeedVector(oldVeh, true).y
        rpm = GetVehicleCurrentRpm(oldVeh)
    end

    lib.requestModel(model)

    local otherCoords = spawnInVehicle and GetEntityCoords(cache.ped, true) or GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 8.0, 0.0)
    local coords = vec4(otherCoords.x, otherCoords.y, otherCoords.z + 1, GetEntityHeading(cache.ped) + (spawnInVehicle and 0 or 90))

    local previousVehicle = GetVehiclePedIsIn(cache.ped, true)

    if previousVehicle ~= 0 then
        if IsVehiclePreviouslyOwnedByPlayer(previousVehicle) and ((GetVehicleNumberOfPassengers(previousVehicle) and IsVehicleSeatFree(previousVehicle, -1)) or GetPedInVehicleSeat(previousVehicle, -1) == cache.ped) then
            if replacePreviousVehicle then
                SetVehicleHasBeenOwnedByPlayer(previousVehicle, false)
                SetEntityAsMissionEntity(previousVehicle, false, true)
                DeleteEntity(previousVehicle)
            else
                SetEntityAsMissionEntity(previousVehicle, false, false)
            end
            previousVehicle = 0
        end
    end

    if IsPedInAnyVehicle(cache.ped, false) and replacePreviousVehicle then
        local tempVeh = GetVehiclePedIsIn(cache.ped, false)
        SetVehicleHasBeenOwnedByPlayer(tempVeh, false)
        SetEntityAsMissionEntity(cache.ped, true, true)

        if previousVehicle ~= 0 and previousVehicle == tempVeh then
            previousVehicle = 0
        end

        SetEntityAsMissionEntity(tempVeh, false, true)
        DeleteEntity(tempVeh)
        tempVeh = 0
    end

    if previousVehicle ~= 0 then
        SetVehicleHasBeenOwnedByPlayer(previousVehicle, false)
    end

    if IsPedInAnyVehicle(cache.ped, false) then
        local _, dimensionMax = GetModelDimensions(model)
        local offset = GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(cache.ped, false), 0, dimensionMax.y, 0.0) - vec3(0, 6, 0)
        coords = vec4(offset.x, offset.y, offset.z, coords.w)
    end

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, false)
    SetVehicleIsStolen(vehicle, false)
    SetVehicleIsWanted(vehicle, false)

    if spawnInVehicle then
        SetVehicleEngineOn(vehicle, true, true, true)

        SetPedIntoVehicle(cache.ped, vehicle, -1)

        if GetVehicleClass(vehicle) == 15 and GetEntityHeightAboveGround(vehicle) > 10 then
            SetHeliBladesFullSpeed(vehicle)
        else
            SetVehicleOnGroundProperly(vehicle)
        end
    end

    if not IsThisModelATrain(model) then -- I don't know why, but it's to be careful, so never remove this
        SetVehicleForwardSpeed(vehicle, speed)
    end

    SetVehicleCurrentRpm(vehicle, rpm)

    SetVehicleRadioEnabled(vehicle, true)
    SetVehRadioStation(vehicle, "OFF")

    SetModelAsNoLongerNeeded(model)

    return vehicle
end

local function createVehiclesForSpawner(vehs, id)
    for i = 1, #vehs do
        local data = vehs[i]
        local label = GetLabelText(GetDisplayNameFromVehicleModel(data.model))
        label = label ~= "NULL" and label or GetDisplayNameFromVehicleModel(data.model)
        label = label ~= "CARNOTFOUND" and label or data.modelName
        lib.setMenuOptions(id, {label = firstToUpper(label:lower()), args = data.model, close = false}, i)
    end
end

local function createVehicleSpawnerMenu()
    local id = 'berkie_menu_vehicle_spawner'
    local i = 4
    for _, v in pairs(vehicleClassNames) do
        local formattedId = ('%s_%s'):format(id, v)
        local vehs = getVehiclesFromClassName(v)

        if table.type(vehs) == 'empty' then goto skipLoop end

        lib.registerMenu({
            id = formattedId,
            title = v,
            position = 'top-right',
            onClose = function(keyPressed)
                closeMenu(false, keyPressed, id)
            end,
            options = {}
        }, function(_, _, args)
            spawnVehicleOnPlayer(args)
        end)

        lib.setMenuOptions(id, {label = v, args = formattedId}, i)

        createVehiclesForSpawner(vehs, formattedId)
        i += 1

        :: skipLoop ::
    end
end

lib.registerMenu({
    id = 'berkie_menu_main',
    title = 'Berkie Menu',
    position = 'top-right',
    onClose = function()
        closeMenu(true)
    end,
    options = {
        {label = 'Online Players', icon = 'user-group', args = 'berkie_menu_online_players'},
        {label = 'Player Related Options', icon = 'user-gear', args = 'berkie_menu_player_related_options'},
        {label = 'Vehicle Related Options', icon = 'car', args = 'berkie_menu_vehicle_related_options'},
        {label = 'Recording Options', icon = 'video', args = 'berkie_menu_recording_options'},
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
    id = 'berkie_menu_vehicle_related_options',
    title = 'Vehicle Related Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_main')
    end,
    options = {
        {label = 'Options', icon = 'wrench', description = 'Common vehicle options including tuning and styling', args = 'berkie_menu_vehicle_options'},
        {label = 'Spawner', icon = 'car', description = 'Spawn any vehicle that is registered in the game, including addon vehicles', args = 'berkie_menu_vehicle_spawner'},
        {label = 'Personal Vehicle', icon = 'user-gear', description = 'Control your personal vehicle or change it', args = 'berkie_menu_vehicle_personal'}
    }
}, function(_, _, args)
    if args == 'berkie_menu_vehicle_spawner' then
        createVehicleSpawnerMenu()
    end
    lib.showMenu(args)
end)

lib.registerMenu({
    id = 'berkie_menu_vehicle_spawner',
    title = 'Vehicle Spawner',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_vehicle_related_options')
    end,
    onSideScroll = function(_, scrollIndex, args)
        if args == 'berkie_menu_vehicle_spawner_inside_vehicle' then
            spawnInVehicle = scrollIndex == 1
            lib.setMenuOptions('berkie_menu_vehicle_spawner', {label = 'Spawn Inside Vehicle', description = 'This will teleport you into the vehicle when it spawns', args = 'berkie_menu_vehicle_spawner_inside_vehicle', values = {'Yes', 'No'}, defaultIndex = spawnInVehicle and 1 or 2, close = false}, 2)
        elseif args == 'berkie_menu_vehicle_spawner_replace_vehicle' then
            replacePreviousVehicle = scrollIndex == 1
            lib.setMenuOptions('berkie_menu_vehicle_spawner', {label = 'Replace Previous Vehicle', description = 'This will delete the vehicle you were previously in when spawning a new vehicle', args = 'berkie_menu_vehicle_spawner_replace_vehicle', values = {'Yes', 'No'}, defaultIndex = replacePreviousVehicle and 1 or 2, close = false}, 3)
        end
    end,
    options = {
        {label = 'Spawn Vehicle By Model Name', description = 'Enter the name of the vehicle you want to spawn', args = 'berkie_menu_vehicle_spawner_by_model'},
        {label = 'Spawn Inside Vehicle', description = 'This will teleport you into the vehicle when it spawns', args = 'berkie_menu_vehicle_spawner_inside_vehicle', values = {'Yes', 'No'}, defaultIndex = spawnInVehicle and 1 or 2, close = false},
        {label = 'Replace Previous Vehicle', description = 'This will delete the vehicle you were previously in when spawning a new vehicle', args = 'berkie_menu_vehicle_spawner_replace_vehicle', values = {'Yes', 'No'}, defaultIndex = replacePreviousVehicle and 1 or 2, close = false}
    }
}, function(_, _, args)
    if args == 'berkie_menu_vehicle_spawner_inside_vehicle' or args == 'berkie_menu_vehicle_spawner_replace_vehicle' then return end

    if args == 'berkie_menu_vehicle_spawner_by_model' then
        local vehicle = lib.inputDialog('test', {'Vehicle Model Name'})
        if vehicle and table.type(vehicle) ~= 'empty' then
            local model = joaat(vehicle[1])
            if IsModelInCdimage(model) then
                spawnVehicleOnPlayer(model)
            end
        end
        Wait(500)
        args = 'berkie_menu_vehicle_spawner'
    end

    lib.showMenu(args)
end)

lib.registerMenu({
    id = 'berkie_menu_miscellaneous_options',
    title = 'Miscellaneous Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSideScroll = function(_, scrollIndex, args)
        if args then return end
        showEffects = scrollIndex == 1
        lib.setMenuOptions('berkie_menu_miscellaneous_options', {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', values = {'Yes', 'No'}, defaultIndex = showEffects and 1 or 2, close = false}, 1)
    end,
    options = {
        {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', values = {'Yes', 'No'}, defaultIndex = showEffects and 1 or 2, close = false}
    }
}, function(_, _, args)
    if not args then return end
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
        local vehicleClassName = vehicleClassNames[vehicleClass] or vehicleClassNames[69]
        vehicles[model] = {
            name = modelName,
            model = model,
            class = vehicleClassName ~= vehicleClassNames[69] and vehicleClass or 69,
            className = vehicleClassName
        }
    end
end)