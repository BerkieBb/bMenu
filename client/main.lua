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
local vehicleDoorBoneNames = {
    [0] = 'door_dside_f',
    [1] = 'door_pside_f',
    [2] = 'door_dside_r',
    [3] = 'door_pside_r',
    [4] = 'bonnet',
    [5] = 'boot'
}
local showEffects = true -- Show effects when going in and out of noclip or when teleporting
local spawnInVehicle = true -- Teleport into the vehicle you're spawning
local replacePreviousVehicle = true -- Replace the previous vehicle you were in when spawning a new vehicle
local vehicleGodMode = false
local vehicleInvincible = false
local vehicleEngineDamage = false
local vehicleVisualDamage = false
local vehicleStrongWheels = false
local vehicleRampDamage = false
local vehicleAutoRepair = false

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
    table.sort(vehs, function(a, b)
        return a.name < b.name
    end)

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
    id = 'berkie_menu_vehicle_options',
    title = 'Vehicle Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_vehicle_related_options')
    end,
    onSideScroll = function(_, scrollIndex, args)
        if args == 'berkie_menu_vehicle_options_god_mode_enable' then
            vehicleGodMode = scrollIndex == 1
            lib.setMenuOptions('berkie_menu_vehicle_options', {label = 'Vehicle God Mode', description = 'Makes your vehicle not take any damage. What kind of damage will be stopped is defined in the God Mode Options', args = 'berkie_menu_vehicle_options_god_mode_enable', values = {'Yes', 'No'}, defaultIndex = vehicleGodMode and 1 or 2, close = false}, 1)
        end
    end,
    options = {
        {label = 'Vehicle God Mode', description = 'Makes your vehicle not take any damage. What kind of damage will be stopped is defined in the God Mode Options', args = 'berkie_menu_vehicle_options_god_mode_enable', values = {'Yes', 'No'}, defaultIndex = vehicleGodMode and 1 or 2, close = false},
        {label = 'God Mode Options', description = 'Enable or disable specific damage types', args = 'berkie_menu_vehicle_options_god_mode_menu'}
    }
}, function(_, scrollIndex, args)
    if scrollIndex then return end
    lib.showMenu(args)
end)

