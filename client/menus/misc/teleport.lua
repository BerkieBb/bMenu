--#region Variables

local locations = {}

--#endregion Variables

--#region Functions

local function refreshLocations()
    local newLocations = lib.callback.await('bMenu:server:getConfig', false, 'locations')

    if newLocations and type(newLocations) == 'table' then
        for i = 1, #newLocations do
            locations[i] = newLocations[i]
        end
    end
end

local function createLocationsMenu()
    local menuOptions = {}
    for i = 1, #locations do
        menuOptions[i] = {label = locations[i].name, args = locations[i], close = false}
    end

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
        options = menuOptions
    }, function(_, _, args)
        if IsInVehicle(true) then
            SetEntityCoords(cache.vehicle, args.coords.x, args.coords.y, args.coords.z, true, false, false, false)
            SetEntityHeading(currentVeh, args.heading)
        else
            SetEntityCoords(cache.ped, args.coords.x, args.coords.y, args.coords.z, true, false, false, false)
            SetEntityHeading(cache.ped, args.heading)
        end

        lib.notify({
            description = ('Successfully teleport to %s'):format(args.name),
            type = 'success'
        })
    end)
end

function SetupTeleportOptions()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'Misc', 'TeleportOptions'}, {'To_Waypoint', 'To_Coords', 'Locations'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_misc_options'}}
    }
    local index = 1

    if perms.To_Waypoint then
        menuOptions[index] = {label = 'Teleport To Waypoint', args = {'teleport_waypoint'}, close = false}
        index += 1
    end

    if perms.To_Coords then
        menuOptions[index] = {label = 'Teleport To Coords', args = {'teleport_coords'}}
        index += 1
    end

    if perms.Locations then
        if table.type(locations) ~= 'empty' then
            menuOptions[index] = {label = 'Teleport To Location', description = 'Teleport to pre-configured locations', args = {'bMenu_misc_options_teleport_options_locations'}}
            index += 1
        end

        menuOptions[index] = {label = 'Save Teleport Location', description = 'Adds your current location to the teleport locations menu', args = {'save_location'}}
        index += 1
    end

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
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'bMenu_misc_options' then
            lib.showMenu(args[1], MenuIndexes[args[1]])
            return
        end

        if args[1] == 'teleport_waypoint' then
            if not IsWaypointActive() then
                lib.notify({
                    description = 'No waypoint set',
                    type = 'error'
                })
                return
            end

            TeleportToWaypoint()
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

            if IsInVehicle(true) then
                SetEntityCoords(cache.vehicle, actualValues[1], actualValues[2], actualValues[3], true, false, false, false)
            else
                SetEntityCoords(cache.ped, actualValues[1], actualValues[2], actualValues[3], true, false, false, false)
            end

            Wait(200)
            lib.showMenu('bMenu_misc_options_teleport_options', MenuIndexes['bMenu_misc_options_teleport_options'])
        elseif args[1] == 'bMenu_misc_options_teleport_options_locations' then
            createLocationsMenu()
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
end

--#endregion Functions

--#region Commands

RegisterCommand('bMenu_tpToWaypoint', function()
    if not IsScreenFadedIn() or IsPlayerSwitchInProgress() or not IsUsingKeyboard(2) then return end

    if not IsWaypointActive() then
        return lib.notify({
            description = 'There is no waypoint active',
            type = 'error'
        })
    end

    TeleportToWaypoint()
    lib.notify({
        description = 'Teleported to waypoint',
        type = 'success'
    })
end, true)

RegisterKeyMapping('bMenu_tpToWaypoint', 'Teleport to waypoint', 'KEYBOARD', 'F7')

--#endregion Commands

--#region Threads

CreateThread(function()
    refreshLocations()
end)

--#endregion Threads