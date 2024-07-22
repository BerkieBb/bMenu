--#region Variables

local currentVehicle = 0
local enableVehicleBlip = false
local vehicleRemoveDoors = false
local vehicleDoors = {
    'Left Front Door',
    'Right Front Door',
    'Left Rear Door',
    'Right Rear Door',
    'Hood',
    'Trunk',
    'Extra Door (#1)',
    'Extra Door (#2)'
}

--#endregion Variables

--#region Functions

local function pressKeyFob()
    if not cache.playerId or cache.playerId == 0 or currentVehicle == 0 or IsPlayerDead(cache.playerId) or IsPedInAnyVehicle(cache.ped, false) then return end

    local keyFobHash = `p_car_keys_01`
    lib.requestModel(keyFobHash)

    local keyFobObject = CreateObject(keyFobHash, 0, 0, 0, true, true, true)
    AttachEntityToEntity(keyFobObject, cache.ped, GetPedBoneIndex(cache.ped, 57005), 0.09, 0.03, -0.02, -76, 13, 28, false, true, true, true, 0, true)
    SetModelAsNoLongerNeeded(keyFobHash)

    ClearPedTasks(cache.ped)
    SetCurrentPedWeapon(cache.ped, `weapon_unarmed`, true)

    TaskTurnPedToFaceEntity(cache.ped, currentVehicle, 500)

    lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
    TaskPlayAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3, -8, 1000, 16, 0, false, false, false)
    PlaySoundFromEntity(-1, 'Remote_Control_Fob', cache.ped, 'PI_Menu_Sounds', true, 0)

    Wait(1250)
    DetachEntity(keyFobObject, false, false)
    SetEntityAsMissionEntity(keyFobObject, false, false)
    DeleteObject(keyFobObject)
    RemoveAnimDict('anim@mp_player_intmenu@key_fob@')
end

local function createDoorMenu()
    local index = 1
    local menuOptions = {}

    for i = 0, 7 do
        if GetIsDoorValid(curVeh, i) then
            menuOptions[index] = {label = vehicleDoors[i + 1], description = ('Open/close the %s'):format(vehicleDoors[i + 1]:lower()), args = {i}, close = false}
            index += 1
        end
    end

    if GetEntityBoneIndexByName(curVeh, 'door_hatch_l') ~= -1 and GetEntityBoneIndexByName(curVeh, 'door_hatch_r') ~= -1 then
        menuOptions[index] = {label = 'Bomb Bay', description = 'Open/close the bomb bay', args = {'bomb_bay'}, close = false}
        index += 1
    end

    menuOptions = {label = 'Open All Doors', args = {'open_all_doors'}, close = false}
    index += 1

    menuOptions[index] = {label = 'Close All Doors', args = {'close_all_doors'}, close = false}
    index += 1

    menuOptions[index] = {label = 'Remove Doors', description = 'If this is enabled, the doors will be deleted when using the remove door option, otherwise they will be dropped to the ground', args = {'remove_doors'}, checked = vehicleRemoveDoors, close = false}
    index += 1

    menuOptions[index] = {label = 'Remove Door', description = 'Remove the specified door from the vehicle, press enter to apply it', args = {'remove_door'}, values = vehicleDoors, defaultIndex = 1, close = false}
    index += 1

    lib.registerMenu({
        id = 'bMenu_vehicle_personal_doors',
        title = 'Vehicle Doors',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_vehicle_personal')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_vehicle_personal_doors'] = selected
        end,
        onCheck = function(_, checked, args)
            if args[1] == 'remove_doors' then
                vehicleRemoveDoors = checked
            end
        end,
        options = menuOptions
    }, function(_, scrollIndex, args)
        local curVeh = NetToVeh(currentVehicle)
        if type(args[1]) == 'number' then
            pressKeyFob()
            local isOpen = GetVehicleDoorAngleRatio(curVeh, args) > 0.1
            if isOpen then
                SetVehicleDoorShut(curVeh, args, false)
            else
                SetVehicleDoorOpen(curVeh, args, false, false)
            end
        elseif args[1] == 'bomb_bay' then
            pressKeyFob()
            if AreBombBayDoorsOpen(curVeh) then
                CloseBombBayDoors(curVeh)
            else
                OpenBombBayDoors(curVeh)
            end
        elseif args[1] == 'open_all_doors' then
            pressKeyFob()
            for i = 0, 7 do
                SetVehicleDoorOpen(curVeh, i, false, false)
            end
            if GetEntityBoneIndexByName(curVeh, 'door_hatch_l') ~= -1 and GetEntityBoneIndexByName(curVeh, 'door_hatch_r') ~= -1 then
                OpenBombBayDoors(curVeh)
            end
        elseif args[1] == 'close_all_doors' then
            pressKeyFob()
            SetVehicleDoorsShut(curVeh, false)
            if GetEntityBoneIndexByName(curVeh, 'door_hatch_l') ~= -1 and GetEntityBoneIndexByName(curVeh, 'door_hatch_r') ~= -1 then
                CloseBombBayDoors(curVeh)
            end
        elseif args[1] == 'remove_door' then
            pressKeyFob()
            SetVehicleDoorBroken(curVeh, scrollIndex - 1, vehicleRemoveDoors)
        end
    end)
