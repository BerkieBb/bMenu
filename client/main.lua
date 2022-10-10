local menuOpen = false
local playerId = PlayerId()
local serverId = GetPlayerServerId(playerId)
local playerBlips = {}
local itemsOnYourself = { -- Put the last part of the argument of the option that you want to be able to use on yourself in here
    '_kill',
}
local menuIndexes = {}
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
local vehicleModTypes = {
    [0] = {nil, 'Spoilers'},
    [1] = {nil, 'Front Bumper'},
    [2] = {nil, 'Rear Bumper'},
    [3] = {nil, 'Side Skirt'},
    [4] = {nil, 'Exhaust'},
    [5] = {nil, 'Chassis'},
    [6] = {nil, 'Grille'},
    [7] = {nil, 'Hood'},
    [8] = {nil, 'Fender'},
    [9] = {nil, 'Right Fender'},
    [10] = {nil, 'Roof'},
    [11] = {'CMOD_MOD_ENG', 'Engine'},
    [12] = {'CMOD_MOD_BRA', 'Brakes'},
    [13] = {'CMOD_MOD_TRN', 'Transmission'},
    [14] = {'CMOD_MOD_HRN', 'Horns'},
    [15] = {'CMOD_MOD_SUS', 'Suspension'},
    [16] = {'CMOD_MOD_ARM', 'Armor'},
    [18] = {nil, 'Turbo'},
    [22] = {nil, 'Headlights'},
    [23] = {'CMOD_WHE0_0', 'Front Wheel'},
    [24] = {'CMOD_WHE0_1', 'Rear Wheel'},
    [25] = {'CMM_MOD_S0', 'Plate Holder'},
    [26] = {'CMM_MOD_S1', 'Vanity Plates'},
    [27] = {'CMM_MOD_S2', 'Trim Design'},
    [28] = {'CMM_MOD_S3', 'Ornaments'},
    [29] = {'CMM_MOD_S4', 'Dashboard'},
    [30] = {'CMM_MOD_S5', 'Dial Design'},
    [31] = {'CMM_MOD_S6', 'Door Speakers'},
    [32] = {'CMM_MOD_S7', 'Seats'},
    [33] = {'CMM_MOD_S8', 'Steering Wheels'},
    [34] = {'CMM_MOD_S9', 'Column Shifter Levers'},
    [35] = {'CMM_MOD_S10', 'Plaques'},
    [36] = {'CMM_MOD_S11', 'Speakers'},
    [37] = {'CMM_MOD_S12', 'Trunk'},
    [38] = {'CMM_MOD_S13', 'Hydraulics'},
    [39] = {'CMM_MOD_S14', 'Engine Block'},
    [40] = {'CMM_MOD_S15', 'Air Filter'},
    [41] = {'CMM_MOD_S16', 'Struts'},
    [42] = {'CMM_MOD_S17', 'Arch Cover'},
    [43] = {'CMM_MOD_S18', 'Aerials'},
    [44] = {'CMM_MOD_S19', 'Trim'},
    [45] = {'CMM_MOD_S20', 'Tank'},
    [46] = {'CMM_MOD_S21', 'Windows'},
    [47] = {'CMM_MOD_S22', 'Mod 47'},
    [48] = {'CMM_MOD_S23', 'Livery'}
}
local vehicleHornNames = {
    [-1] = {'CMOD_HRN_0', 'Stock Horn'},
    [0] = {'CMOD_HRN_TRK','Truck Horn'},
    [1] = {'CMOD_HRN_COP', 'Cop Horn'},
    [2] = {'CMOD_HRN_CLO', 'Clown Horn'},
    [3] = {'CMOD_HRN_MUS1', 'Musical Horn 1'},
    [4] = {'CMOD_HRN_MUS2', 'Musical Horn 2'},
    [5] = {'CMOD_HRN_MUS3', 'Musical Horn 3'},
    [6] = {'CMOD_HRN_MUS4', 'Musical Horn 4'},
    [7] = {'CMOD_HRN_MUS5', 'Musical Horn 5'},
    [8] = {'CMOD_HRN_SAD', 'Sad Trombone'},
    [9] = {'HORN_CLAS1', 'Classical Horn 1'},
    [10] = {'HORN_CLAS2', 'Classical Horn 2'},
    [11] = {'HORN_CLAS3', 'Classical Horn 3'},
    [12] = {'HORN_CLAS4', 'Classical Horn 4'},
    [13] = {'HORN_CLAS5', 'Classical Horn 5'},
    [14] = {'HORN_CLAS6', 'Classical Horn 6'},
    [15] = {'HORN_CLAS7', 'Classical Horn 7'},
    [16] = {'HORN_CNOTE_C0', 'Scale Do'},
    [17] = {'HORN_CNOTE_D0', 'Scale Re'},
    [18] = {'HORN_CNOTE_E0', 'Scale Mi'},
    [19] = {'HORN_CNOTE_F0', 'Scale Fa'},
    [20] = {'HORN_CNOTE_G0', 'Scale Sol'},
    [21] = {'HORN_CNOTE_A0', 'Scale La'},
    [22] = {'HORN_CNOTE_B0', 'Scale Ti'},
    [23] = {'HORN_CNOTE_C1', 'Scale Do (High)'},
    [24] = {'HORN_HIPS1', 'Jazz Horn 1'},
    [25] = {'HORN_HIPS2', 'Jazz Horn 2'},
    [26] = {'HORN_HIPS3', 'Jazz Horn 3'},
    [27] = {'HORN_HIPS4', 'Jazz Horn Loop'},
    [28] = {'HORN_INDI_1', 'Star Spangled Banner 1'},
    [29] = {'HORN_INDI_2', 'Star Spangled Banner 2'},
    [30] = {'HORN_INDI_3', 'Star Spangled Banner 3'},
    [31] = {'HORN_INDI_4', 'Star Spangled Banner 4'},
    [32] = {'HORN_LUXE2', 'Classical Horn Loop 1'},
    [33] = {'HORN_LUXE1', 'Classical Horn 8'},
    [34] = {'HORN_LUXE3', 'Classical Horn Loop 2'},
    [35] = {'HORN_LUXE2', 'Classical Horn Loop 1'},
    [36] = {'HORN_LUXE1', 'Classical Horn 8'},
    [37] = {'HORN_LUXE3', 'Classical Horn Loop 2'},
    [38] = {'HORN_HWEEN1', 'Halloween Loop 1'},
    [39] = {'HORN_HWEEN1', 'Halloween Loop 1'},
    [40] = {'HORN_HWEEN2', 'Halloween Loop 2'},
    [41] = {'HORN_HWEEN2', 'Halloween Loop 2'},
    [42] = {'HORN_LOWRDER1', 'San Andreas Loop'},
    [43] = {'HORN_LOWRDER1', 'San Andreas Loop'},
    [44] = {'HORN_LOWRDER2', 'Liberty City Loop'},
    [45] = {'HORN_LOWRDER2', 'Liberty City Loop'},
    [46] = {'HORN_XM15_1', 'Festive Loop 1'},
    [47] = {'HORN_XM15_2', 'Festive Loop 2'},
    [48] = {'HORN_XM15_3', 'Festive Loop 3'}
}
local vehicleWheelTypes = {
    [0] = 'Sports',
    [1] = 'Muscle',
    [2] = 'Lowrider',
    [3] = 'SUV',
    [4] = 'Offroad',
    [5] = 'Tuner',
    [6] = 'Bike Wheels',
    [7] = 'High End',
    [8] = 'Benny\'s Original',
    [9] = 'Benny\' Bespoke',
    [10] = 'Open Wheel',
    [11] = 'Street',
    [12] = 'Track'
}
local vehicleModsMenuData = {}
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
local vehicleNeverDirty = false
local vehicleDirtLevelSetter = 0

