--#region Variables

local vehicleClassNames = {
    [0] = GetLabelText('VEH_CLASS_0'), -- Compacts
    [1] = GetLabelText('VEH_CLASS_1'), -- Sedans
    [2] = GetLabelText('VEH_CLASS_2'), -- SUVs
    [3] = GetLabelText('VEH_CLASS_3'), -- Coupes
    [4] = GetLabelText('VEH_CLASS_4'), -- Muscle
    [5] = GetLabelText('VEH_CLASS_5'), -- Sports Classics
    [6] = GetLabelText('VEH_CLASS_6'), -- Sports
    [7] = GetLabelText('VEH_CLASS_7'), -- Super
    [8] = GetLabelText('VEH_CLASS_8'), -- Motorcycles
    [9] = GetLabelText('VEH_CLASS_9'), -- Offroad
    [10] = GetLabelText('VEH_CLASS_10'), -- Industrial
    [11] = GetLabelText('VEH_CLASS_11'), -- Utility
    [12] = GetLabelText('VEH_CLASS_12'), -- Vans
    [13] = GetLabelText('VEH_CLASS_13'), -- Cycles
    [14] = GetLabelText('VEH_CLASS_14'), -- Boats
    [15] = GetLabelText('VEH_CLASS_15'), -- Helicopters
    [16] = GetLabelText('VEH_CLASS_16'), -- Planes
    [17] = GetLabelText('VEH_CLASS_17'), -- Service
    [18] = GetLabelText('VEH_CLASS_18'), -- Emergency
    [19] = GetLabelText('VEH_CLASS_19'), -- Military
    [20] = GetLabelText('VEH_CLASS_20'), -- Commercial
    [21] = GetLabelText('VEH_CLASS_21'), -- Trains
    [22] = GetLabelText('VEH_CLASS_22'), -- Open Wheel
    [69] = 'Misc' -- For any other vehicles that haven't got a class set for some reason.
}

local spawnInVehicle = true -- Teleport into the vehicle you're spawning
local replacePreviousVehicle = true -- Replace the previous vehicle you were in when spawning a new vehicle

--#endregion Variables

--#region Functions

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
        if IsVehiclePreviouslyOwnedByPlayer(previousVehicle) and ((GetVehicleNumberOfPassengers(previousVehicle) == 0 and IsVehicleSeatFree(previousVehicle, -1)) or cache.seat == -1) then
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
        local offset = GetOffsetFromEntityInWorldCoords(cache.vehicle, 0, 10 + GetEntitySpeed(cache.vehicle) / 2, 0)
        coords = vec4(offset.x, offset.y, offset.z, coords.w)
    end

    local netVeh = lib.callback.await('bMenu:server:spawnVehicle', false, model, coords)
    while netVeh == 0 or not DoesEntityExist(NetToVeh(netVeh)) do
        Wait(0)
    end

    local vehicle = NetToVeh(netVeh)
    if vehicle == 0 then
        lib.notify({
            description = 'Something went wrong spawning the vehicle',
            type = 'error'
        })
        return
    end

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
    Wait(10) -- SetVehicleRadioEnabled sets the radio to a random one or the previous one, so we have to wait before overriding it
    SetVehRadioStation(vehicle, VehicleDefaultRadio)

    SetModelAsNoLongerNeeded(model)
end