end

function SetupVehiclePersonalMenu()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'VehicleRelated', 'PersonalVehicle'}, {'Toggle_Engine', 'Set_Lights', 'Manage_Doors', 'Toggle_Alarm', 'Toggle_Blip', 'Exclusive_Driver'})
    local menuOptions = {
        {label = 'Set Vehicle', description = 'Sets your current vehicle as your personal vehicle. If you already have a personal vehicle set then this will override your selection', args = {'set_vehicle'}},
        {label = 'Current Vehicle: None', close = false}
    }
    local index = 3

    if perms.Toggle_Engine then
        menuOptions[index] = {label = 'Toggle Engine', description = 'Toggles the engine on or off, even when you\'re not inside of the vehicle. This does not work if someone else is currently using your vehicle', args = {'toggle_engine'}, close = false}
        index += 1
    end

    if perms.Set_Lights then
        menuOptions[index] = {label = 'Set Vehicle Lights', description = 'This will enable or disable your vehicle headlights, the engine of your vehicle needs to be running for this to work', args = {'set_vehicle_lights'}, values = {'Force On', 'Force Off', 'Reset'}, defaultIndex = 1, close = false}
        index += 1
    end

    if perms.Manage_Doors then
        menuOptions[index] = {label = 'Lock Vehicle Doors', description = 'This will lock all your vehicle doors for all players. Anyone already inside will always be able to leave the vehicle, even if the doors are locked', args = {'lock_doors'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Unlock Vehicle Doors', description = 'This will unlock all your vehicle doors for all players', args = {'unlock_doors'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Vehicle Doors', description = 'Open, close, remove and restore vehicle doors here', args = {'bMenu_vehicle_personal_doors'}, close = false}
        index += 1
    end

    if perms.Toggle_Alarm then
        menuOptions[index] = {label = 'Toggle Alarm Sound', description = 'Toggles the vehicle alarm sound on or off. This does not set an alarm. It only toggles the current sounding status of the alarm', args = {'alarm_sound'}, close = false}
        index += 1
    end

    if perms.Toggle_Blip then
        menuOptions[index] = {label = 'Add Blip', description = 'Enables or disables the blip that gets added when you mark a vehicle as your personal vehicle', args = {'add_blip'}, checked = enableVehicleBlip, close = false}
        index += 1
    end

    if perms.Exclusive_Driver then
        menuOptions[index] = {label = 'Exclusive Driver', description = 'If enabled, then you will be the only one that can enter the drivers seat. Other players will not be able to drive the car. They can still be passengers', args = {'exclusive_driver'}, checked = false, close = false}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_vehicle_personal',
        title = 'Personal Vehicle',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_vehicle_related_options')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_vehicle_personal'] = selected
        end,
        onCheck = function(selected, checked, args)
            local curVeh = NetToVeh(currentVehicle)

            if not NetworkHasControlOfEntity(curVeh) then
                if not NetworkRequestControlOfEntity(curVeh) then
                    lib.notify({
                        description = 'You currently can\'t control this vehicle. Is someone else currently driving your car? Please try again after making sure other players are not controlling your vehicle',
                        type = 'error'
                    })
                    return
                end
            end

            if args[1] == 'add_blip' then
                enableVehicleBlip = checked
                lib.setMenuOptions('bMenu_vehicle_personal', {label = 'Add Blip', description = 'Enables or disables the blip that gets added when you mark a vehicle as your personal vehicle', args = {'add_blip'}, checked = checked, close = false}, selected)
                if enableVehicleBlip then
                    local entityState = Entity(curVeh)
                    if not entityState.state.bMenu_blip or not DoesBlipExist(entityState.state.bMenu_blip) then
                        local blip = AddBlipForEntity(curVeh)
                        SetBlipSprite(blip, 225)
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentSubstringPlayerName('Personal Vehicle')
                        EndTextCommandSetBlipName(blip)
                        entityState.state:set('bMenu_blip', blip)
                    end
                else
                    local entityState = Entity(curVeh)
                    if entityState.state.bMenu_blip and DoesBlipExist(entityState.state.bMenu_blip) then
                        RemoveBlip(entityState.state.bMenu_blip)
                    end
                    entityState.state:set('bMenu_blip', nil)
                end
            elseif args[1] == 'exclusive_driver' then
                SetVehicleExclusiveDriver(curVeh, checked)
                SetVehicleExclusiveDriver_2(curVeh, checked and cache.ped or 0, 1)
                lib.setMenuOptions('bMenu_vehicle_personal', {label = 'Exclusive Driver', description = 'If enabled, then you will be the only one that can enter the drivers seat. Other players will not be able to drive the car. They can still be passengers', args = {'exclusive_driver'}, checked = checked, close = false}, selected)
            end
        end,
        onSideScroll = function(selected, scrollIndex, args)
            local curVeh = NetToVeh(currentVehicle)

            if not NetworkHasControlOfEntity(curVeh) then
                if not NetworkRequestControlOfEntity(curVeh) then
                    lib.notify({
                        description = 'You currently can\'t control this vehicle. Is someone else currently driving your car? Please try again after making sure other players are not controlling your vehicle',
                        type = 'error'
                    })
                    return
                end
            end

            if args[1] == 'set_vehicle_lights' then
                lib.setMenuOptions('bMenu_vehicle_personal', {label = 'Set Vehicle Lights', description = 'This will enable or disable your vehicle headlights, the engine of your vehicle needs to be running for this to work', args = {'set_vehicle_lights'}, values = {'Force On', 'Force Off', 'Reset'}, defaultIndex = scrollIndex, close = false}, selected)
            end
        end,
        options = menuOptions
    }, function(selected, scrollIndex, args)
        if not args or not args[1] then return end

        if args[1] == 'set_vehicle' then
            local inVeh, reason = IsInVehicle(true)
            if not inVeh then
                lib.notify({
                    description = reason,
                    type = 'error'
                })
            else
                local curVeh = NetToVeh(currentVehicle)
                if DoesEntityExist(curVeh) then
                    local entityState = Entity(curVeh)
                    if entityState.state.bMenu_blip and DoesBlipExist(entityState.state.bMenu_blip) then
                        RemoveBlip(entityState.state.bMenu_blip)
                    end
                    entityState.state:set('bMenu_blip', nil)
                end
                curVeh = GetVehiclePedIsIn(cache.ped, false)
                SetVehicleHasBeenOwnedByPlayer(curVeh, true)
                SetEntityAsMissionEntity(curVeh, true, false)
                if enableVehicleBlip then
                    local entityState = Entity(curVeh)
                    if not entityState.state.bMenu_blip or not DoesBlipExist(entityState.state.bMenu_blip) then
                        local blip = AddBlipForEntity(curVeh)
                        SetBlipSprite(blip, 225)
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentSubstringPlayerName('Personal Vehicle')
                        EndTextCommandSetBlipName(blip)
                        entityState.state:set('bMenu_blip', blip)
                    end
                end
                local name = GetDisplayNameFromVehicleModel(GetEntityModel(curVeh))
                local labelText = GetLabelText(name)
                local vehicleName = labelText and labelText ~= '' and labelText ~= 'NULL' and ToProperCase(labelText) or ToProperCase(name)
                lib.setMenuOptions('bMenu_vehicle_personal', {label = ('Current Vehicle: %s'):format(vehicleName)}, selected)
                currentVehicle = VehToNet(curVeh)
            end
            lib.showMenu('bMenu_vehicle_personal', MenuIndexes['bMenu_vehicle_personal'])
        elseif DoesEntityExist(NetToVeh(currentVehicle)) then
            if args[1] == 'kick_passengers' then
                local curVeh = NetToVeh(currentVehicle)
                if IsPedInVehicle(cache.ped, curVeh, false) or (GetVehicleNumberOfPassengers(curVeh) == 0 and not IsVehicleSeatFree(curVeh, -1)) then
                    lib.notify({
                        description = 'No one to kick out of the vehicle',
                        type = 'inform'
                    })
                    return
                end

                TaskEveryoneLeaveVehicle(curVeh)
            else
                local curVeh = NetToVeh(currentVehicle)

                if not NetworkHasControlOfEntity(curVeh) then
                    if not NetworkRequestControlOfEntity(curVeh) then
                        lib.notify({
                            description = 'You currently can\'t control this vehicle. Is someone else currently driving your car? Please try again after making sure other players are not controlling your vehicle',
                            type = 'error'
                        })
                        return
                    end
                end

                if args[1] == 'toggle_engine' then
                    pressKeyFob()
                    SetVehicleEngineOn(curVeh, not GetIsVehicleEngineRunning(curVeh), true, true)
                elseif args[1] == 'set_vehicle_lights' then
                    pressKeyFob()
                    if scrollIndex == 1 then
                        SetVehicleLights(curVeh, 3)
                    elseif scrollIndex == 2 then
                        SetVehicleLights(curVeh, 1)
                    else
                        SetVehicleLights(curVeh, 0)
                    end
                elseif args[1] == 'unlock_doors' or args[1] == 'lock_doors' then
                    local lock = args[1] == 'lock_doors'
                    pressKeyFob()
                    for _ = 1, 2 do
                        local timer = GetGameTimer()
                        while GetGameTimer() - timer < 50 do
                            SoundVehicleHornThisFrame(curVeh)
                            Wait(0)
                        end

                        Wait(50)
                    end

                    lib.notify({
                        description = ('Vehicle doors are now %s'):format(lock and 'locked' or 'unlocked'),
                        type = 'inform'
                    })
                    SetVehicleDoorsLockedForAllPlayers(curVeh, lock)
                elseif args[1] == 'alarm_sound' then
                    pressKeyFob()
                    if IsVehicleAlarmActivated(curVeh) then
                        SetVehicleAlarmTimeLeft(curVeh, 0)
                        SetVehicleAlarm(curVeh, false)
                    else
                        SetVehicleAlarm(curVeh, true)
                        SetVehicleAlarmTimeLeft(curVeh, math.random(8000, 45000))
                        StartVehicleAlarm(curVeh)
                    end
                elseif args[1] == 'bMenu_vehicle_personal_doors' then
                    lib.hideMenu(false)
                    createDoorMenu()
                    lib.showMenu(args[1], MenuIndexes[args[1]])
                end
            end
        else
            lib.notify({
                description = 'You have not selected a current vehicle or it doesn\'t exist anymore',
                type = 'error'
            })
        end
    end)
end

--#endregion Functions