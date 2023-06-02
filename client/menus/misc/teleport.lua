--#region Variables

local locations = {}

--#endregion Variables

--#region Functions

function SetupTeleportOptions()
    if table.type(locations) == 'empty' then
        lib.setMenuOptions('bMenu_misc_options_teleport_options', {label = 'Save Teleport Location', description = 'Adds your current location to the teleport locations menu', args = {'save_location'}}, 3)
        lib.setMenuOptions('bMenu_misc_options_teleport_options', nil, 4)
    else
        lib.setMenuOptions('bMenu_misc_options_teleport_options', {label = 'Teleport Locations', description = 'Teleport to pre-configured locations', args = {'bMenu_misc_options_teleport_options_locations'}}, 3)
        lib.setMenuOptions('bMenu_misc_options_teleport_options', {label = 'Save Teleport Location', description = 'Adds your current location to the teleport locations menu', args = {'save_location'}}, 4)
    end
end

local function refreshLocations()
    local newLocations = lib.callback.await('bMenu:server:getConfig', false, 'locations')

    if newLocations and type(newLocations) == 'table' then
        for i = 1, #newLocations do
            locations[i] = newLocations[i]
        end
    end
end

local function teleportToCoords(pos)
    local vehicleRestoreVisibility = IsInVehicle(true) and IsEntityVisible(cache.vehicle)
    local pedRestoreVisibility = IsEntityVisible(cache.ped)

    if IsInVehicle(true) then
        FreezeEntityPosition(cache.vehicle, true)
        if IsEntityVisible(cache.vehicle) then
            NetworkFadeOutEntity(cache.vehicle, true, false)
        end
    else
        ClearPedTasksImmediately(cache.ped)
        FreezeEntityPosition(cache.ped, true)
        if IsEntityVisible(cache.ped) then
            NetworkFadeOutEntity(cache.ped, true, false)
        end
    end

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    local groundZ = 850
    local found = false
    for zz = 950, 0, -25 do
        local z = zz
        if zz % 2 ~= 0 then
            z = 950 - zz
        end

        RequestCollisionAtCoord(pos.x, pos.y, z)

        NewLoadSceneStart(pos.x, pos.y, z, pos.x, pos.y, z, 50, 0)

        local tempTimer = GetGameTimer()

        while IsNetworkLoadingScene() do
            if GetGameTimer() - tempTimer > 1000 then
                break
            end
            Wait(0)
        end

        SetEntityCoords(IsInVehicle(true) and cache.vehicle or cache.ped, pos.x, pos.y, z, false, false, false, true)

        tempTimer = GetGameTimer()

        while not HasCollisionLoadedAroundEntity(cache.ped) do
            if GetGameTimer() - tempTimer > 1000 then
                return
            end
            Wait(0)
        end

        found, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, z, false)

        if found then
            if IsInVehicle(true) then
                SetEntityCoords(cache.vehicle, pos.x, pos.y, groundZ, false, false, false, true)
                FreezeEntityPosition(cache.vehicle, false)
                SetVehicleOnGroundProperly(cache.vehicle)
                FreezeEntityPosition(cache.vehicle, true)
            else
                SetEntityCoords(cache.ped, pos.x, pos.y, groundZ, false, false, false, true)
            end
            break
        end

        Wait(10)
    end

    if not found then
        local result, safePos = GetNthClosestVehicleNode(pos.x, pos.y, pos.z, 0, 0, 0, 0)
        if not result or not safePos then
            safePos = pos
        end

        if IsInVehicle(true) then
            SetEntityCoords(cache.vehicle, safePos.x, safePos.y, safePos.z, false, false, false, true)
            FreezeEntityPosition(cache.vehicle, false)
            SetVehicleOnGroundProperly(cache.vehicle)
            FreezeEntityPosition(cache.vehicle, true)
        else
            SetEntityCoords(cache.ped, safePos.x, safePos.y, safePos.z, false, false, false, true)
        end
    end

    if IsInVehicle(true) then
        if vehicleRestoreVisibility then
            NetworkFadeInEntity(cache.vehicle, true)
            if not pedRestoreVisibility then
                SetEntityVisible(cache.ped, false, false)
            end
        end
        FreezeEntityPosition(cache.vehicle, false)
    else
        if pedRestoreVisibility then
            NetworkFadeInEntity(cache.ped, true)
        end
        FreezeEntityPosition(cache.ped, false)
    end

    DoScreenFadeIn(500)
    SetGameplayCamRelativePitch(0.0, 1.0)
end

--#endregion Functions

--#region Menu Registration