local function getVehiclesFromClassName(className)
    local result = {}
    for _, v in pairs(Vehicles) do
        if v.className == className then
            result[#result+1] = v
        end
    end
    return result
end

local function createVehiclesForSpawner(vehs, id)
    table.sort(vehs, function(a, b)
        return a.name < b.name
    end)

    for i = 1, #vehs do
        local data = vehs[i]
        local displayName = GetDisplayNameFromVehicleModel(data.model)
        local label = GetLabelText(displayName)
        label = label ~= 'NULL' and label or displayName
        label = label ~= 'CARNOTFOUND' and label or data.modelName
        lib.setMenuOptions(id, {label = ToProperCase(label:lower()), args = {data.model}, close = false}, i)
    end
end

function SetupVehicleSpawnerMenu()
    local id = 'bMenu_vehicle_spawner'
    local sorted = {}
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'VehicleRelated', 'Spawner'}, {'Spawn_By_Name', 'Spawn_In_Vehicle', 'Replace_Previous', 'Spawn_By_Category'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_vehicle_related_options'}}
    }
    local index = 1

    if perms.Spawn_By_Name then
        menuOptions[index] = {label = 'Spawn Vehicle By Model Name', description = 'Enter the name of the vehicle you want to spawn', args = {'spawn_by_model'}}
        index += 1
    end

    if perms.Spawn_In_Vehicle then
        menuOptions[index] = {label = 'Spawn Inside Vehicle', description = 'This will teleport you into the vehicle when it spawns', args = {'inside_vehicle'}, checked = spawnInVehicle, close = false}
        index += 1
    end

    if perms.Replace_Previous then
        menuOptions[index] = {label = 'Replace Previous Vehicle', description = 'This will delete the vehicle you were previously in when spawning a new vehicle', args = {'replace_vehicle'}, checked = replacePreviousVehicle, close = false}
        index += 1
    end

    if perms.Spawn_By_Category then
        for _, v in pairs(vehicleClassNames) do
            sorted[#sorted+1] = v
        end

        table.sort(sorted, function(a, b)
            return a < b
        end)

        for i2 = 1, #sorted do
            local v = sorted[i2]
            local formattedId = ('%s_%s'):format(id, v)
            local vehs = getVehiclesFromClassName(v)

            if table.type(vehs) == 'empty' then goto skipLoop end

            lib.registerMenu({
                id = formattedId,
                title = v,
                position = MenuPosition,
                onClose = function(keyPressed)
                    CloseMenu(false, keyPressed, id)
                end,
                onSelected = function(selected)
                    MenuIndexes[formattedId] = selected
                end,
                options = {}
            }, function(_, _, args)
                spawnVehicleOnPlayer(args[1])
            end)

            menuOptions[index] = {label = v, args = {formattedId}}
            createVehiclesForSpawner(vehs, formattedId)

            index += 1

            :: skipLoop ::
        end
    end

    lib.registerMenu({
        id = id,
        title = 'Vehicle Spawner',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_vehicle_related_options')
        end,
        onSelected = function(selected)
            MenuIndexes[id] = selected
        end,
        onCheck = function(selected, checked, args)
            if args[1] == 'inside_vehicle' then
                spawnInVehicle = checked
                lib.setMenuOptions(id, {label = 'Spawn Inside Vehicle', description = 'This will teleport you into the vehicle when it spawns', args = {'inside_vehicle'}, checked = checked, close = false}, selected)
            elseif args[1] == 'replace_vehicle' then
                replacePreviousVehicle = checked
                lib.setMenuOptions(id, {label = 'Replace Previous Vehicle', description = 'This will delete the vehicle you were previously in when spawning a new vehicle', args = {'replace_vehicle'}, checked = checked, close = false}, selected)
            end
        end,
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'spawn_by_model' then
            local vehicle = lib.inputDialog('Spawn Vehicle', {'Vehicle Model Name'})
            if vehicle and table.type(vehicle) ~= 'empty' then
                local model = joaat(vehicle[1])
                if IsModelInCdimage(model) then
                    spawnVehicleOnPlayer(model)
                else
                    lib.notify({
                        description = ('Vehicle model %s doesn\'t exist in the game'):format(vehicle[1]),
                        type = 'error'
                    })
                end
            end
            Wait(200)
            lib.showMenu(id, MenuIndexes[id])
        elseif args[1] ~= 'inside_vehicle' and args[1] ~= 'replace_vehicle' then
            lib.showMenu(args[1], MenuIndexes[args[1]])
        end
    end)
end

--#endregion Functions

--#region Threads

CreateThread(function()
    local vehicleModels = GetAllVehicleModels()
    for i = 1, #vehicleModels do
        local modelName = vehicleModels[i]
        local model = joaat(modelName)
        local vehicleClass = GetVehicleClassFromName(model)
        local vehicleClassName = vehicleClassNames[vehicleClass] or vehicleClassNames[69]
        Vehicles[model] = {
            name = modelName,
            model = model,
            class = vehicleClassName ~= vehicleClassNames[69] and vehicleClass or 69,
            className = vehicleClassName
        }
    end
end)

--#endregion Threads