local function firstToUpper(str)
    return str:gsub('^%l', string.upper)
end

local function toProperCase(str)
    return string.gsub(str, '(%a)([%w_\']*)', function(first, rest)
        return first:upper()..rest:lower()
    end)
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

local function getAllPossibleMods()
    local result = {}
    for k in pairs(vehicleModTypes) do
        local amount = GetNumVehicleMods(cache.vehicle, k)
        if amount > 0 then
            result[k] = amount
        end
    end
    return result
end

local function getModLocalizedType(mod)
    local alt
    local alt2
    local vehModel = GetEntityModel(cache.vehicle)

    if mod == 23 then
        if not IsThisModelABike(vehModel) and IsThisModelABicycle(vehModel) then
            alt = 'CMOD_MOD_WHEM'
            alt2 = 'Wheels'
        end
    elseif mod == 27 then
        if vehModel == `sultanrs` then
            alt = 'CMM_MOD_S2b'
        end
    elseif mod == 40 then
        if vehModel == `sultanrs` then
            alt = 'CMM_MOD_S15b'
        end
    elseif mod == 41 then
        if vehModel == `sultanrs` or vehModel == `banshee2` then
            alt = 'CMM_MOD_S16b'
        end
    elseif mod == 42 then
        if vehModel == `sultanrs` then
            alt = 'CMM_MOD_S17b'
        end
    elseif mod == 43 then
        if vehModel == `sultanrs` then
            alt = 'CMM_MOD_S18b'
        end
    elseif mod == 44 then
        if vehModel == `sultanrs` then
            alt = 'CMM_MOD_S19b'
        elseif vehModel == `btype3` then
            alt = 'CMM_MOD_S19c'
        elseif vehModel == `virgo2` then
            alt = 'CMM_MOD_S19d'
        end
    elseif mod == 45 then
        if vehModel == `slamvan3` then
            alt = 'CMM_MOD_S27'
        end
    elseif mod == 46 then
        if vehModel == `btype3` then
            alt = 'CMM_MOD_S21b'
        end
    elseif mod == 47 then
        if vehModel == `slamvan3` then
            alt = 'SLVAN3_RDOOR'
        end
    end

    local name = alt or vehicleModTypes[mod]?[1] or GetModSlotName(cache.vehicle, mod)

    return DoesTextLabelExist(name) and GetLabelText(name) or alt2 or vehicleModTypes[mod]?[2]