lib.registerMenu({
    id = 'bMenu_misc_options_teleport_options',
    title = 'Teleport Options',
    position = MenuPosition,
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'bMenu_misc_options')
    end,
    onSelected = function(selected)
        MenuIndexes['bMenu_misc_options_teleport_options'] = selected
    end,
    options = {
        {label = 'Teleport To Waypoint', args = {'teleport_waypoint'}, close = false},
        {label = 'Teleport To Coords', args = {'teleport_coords'}},
        {label = 'Teleport Locations', description = 'Teleport to pre-configured locations', args = {'bMenu_misc_options_teleport_options_locations'}},
        {label = 'Save Teleport Location', description = 'Adds your current location to the teleport locations menu', args = {'save_location'}}
    }
}, function(_, _, args)
    if args[1] == 'teleport_waypoint' then
        local blipMarker = GetFirstBlipInfoId(8)
        if not DoesBlipExist(blipMarker) then
            lib.notify({
                description = 'No waypoint set',
                type = 'error'
            })
            return
	end
        local waypointBlipInfo = GetFirstBlipInfoId(GetWaypointBlipEnumId())
        local waypointBlipPos = waypointBlipInfo ~= 0 and GetBlipInfoIdType(waypointBlipInfo) == 4 and GetBlipInfoIdCoord(waypointBlipInfo) or vec2(0, 0)
        RequestCollisionAtCoord(waypointBlipPos.x, waypointBlipPos.y, 1000)
        local result, z = GetGroundZFor_3dCoord(waypointBlipPos.x, waypointBlipPos.y, 1000, false)
        if not result then
            z = 0
        end
        waypointBlipPos = vec3(waypointBlipPos.x, waypointBlipPos.y, z)
        teleportToCoords(waypointBlipPos)
    elseif args[1] == 'teleport_coords' then
        local dialog = lib.inputDialog('Teleport To Coords', {'Coords'})

        if not dialog or not dialog[1] or dialog[1] == '' then
            Wait(200)
            lib.showMenu('bMenu_misc_options_teleport_options', MenuIndexes['bMenu_misc_options_teleport_options'])
            return
        end

        local actualValues = {}
        for word in dialog[1]:gmatch('[^,]*') do
            local val = tonumber(word)
            if val then
                actualValues[#actualValues + 1] = val
            end
        end

        if #actualValues < 3 then
            lib.notify({
                description = 'Wrong format used, the format is `x, y, z`',
                type = 'error'
            })
            Wait(200)
            lib.showMenu('bMenu_misc_options_teleport_options', MenuIndexes['bMenu_misc_options_teleport_options'])
            return
        end

        for i = 4, #actualValues do
            actualValues[i] = nil
        end

        SetEntityCoords(cache.ped, actualValues[1], actualValues[2], actualValues[3], true, false, false, false)

        Wait(200)
        lib.showMenu('bMenu_misc_options_teleport_options', MenuIndexes['bMenu_misc_options_teleport_options'])
    elseif args[1] == 'bMenu_misc_options_teleport_options_locations' then
        lib.setMenuOptions('bMenu_misc_options_teleport_options_locations', {[1] = true})
        for i = 1, #locations do
            lib.setMenuOptions('bMenu_misc_options_teleport_options_locations', {label = locations[i].name, args = locations[i], close = false}, i)
        end
        lib.showMenu(args[1], MenuIndexes[args[1]])
    elseif args[1] == 'save_location' then
        local dialog = lib.inputDialog('Save Location', {'Location Name'})

        if not dialog or not dialog[1] or dialog[1] == '' then
            Wait(200)
            lib.showMenu('bMenu_misc_options_teleport_options', MenuIndexes['bMenu_misc_options_teleport_options'])
            return
        end

        local result, notification = lib.callback.await('bMenu:server:saveTeleportLocation', false, dialog[1])

        lib.notify({
            description = notification,
            type = result and 'success' or 'error'
        })

        refreshLocations()
        SetupTeleportOptions()

        Wait(200)
        lib.showMenu('bMenu_misc_options_teleport_options', MenuIndexes['bMenu_misc_options_teleport_options'])
    end
end)

lib.registerMenu({
    id = 'bMenu_misc_options_teleport_options_locations',
    title = 'Teleport Locations',
    position = MenuPosition,
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'bMenu_misc_options_teleport_options')
    end,
    onSelected = function(selected)
        MenuIndexes['bMenu_misc_options_teleport_options_locations'] = selected
    end,
    options = {}
}, function(_, _, args)
    SetEntityCoords(cache.ped, args.coords.x, args.coords.y, args.coords.z, true, false, false, false)
    SetEntityHeading(cache.ped, args.heading)
    lib.notify({
        description = ('Successfully teleport to %s'):format(args.name),
        type = 'success'
    })
end)

--#endregion Menu Registration

--#region Threads

CreateThread(function()
    refreshLocations()
end)

--#endregion Threads
