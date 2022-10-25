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

--#endregion Functions

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_vehicle_related_options',
    title = 'Vehicle Related Options',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_vehicle_related_options'] = selected
    end,
    options = {
        {label = 'Options', icon = 'wrench', description = 'Common vehicle options including tuning and styling', args = 'berkie_menu_vehicle_options'},
        {label = 'Spawner', icon = 'car', description = 'Spawn any vehicle that is registered in the game, including addon vehicles', args = 'berkie_menu_vehicle_spawner'},
        {label = 'Personal Vehicle', icon = 'user-gear', description = 'Control your personal vehicle or change it', args = 'berkie_menu_vehicle_personal'}
    }
}, function(_, _, args)
    if args == 'berkie_menu_vehicle_spawner' then
        CreateVehicleSpawnerMenu()
    end

    lib.showMenu(args, MenuIndexes[args])
end)

--#endregion Menu Registration

--[[
    TODO

        Add IsInVehicle check at every vehicle menu
]]