end

local function getModLocalizedName(modType, mod)
    local modCount = GetNumVehicleMods(cache.vehicle, modType)
    if mod < -1 or mod >= modCount then return end

    local vehModel = GetEntityModel(cache.vehicle)

    if modType == 14 then
        local horn = vehicleHornNames[mod]
        if horn then
            if DoesTextLabelExist(horn[1]) then
                return GetLabelText(horn[1])
            end
            return horn[2]
        end
        return
    elseif modType == 23 or modType == 24 then
        if mod == -1 then
            if not IsThisModelABike(vehModel) and IsThisModelABicycle(vehModel) then
                return DoesTextLabelExist('CMOD_WHE_0') and GetLabelText('CMOD_WHE_0') or nil
            else
                return DoesTextLabelExist('CMOD_WHE_B_0') and GetLabelText('CMOD_WHE_B_0') or nil
            end
        end

        if mod >= modCount / 2 then
            local modLabel = GetModTextLabel(cache.vehicle, modType, mod)
            return ('%s %s'):format((DoesTextLabelExist('CHROME') and GetLabelText('CHROME') or ''), (DoesTextLabelExist(modLabel) and GetLabelText(modLabel) or ''))
        else
            local modLabel = GetModTextLabel(cache.vehicle, modType, mod)
            return DoesTextLabelExist(modLabel) and GetLabelText(modLabel) or nil
        end
    elseif modType == 16 then
        local modLabel = ('CMOD_ARM_%s'):format(mod + 1)
        return DoesTextLabelExist(modLabel) and GetLabelText(modLabel) or nil
    elseif modType == 12 then
        local modLabel = ('CMOD_BRA_%s'):format(mod + 1)
        return DoesTextLabelExist(modLabel) and GetLabelText(modLabel) or nil
    elseif modType == 11 then
        if mod == -1 then
            -- Engine doesn't list anything in LSC for no parts, but there is a setting with no part. so just use armours none
            return DoesTextLabelExist('CMOD_ARM_0') and GetLabelText('CMOD_ARM_0') or nil
        end
        local modLabel = ('CMOD_ENG_%s'):format(mod + 2)
        return DoesTextLabelExist(modLabel) and GetLabelText(modLabel) or nil
    elseif modType == 15 then
        local modLabel = ('CMOD_SUS_%s'):format(mod + 1)
        return DoesTextLabelExist(modLabel) and GetLabelText(modLabel) or nil
    elseif modType == 13 then
        local modLabel = ('CMOD_GBX_%s'):format(mod + 1)
        return DoesTextLabelExist(modLabel) and GetLabelText(modLabel) or nil
    end

    if mod > -1 then
        local modLabel = GetModTextLabel(cache.vehicle, modType, mod)
        return DoesTextLabelExist(modLabel) and GetLabelText(modLabel) or ('%s %s'):format(getModLocalizedType(modType), mod + 1)
    else
        if modType == 41 then
            if vehModel == `banshee` or vehModel == `banshee2` or vehModel == `sultanrs` then
                return DoesTextLabelExist('CMOD_COL5_41') and GetLabelText('CMOD_COL5_41') or nil
            end
        end
        return DoesTextLabelExist('CMOD_DEF_0') and GetLabelText('CMOD_DEF_0') or nil
    end