lib.registerMenu({
    id = 'berkie_menu_vehicle_options_god_mode_menu',
    title = 'Vehicle God Mode Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_vehicle_options')
    end,
    onSideScroll = function(_, scrollIndex, args)
        local val = scrollIndex == 1 and vehicleGodMode
        if args == 'invincible' then
            if val == vehicleInvincible then return end
            vehicleInvincible = val
            lib.setMenuOptions('berkie_menu_vehicle_options_god_mode_menu', {label = 'Invincible', description = 'Makes the car invincible, includes fire damage, explosion damage, collision damage and more', args = 'invincible', values = {'Yes', 'No'}, defaultIndex = vehicleInvincible and 1 or 2, close = false}, 1)
        elseif args == 'engine_damage' then
            if val == vehicleEngineDamage then return end
            vehicleEngineDamage = val
            lib.setMenuOptions('berkie_menu_vehicle_options_god_mode_menu', {label = 'Engine Damage', description = 'Disables your engine from taking any damage', args = 'engine_damage', values = {'Yes', 'No'}, defaultIndex = vehicleEngineDamage and 1 or 2, close = false}, 2)
        elseif args == 'visual_damage' then
            if val == vehicleVisualDamage then return end
            vehicleVisualDamage = val
            lib.setMenuOptions('berkie_menu_vehicle_options_god_mode_menu', {label = 'Visual Damage', description = 'This prevents scratches and other damage decals from being applied to your vehicle. It does not prevent (body) deformation damage', args = 'visual_damage', values = {'Yes', 'No'}, defaultIndex = vehicleVisualDamage and 1 or 2, close = false}, 3)
        elseif args == 'strong_wheels' then
            if val == vehicleStrongWheels then return end
            vehicleStrongWheels = val
            lib.setMenuOptions('berkie_menu_vehicle_options_god_mode_menu', {label = 'Strong Wheels', description = 'Disables your wheels from being deformed and causing reduced handling. This does not make tires bulletproof', args = 'strong_wheels', values = {'Yes', 'No'}, defaultIndex = vehicleStrongWheels and 1 or 2, close = false}, 4)
        elseif args == 'ramp_damage' then
            if val == vehicleRampDamage then return end
            vehicleRampDamage = val
            lib.setMenuOptions('berkie_menu_vehicle_options_god_mode_menu', {label = 'Ramp Damage', description = 'Disables vehicles such as the Ramp Buggy from taking any damage when using the ramp', args = 'ramp_damage', values = {'Yes', 'No'}, defaultIndex = vehicleRampDamage and 1 or 2, close = false}, 5)
        elseif args == 'auto_repair' then
            if val == vehicleAutoRepair then return end
            vehicleAutoRepair = val
            lib.setMenuOptions('berkie_menu_vehicle_options_god_mode_menu', {label = 'Auto Repair', description = 'Automatically repairs your vehicle when it has ANY type of damage. It\'s recommended to keep this turned off to prevent glitchyness', args = 'auto_repair', values = {'Yes', 'No'}, defaultIndex = vehicleAutoRepair and 1 or 2, close = false}, 6)
        end
    end,
    options = {
        {label = 'Invincible', description = 'Makes the car invincible, includes fire damage, explosion damage, collision damage and more', args = 'invincible', values = {'Yes', 'No'}, defaultIndex = vehicleInvincible and 1 or 2, close = false},
        {label = 'Engine Damage', description = 'Disables your engine from taking any damage', args = 'engine_damage', values = {'Yes', 'No'}, defaultIndex = vehicleEngineDamage and 1 or 2, close = false},
        {label = 'Visual Damage', description = 'This prevents scratches and other damage decals from being applied to your vehicle. It does not prevent (body) deformation damage', args = 'visual_damage', values = {'Yes', 'No'}, defaultIndex = vehicleVisualDamage and 1 or 2, close = false},
        {label = 'Strong Wheels', description = 'Disables your wheels from being deformed and causing reduced handling. This does not make tires bulletproof', args = 'strong_wheels', values = {'Yes', 'No'}, defaultIndex = vehicleStrongWheels and 1 or 2, close = false},
        {label = 'Ramp Damage', description = 'Disables vehicles such as the Ramp Buggy from taking any damage when using the ramp', args = 'ramp_damage', values = {'Yes', 'No'}, defaultIndex = vehicleRampDamage and 1 or 2, close = false},
        {label = 'Auto Repair', description = 'Automatically repairs your vehicle when it has ANY type of damage. It\'s recommended to keep this turned off to prevent glitchyness', args = 'auto_repair', values = {'Yes', 'No'}, defaultIndex = vehicleAutoRepair and 1 or 2, close = false}
    }
})

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
}, function(_, scrollIndex, args)
    if scrollIndex then return end

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

    while true do
        local sleep = 200
        if cache.vehicle then
            sleep = 0
            if vehicleGodMode then
                local veh = cache.vehicle

                SetVehicleReceivesRampDamage(veh, not vehicleRampDamage)

                if vehicleVisualDamage then
                    RemoveDecalsFromVehicle(veh)
                end

                if vehicleAutoRepair then
                    SetVehicleFixed(veh)
                end

                SetVehicleCanBeVisiblyDamaged(veh, not vehicleVisualDamage)
                SetVehicleEngineCanDegrade(veh, not vehicleEngineDamage)

                if vehicleEngineDamage and GetVehicleEngineHealth(veh) < 1000.0 then
                    SetVehicleEngineHealth(veh, 1000.0)
                end

                SetVehicleWheelsCanBreak(veh, not vehicleStrongWheels)
                SetVehicleHasStrongAxles(veh, vehicleStrongWheels)

                local memoryAddress = Citizen.InvokeNative(`GET_ENTITY_ADDRESS`, veh)
                if not memoryAddress then
                    goto skipAddresses
                end

                memoryAddress += 392

                local setter = vehicleInvincible and SetBit or ClearBit

                ---@diagnostic disable
                setter(memoryAddress, 4) -- IsBulletProof
                setter(memoryAddress, 5) -- IsFireProof
                setter(memoryAddress, 6) -- IsCollisionProof
                setter(memoryAddress, 7) -- IsMeleeProof
                setter(memoryAddress, 11) -- IsExplosionProof
                ---@diagnostic enable

                SetEntityInvincible(vehicle, vehicleInvincible)

                for i = 0, 5 do
                    if GetEntityBoneIndexByName(veh, vehicleDoorBoneNames[i]) ~= -1 then
                        SetVehicleDoorCanBreak(veh, i, not vehicleInvincible)
                    end
                end

                :: skipAddresses ::
            end
        else

        end
        Wait(sleep)
    end
end)

--[[
    vehicle options menu:

Vehicle God Mode (yes or no)
God Mode options:
  invincible (yes or no)
  engine damage (yes or no)
  visual damage (yes or no)
  strong wheels (yes or no)
  ramp damage (yes or no)
  auto repair (yes or no)
repair vehicle (option)
keep vehicle clean (yes or no)
wash vehicle (option)
set dirt level (0-15)
mod menu:
  generate options
colors:
  primary color:
  secondary color:
  chrome (option)
  enveff scale (nog kijken)
  generaten:
neon kits:
  front light (yes or no)
  rear light (yes or no)
  left light (yes or no)
  right light (yes or no)
  color (selection)
liveries:
  generate, don't show if no liveries
extras:
  generate, don't show if no extras
toggle engine on/off (option)
set license plate text (input)
license plate type (selection)
vehicle doors:
  generate
  open all doors (option)
  close all doors (option)
  remove door (selection)
  delete removed doors (yes or no)
vehicle windows:
  roll down and roll up (option)
bike seatbelt (yes or no)
speed limiter (selection to input)
enable torque multiplier (yes or no)
set engine torque multiplier (selection)
enable power multiplier (yes or no)
set engine power multiplier (selection)
disable plane turbulence (yes or no)
flip vehicle (option)
toggle vehicle alarm (option)
cycle through vehicle seats (option)
vehicle lights (selection)
fix / destroy tires (selection)
freeze vehicle (yes or no)
set vehicle visibility (yes or no)
engine always on (yes or no)
infinite fuel (yes or no)
show vehicle health (yes or no)
default radio station (yes or no)
disable siren (yes or no)
no bike helmet (yes or no)
flash highbeams on honk (yes or no)
delete vehicle:
  confirm or go back
]]