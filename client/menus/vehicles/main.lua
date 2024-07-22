--#region Variables

Vehicles = {}
VehicleDefaultRadio = 'OFF'

--#endregion Variables

--#region Functions

function IsInVehicle(checkDriver)
    if not cache.vehicle then
        return false, 'You need to be in a vehicle to perform this action'
    end

    if checkDriver and cache.seat ~= -1 then
        return false, 'You need to be the driver of the vehicle to perform this action'
    end

    return true
end

function CreateVehicleOptionsMenu()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, 'VehicleRelated', {'Options', 'PersonalVehicle', 'Spawner'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_main'}}
    }
    local index = 1

    if perms.Options then
        menuOptions[index] = {label = 'Options', icon = 'wrench', description = 'Common vehicle options including tuning and styling', args = {'bMenu_vehicle_options'}}
        index += 1
    end

    if perms.PersonalVehicle then
        menuOptions[index] = {label = 'Personal Vehicle', icon = 'user-gear', description = 'Control your personal vehicle or change it', args = {'bMenu_vehicle_personal'}}
        index += 1
    end

    if perms.Spawner then
        menuOptions[index] = {label = 'Spawner', icon = 'car', description = 'Spawn any vehicle that is registered in the game, including addon vehicles', args = {'bMenu_vehicle_spawner'}}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_vehicle_related_options',
        title = 'Vehicle Related Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_main')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_vehicle_related_options'] = selected
        end,
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'bMenu_vehicle_options' then
            SetupVehicleOptionsMenu()
        elseif args[1] == 'bMenu_vehicle_personal' then
            SetupVehiclePersonalMenu()
        elseif args[1] == 'bMenu_vehicle_spawner' then
            SetupVehicleSpawnerMenu()
        end

        lib.showMenu(args[1], MenuIndexes[args[1]])
    end)
end

--#endregion Functions