end

local function closeMenu(isFullMenuClose, keyPressed, previousMenu)
    if isFullMenuClose or not keyPressed or keyPressed == 'Escape' then
        lib.hideMenu(false)
        menuOpen = false
        return
    end

    lib.showMenu(previousMenu, menuIndexes[previousMenu])
end

local function isInVehicle(checkDriver)
    if not cache.vehicle then
        return false, 'You need to be in a vehicle to perform this action'
    end

    if checkDriver and GetPedInVehicleSeat(cache.vehicle, -1) ~= cache.ped then
        return false, 'You need to be the driver of the vehicle to perform this action'
    end

    return true
end

local function createPlayerMenu()
    local id = 'berkie_menu_online_players'
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
                closeMenu(false, keyPressed, id)
            end,
            onSelected = function(selected)
                menuIndexes[formattedId] = selected
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
                    description = 'You can\'t do this on yourself',
                    type = 'error'
                })
                return
            end

            local message = args == messageArg and lib.hideMenu(true) and lib.inputDialog(('Send a message to %s'):format(data.name), {'Message'})

            if args == messageArg and (not message or not message[1] or message[1] == '') then
                Wait(500)
                lib.showMenu(formattedId, menuIndexes[formattedId])
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
            lib.showMenu(formattedId, menuIndexes[formattedId])
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
    SetVehRadioStation(vehicle, 'OFF')

    SetModelAsNoLongerNeeded(model)

    return vehicle
end

local function createModMenu()
    if not HasThisAdditionalTextLoaded('mod_mnu', 10) then
        ClearAdditionalText(10, true)
        RequestAdditionalText('mod_mnu', 10)
        while not HasThisAdditionalTextLoaded('mod_mnu', 10) do
            Wait(100)
        end
    end

    local vehModel = GetEntityModel(cache.vehicle)

    local id = 'berkie_menu_vehicle_options_mod_menu'
    SetVehicleModKit(cache.vehicle, 0)
    local mods = getAllPossibleMods()
    local i = 1
    for k, v in pairs(mods) do
        local values = {}
        local args = {}
        local localizedName = getModLocalizedType(k)
        local defaultIndex = GetVehicleMod(cache.vehicle, k) + 2
        values[1] = ('Stock %s'):format(localizedName)
        args[1] = {-1, k}

        for i2 = 2, v do
            local actualIndex = i2 - 2
            local localizedModName = getModLocalizedName(k, actualIndex)
            values[i2] = localizedModName and toProperCase(localizedModName) or ('%s %s'):format(localizedName, actualIndex)
            args[i2] = {actualIndex, k}
        end

        vehicleModsMenuData[k] = {i, {label = localizedName, description = ('Choose a %s upgrade, it will apply automatically'):format(localizedName), args = args, values = values, defaultIndex = defaultIndex, close = false}}

        lib.setMenuOptions(id, {label = localizedName, description = ('Choose a %s upgrade, it will apply automatically'):format(localizedName), args = args, values = values, defaultIndex = defaultIndex, close = false}, i)
        i += 1
    end

    if not IsThisModelABoat(vehModel) and not IsThisModelAHeli(vehModel) and not IsThisModelAPlane(vehModel) and not IsThisModelABicycle(vehModel) and not IsThisModelATrain(vehModel) then
        local valuesWheelType = {}
        for i2 = 0, #vehicleWheelTypes do
            valuesWheelType[i2 + 1] = vehicleWheelTypes[i2]
        end
        if IsThisModelABike(vehModel) then
            valuesWheelType = {'Bike Wheels'}
        elseif GetVehicleClass(cache.vehicle) == 22 then
            valuesWheelType = {'Open Wheel'}
        end

        local wheelTypeIndex = GetVehicleWheelType(cache.vehicle) + 1

        vehicleModsMenuData['wheel_type'] = {i, {label = 'Wheel Type', description = 'Choose a wheel type for your vehicle', args = 'wheel_type', values = valuesWheelType, defaultIndex = #valuesWheelType == 1 and 1 or wheelTypeIndex, close = false}}

        lib.setMenuOptions(id, {label = 'Wheel Type', description = 'Choose a wheel type for your vehicle', args = 'wheel_type', values = valuesWheelType, defaultIndex = #valuesWheelType == 1 and 1 or wheelTypeIndex, close = false}, i)
        i += 1
    end
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
        lib.setMenuOptions(id, {label = firstToUpper(label:lower()), args = data.model, close = false}, i)
    end
end

local function createVehicleSpawnerMenu()
    local id = 'berkie_menu_vehicle_spawner'
    local i = 4
    local sorted = {}

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
            position = 'top-right',
            onClose = function(keyPressed)
                closeMenu(false, keyPressed, id)
            end,
            onSelected = function(selected)
                menuIndexes[formattedId] = selected
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
    onSelected = function(selected)
        menuIndexes['berkie_menu_main'] = selected
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

    lib.showMenu(args, menuIndexes[args])
end)

lib.registerMenu({
    id = 'berkie_menu_online_players',
    title = 'Online Players',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        menuIndexes['berkie_menu_online_players'] = selected
    end,
    options = {}
}, function(_, _, args)
    lib.showMenu(args, menuIndexes[args])
end)

lib.registerMenu({
    id = 'berkie_menu_vehicle_related_options',
    title = 'Vehicle Related Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        menuIndexes['berkie_menu_vehicle_related_options'] = selected
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

    lib.showMenu(args, menuIndexes[args])
end)

lib.registerMenu({
    id = 'berkie_menu_vehicle_options',
    title = 'Vehicle Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_vehicle_related_options')
    end,
    onSelected = function(selected)
        menuIndexes['berkie_menu_vehicle_options'] = selected
    end,
    onSideScroll = function(_, scrollIndex, args)
        local val = scrollIndex == 1
        if args == 'god_mode_enable' then
            if val == vehicleGodMode then return end
            vehicleGodMode = val
            lib.setMenuOptions('berkie_menu_vehicle_options', {label = 'Vehicle God Mode', description = 'Makes your vehicle not take any damage. What kind of damage will be stopped is defined in the God Mode Options', args = 'god_mode_enable', values = {'Yes', 'No'}, defaultIndex = vehicleGodMode and 1 or 2, close = false}, 1)
        elseif args == 'keep_vehicle_clean' then
            if val == vehicleNeverDirty then return end
            vehicleNeverDirty = val
            lib.setMenuOptions('berkie_menu_vehicle_options', {label = 'Keep Vehicle Clean', description = 'This will constantly clean your car if it gets dirty. Note that this only cleans dust or dirt, not mud, snow or other damage decals. Repair your vehicle to remove them', args = 'keep_vehicle_clean', values = {'Yes', 'No'}, defaultIndex = vehicleNeverDirty and 1 or 2, close = false}, 4)
        end
    end,
    options = {
        {label = 'Vehicle God Mode', description = 'Makes your vehicle not take any damage. What kind of damage will be stopped is defined in the God Mode Options', args = 'god_mode_enable', values = {'Yes', 'No'}, defaultIndex = vehicleGodMode and 1 or 2, close = false},
        {label = 'God Mode Options', description = 'Enable or disable specific damage types', args = 'berkie_menu_vehicle_options_god_mode_menu'},
        {label = 'Repair Vehicle', description = 'Repair any damage present on your vehicle', args = 'repair_vehicle', close = false},
        {label = 'Keep Vehicle Clean', description = 'This will constantly clean your car if it gets dirty. Note that this only cleans dust or dirt, not mud, snow or other damage decals. Repair your vehicle to remove them', args = 'keep_vehicle_clean', values = {'Yes', 'No'}, defaultIndex = vehicleNeverDirty and 1 or 2, close = false},
        {label = 'Wash Vehicle', description = 'Clean your vehicle', args = 'wash_vehicle', close = false},
        {label = 'Set Dirt Level', description = 'Select how much dirt should be visible on your vehicle, press enter to apply it', args = 'set_dirt_level', values = {'No Dirt', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'}, defaultIndex = vehicleDirtLevelSetter + 1, close = false},
        {label = 'Mod Menu', description = 'Tune and customize your vehicle here', args = 'berkie_menu_vehicle_options_mod_menu'}
    }
}, function(_, scrollIndex, args)
    if scrollIndex and args ~= 'set_dirt_level' then return end

    local inVeh, reason = isInVehicle(true)
    if not inVeh then
        lib.notify({
            description = reason,
            type = 'error'
        })

        if args == 'berkie_menu_vehicle_options_mod_menu' or args == 'berkie_menu_vehicle_options_god_mode_menu' then
            menuOpen = false
        end

        return
    end

    if args == 'repair_vehicle' then
        SetVehicleFixed(cache.vehicle)
        return
    elseif args == 'wash_vehicle' then
        SetVehicleDirtLevel(cache.vehicle, 0)
        return
    elseif args == 'set_dirt_level' then
        vehicleDirtLevelSetter = scrollIndex - 1
        SetVehicleDirtLevel(cache.vehicle, vehicleDirtLevelSetter)
        lib.setMenuOptions('berkie_menu_vehicle_options', {label = 'Set Dirt Level', description = 'Select how much dirt should be visible on your vehicle', args = 'set_dirt_level', values = {'No Dirt', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'}, defaultIndex = vehicleDirtLevelSetter + 1, close = false}, 6)
        return
    elseif args == 'berkie_menu_vehicle_options_mod_menu' then
        createModMenu()
    end

    lib.showMenu(args, menuIndexes[args])
end)

lib.registerMenu({
    id = 'berkie_menu_vehicle_options_god_mode_menu',
    title = 'Vehicle God Mode Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_vehicle_options')
    end,
    onSelected = function(selected)
        menuIndexes['berkie_menu_vehicle_options_god_mode_menu'] = selected
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
    id = 'berkie_menu_vehicle_options_mod_menu',
    title = 'Mod Menu',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_vehicle_options')
    end,
    onSelected = function(selected)
        menuIndexes['berkie_menu_vehicle_options_mod_menu'] = selected
    end,
    onSideScroll = function(_, scrollIndex, args)
        -- preset or custom mode with tire smoke for rgb
        local customTires = GetVehicleModVariation(cache.vehicle, 23)
        local vehClass = GetVehicleClass(cache.vehicle)
        local vehModel = GetEntityModel(cache.vehicle)
        if type(args) == 'table' then
            local curArg = args[scrollIndex]
            SetVehicleMod(cache.vehicle, curArg[2], curArg[1], customTires)
            vehicleModsMenuData[curArg[2]][2].defaultIndex = scrollIndex
            lib.setMenuOptions('berkie_menu_vehicle_options_mod_menu', vehicleModsMenuData[curArg[2]][2], vehicleModsMenuData[curArg[2]][1])
        else
            if args == 'wheel_type' then
                if IsThisModelABike(vehModel) or vehClass == 22 then return end
                SetVehicleWheelType(cache.vehicle, scrollIndex - 1)
                SetVehicleMod(cache.vehicle, 23, -1, customTires)
                vehicleModsMenuData[23][2].defaultIndex = 1
                vehicleModsMenuData[args][2].defaultIndex = scrollIndex
                lib.setMenuOptions('berkie_menu_vehicle_options_mod_menu', vehicleModsMenuData[23][2], vehicleModsMenuData[23][1])
                lib.setMenuOptions('berkie_menu_vehicle_options_mod_menu', vehicleModsMenuData[args][2], vehicleModsMenuData[args][1])
                lib.hideMenu(false)
                lib.showMenu('berkie_menu_vehicle_options_mod_menu', menuIndexes['berkie_menu_vehicle_options_mod_menu'])
            end
        end
    end,
    options = {}
})

lib.registerMenu({
    id = 'berkie_menu_vehicle_spawner',
    title = 'Vehicle Spawner',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_vehicle_related_options')
    end,
    onSelected = function(selected)
        menuIndexes['berkie_menu_vehicle_spawner'] = selected
    end,
    onSideScroll = function(_, scrollIndex, args)
        if args == 'inside_vehicle' then
            spawnInVehicle = scrollIndex == 1
            lib.setMenuOptions('berkie_menu_vehicle_spawner', {label = 'Spawn Inside Vehicle', description = 'This will teleport you into the vehicle when it spawns', args = 'inside_vehicle', values = {'Yes', 'No'}, defaultIndex = spawnInVehicle and 1 or 2, close = false}, 2)
        elseif args == 'replace_vehicle' then
            replacePreviousVehicle = scrollIndex == 1
            lib.setMenuOptions('berkie_menu_vehicle_spawner', {label = 'Replace Previous Vehicle', description = 'This will delete the vehicle you were previously in when spawning a new vehicle', args = 'replace_vehicle', values = {'Yes', 'No'}, defaultIndex = replacePreviousVehicle and 1 or 2, close = false}, 3)
        end
    end,
    options = {
        {label = 'Spawn Vehicle By Model Name', description = 'Enter the name of the vehicle you want to spawn', args = 'spawn_by_model'},
        {label = 'Spawn Inside Vehicle', description = 'This will teleport you into the vehicle when it spawns', args = 'inside_vehicle', values = {'Yes', 'No'}, defaultIndex = spawnInVehicle and 1 or 2, close = false},
        {label = 'Replace Previous Vehicle', description = 'This will delete the vehicle you were previously in when spawning a new vehicle', args = 'replace_vehicle', values = {'Yes', 'No'}, defaultIndex = replacePreviousVehicle and 1 or 2, close = false}
    }
}, function(_, scrollIndex, args)
    if scrollIndex then return end

    if args == 'spawn_by_model' then
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

    lib.showMenu(args, menuIndexes[args])
end)

lib.registerMenu({
    id = 'berkie_menu_miscellaneous_options',
    title = 'Miscellaneous Options',
    position = 'top-right',
    onClose = function(keyPressed)
        closeMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        menuIndexes['berkie_menu_miscellaneous_options'] = selected
    end,
    onSideScroll = function(_, scrollIndex, args)
        if args == 'show_effects' then
            showEffects = scrollIndex == 1
            lib.setMenuOptions('berkie_menu_miscellaneous_options', {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', values = {'Yes', 'No'}, defaultIndex = showEffects and 1 or 2, close = false}, 1)
        end
    end,
    options = {
        {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', args = 'show_effects', values = {'Yes', 'No'}, defaultIndex = showEffects and 1 or 2, close = false}
    }
}, function(_, scrollIndex, args)
    if scrollIndex then return end

    lib.showMenu(args, menuIndexes[args])
end)

RegisterCommand('berkiemenu', function()
    menuOpen = not menuOpen

    if menuOpen then
        lib.showMenu('berkie_menu_main', menuIndexes['berkie_menu_main'])
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
        if isInVehicle(false) then
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

                do
                    memoryAddress += 392

                    local setter = vehicleInvincible and SetBit or ClearBit

                    ---@diagnostic disable
                    setter(memoryAddress, 4) -- IsBulletProof
                    setter(memoryAddress, 5) -- IsFireProof
                    setter(memoryAddress, 6) -- IsCollisionProof
                    setter(memoryAddress, 7) -- IsMeleeProof
                    setter(memoryAddress, 11) -- IsExplosionProof
                    ---@diagnostic enable
                end

                :: skipAddresses ::

                SetEntityInvincible(vehicle, vehicleInvincible)

                for i = 0, 5 do
                    if GetEntityBoneIndexByName(veh, vehicleDoorBoneNames[i]) ~= -1 then
                        SetVehicleDoorCanBreak(veh, i, not vehicleInvincible)
                    end
                end

                if vehicleNeverDirty and GetVehicleDirtLevel(veh) > 0 then
                    SetVehicleDirtLevel(veh, 0)
                end
            end
        else

        end
        Wait(sleep)
    end
end)

--[[
    vehicle options menu:
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