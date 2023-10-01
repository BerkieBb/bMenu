--#region Variables

IgnorePlayer = false
StayInVehicle = false

local godmode = false
local invisible = false
local unlimitedStamina = false
local fastRun = false
local fastSwim = false
local superJump = false
local noRagdoll = false
local neverWanted = true
local ghostMode = false
local customDrivingStyleList = {}
local customDrivingStyle = ''
local freezePlayer = false
local drivingStyle = 1
local actualDrivingStyle = 443

--#endregion Variables

--#region Functions

local function setupDrivingStyleOptions()
    lib.registerMenu({
        id = 'bMenu_player_autopilot_options_custom_driving_style',
        title = 'Custom Driving Style',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_player_autopilot_options')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_player_autopilot_options_custom_driving_style'] = selected
        end,
        onSideScroll = function(_, scrollIndex, args)
            customDrivingStyleList[args[1]] = scrollIndex == 1
            if drivingStyle == 5 then
                customDrivingStyle = ''
                for i = 0, 30 do
                    customDrivingStyle = ('%s%s'):format(customDrivingStyle, customDrivingStyleList[i] and 1 or 0)
                end
                actualDrivingStyle = tonumber(customDrivingStyle) --[[@as integer]]
                SetDriveTaskDrivingStyle(cache.ped, actualDrivingStyle)
            end
        end,
        options = {
            {label = 'Stop Before Vehicles', args = {0}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Stop Before Peds', args = {1}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Avoid Vehicles', args = {2}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Avoid Empty Vehicles', args = {3}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Avoid Peds', args = {4}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Avoid Objects', args = {5}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {6}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Stop At Traffic Lights', args = {7}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Use Blinkers', args = {8}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Allow Going Wrong Way', args = {9}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Go In Reverse Gear', args = {10}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {11}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {12}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {13}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {14}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {15}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {16}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {17}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Use Shortest Path', args = {18}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {19}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {20}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {21}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Ignore Roads', args = {22}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {23}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Ignore All Pathing', args = {24}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {25}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {26}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {27}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {28}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Avoid Highways (If Possible)', args = {29}, values = {'Yes', 'No'}, defaultIndex = 2, close = false},
            {label = 'Unknown Flag', args = {30}, values = {'Yes', 'No'}, defaultIndex = 2, close = false}
        }
    })
end

local function setupAutoPilotOptions()
    lib.registerMenu({
        id = 'bMenu_player_autopilot_options',
        title = 'Vehicle Auto Pilot',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_player_options')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_player_autopilot_options'] = selected
        end,
        onSideScroll = function(selected, scrollIndex, args)
            if args[1] == 'driving_style' then
                drivingStyle = scrollIndex
                if scrollIndex == 1 then
                    SetDriveTaskDrivingStyle(cache.ped, 443)
                    actualDrivingStyle = 443
                elseif scrollIndex == 2 then
                    SetDriveTaskDrivingStyle(cache.ped, 575)
                    actualDrivingStyle = 575
                elseif scrollIndex == 3 then
                    SetDriveTaskDrivingStyle(cache.ped, 536871355)
                    actualDrivingStyle = 536871355
                elseif scrollIndex == 4 then
                    SetDriveTaskDrivingStyle(cache.ped, 1467)
                    actualDrivingStyle = 1467
                elseif scrollIndex == 5 then
                    customDrivingStyle = ''
                    for i = 0, 30 do
                        customDrivingStyle = ('%s%s'):format(customDrivingStyle, customDrivingStyleList[i] and 1 or 0)
                    end
                    actualDrivingStyle = tonumber(customDrivingStyle) --[[@as integer]]
                    SetDriveTaskDrivingStyle(cache.ped, actualDrivingStyle)
                end
                lib.setMenuOptions('bMenu_player_autopilot_options', {label = 'Driving Style', description = 'Set the driving style that is used for the Drive to Waypoint and Drive Around Randomly functions', args = {'driving_style'}, values = {'Normal', 'Rushed', 'Avoid highways', 'Drive in reverse', 'Custom'}, defaultIndex = scrollIndex, close = false}, selected)
            end
        end,
        options = {
            {label = 'Driving Style', description = 'Set the driving style that is used for the Drive to Waypoint and Drive Around Randomly functions', args = {'driving_style'}, values = {'Normal', 'Rushed', 'Avoid highways', 'Drive in reverse', 'Custom'}, defaultIndex = drivingStyle, close = false},
            {label = 'Custom Driving Style', description = 'Select a custom driving style. Make sure to also enable it by selecting the \'Custom\' driving style in the driving styles list', args = {'bMenu_player_autopilot_options_custom_driving_style'}},
            {label = 'Drive To Waypoint', description = 'Make your player ped drive your vehicle to your waypoint', args = {'to_waypoint'}, close = false},
            {label = 'Drive Around Randomly', description = 'Make your player ped drive your vehicle randomly around the map', args = {'around_randomly'}, close = false},
            {label = 'Stop Driving', description = 'The player ped will find a suitable place to stop the vehicle. The task will be stopped once the vehicle has reached the suitable stop location', args = {'stop_driving'}, close = false},
            {label = 'Force Stop Driving', description = 'This will stop the driving task immediately without finding a suitable place to stop', args = {'force_stop_driving'}, close = false}
        }
    }, function(_, _, args)
        if args[1] == 'bMenu_player_autopilot_options_custom_driving_style' then
            setupDrivingStyleOptions()
            lib.showMenu(args[1], MenuIndexes[args[1]])
        else
            local inVeh, reason = IsInVehicle(true)
            if not inVeh then
                lib.notify({
                    description = reason,
                    type = 'error'
                })
                return
            end

            if args[1] == 'to_waypoint' then
                if not IsWaypointActive() then
                    lib.notify({
                        description = 'You need a waypoint set to drive to',
                        type = 'error'
                    })
                    return
                end

                ClearPedTasks(cache.ped)

                local waypointBlipInfo = GetFirstBlipInfoId(GetWaypointBlipEnumId())
                local waypointBlipPos = waypointBlipInfo ~= 0 and GetBlipInfoIdType(waypointBlipInfo) == 4 and GetBlipInfoIdCoord(waypointBlipInfo) or vec2(0, 0)
                RequestCollisionAtCoord(waypointBlipPos.x, waypointBlipPos.y, 1000)
                local result, z = GetGroundZFor_3dCoord(waypointBlipPos.x, waypointBlipPos.y, 1000, false)
                if not result then
                    z = 0
                end
                waypointBlipPos = vec3(waypointBlipPos.x, waypointBlipPos.y, z)

                SetDriverAbility(cache.ped, 1.0)
                SetDriverAggressiveness(cache.ped, 0.0)

                TaskVehicleDriveToCoordLongrange(cache.ped, cache.vehicle, waypointBlipPos.x, waypointBlipPos.y, waypointBlipPos.z, GetVehicleModelEstimatedMaxSpeed(GetEntityModel(cache.vehicle)), actualDrivingStyle, 10.0)

                lib.notify({
                    description = 'Your player ped is now driving the vehicle for you. You can cancel any time by pressing the Stop Driving button. The vehicle will stop when it has reached the destination',
                    type = 'inform'
                })
            elseif args[1] == 'around_randomly' then
                ClearPedTasks(cache.ped)

                SetDriverAbility(cache.ped, 1.0)
                SetDriverAggressiveness(cache.ped, 0.0)

                TaskVehicleDriveWander(cache.ped, cache.vehicle, GetVehicleModelEstimatedMaxSpeed(GetEntityModel(cache.vehicle)), actualDrivingStyle)

                lib.notify({
                    description = 'Your player ped is now driving the vehicle for you. You can cancel any time by pressing the Stop Driving button',
                    type = 'inform'
                })
            elseif args[1] == 'stop_driving' then
                local coords = GetEntityCoords(cache.ped)
                local success, closestNode = GetNthClosestVehicleNode(coords.x, coords.y, coords.z, 3, 0, 0, 0)

                if not success then return end

                lib.notify({
                    description = 'The player ped will find a suitable place to park the car and will then stop driving. Please wait',
                    type = 'inform'
                })
                ClearPedTasks(cache.ped)
                TaskVehiclePark(cache.ped, cache.vehicle, closestNode.x, closestNode.y, closestNode.z, GetEntityHeading(cache.ped), 3, 60, true)

                while #(GetEntityCoords(cache.ped).xy - closestNode.xy) > 3 do
                    Wait(0)
                end

                BringVehicleToHalt(cache.vehicle, 3, 0, false)
                ClearPedTasks(cache.ped)

                lib.notify({
                    description = 'Your vehicle is now stopped',
                    type = 'inform'
                })
            elseif args[1] == 'force_stop_driving' then
                ClearPedTasks(cache.ped)
            end
        end
    end)
end

function SetupPlayerOptions()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'PlayerRelated', 'PlayerOptions'}, {'Godmode', 'Invisible', 'Unlimited_Stamina', 'Fast_Run', 'Fast_Swim', 'Super_Jump', 'No_Ragdoll', 'Ghost_Mode', 'Never_Wanted', 'Set_Wanted_Level', 'Everyone_Ignore_Player', 'Stay_In_Vehicle', 'Heal_Player', 'Set_Armor_Type', 'Adjust_Player_Clothes', 'Suicide', 'AutoPilot', 'Freeze_Player'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_player_related_options'}}
    }
    local index = 1

    if perms.Godmode then
        menuOptions[index] = {label = 'Godmode', description = 'Makes you invincible', args = {'godmode'}, checked = godmode, close = false}
        index += 1
    end

    if perms.Invisible then
        menuOptions[index] = {label = 'Invisible', description = 'Makes you invisible to yourself and others', args = {'invisible'}, checked = invisible, close = false}
        index += 1
    end

    if perms.Unlimited_Stamina then
        menuOptions[index] = {label = 'Unlimited Stamina', description = 'Allows you to run forever without slowing down or taking damage', args = {'unlimited_stamina'}, checked = unlimitedStamina, close = false}
        index += 1
    end

    if perms.Fast_Run then
        menuOptions[index] = {label = 'Fast Run', description = 'Get Snail powers and run very fast', args = {'fast_run'}, checked = fastRun, close = false}
        index += 1
    end

    if perms.Fast_Swim then
        menuOptions[index] = {label = 'Fast Swim', description = 'Get Snail 2.0 powers and swim super fast', args = {'fast_swim'}, checked = fastSwim, close = false}
        index += 1
    end

    if perms.Super_Jump then
        menuOptions[index] = {label = 'Super Jump', description = 'Get Snail 3.0 powers and jump like a champ', args = {'super_jump'}, checked = superJump, close = false}
        index += 1
    end

    if perms.No_Ragdoll then
        menuOptions[index] = {label = 'No Ragdoll', description = 'Disables player ragdoll, makes you not fall off your bike anymore', args = {'no_ragdoll'}, checked = noRagdoll, close = false}
        index += 1
    end

    if perms.Ghost_Mode then
        menuOptions[index] = {label = 'Ghost Mode', description = 'Be barely visible and untouchable', args = {'ghost'}, checked = ghostMode, close = false}
        index += 1
    end

    if perms.Never_Wanted then
        menuOptions[index] = {label = 'Never Wanted', description = 'Disables all wanted levels', args = {'never_wanted'}, checked = neverWanted, close = false}
        index += 1
    end

    if perms.Set_Wanted_Level then
        menuOptions[index] = {label = 'Set Wanted Level', args = {'set_wanted_level'}, values = {'0', '1', '2', '3', '4', '5'}, defaultIndex = 1, close = false}
        index += 1
    end

    if perms.Everyone_Ignore_Player then
        menuOptions[index] = {label = 'Everyone Ignore Player', description = 'Introverts love this', args = {'ignore_player'}, checked = IgnorePlayer, close = false}
        index += 1
    end

    if perms.Stay_In_Vehicle then
        menuOptions[index] = {label = 'Stay In Vehicle', description = 'When this is enabled, NPCs will not be able to drag you out of your vehicle if they get angry at you', args = {'stay_in_vehicle'}, checked = StayInVehicle, close = false}
        index += 1
    end

    if perms.Heal_Player then
        menuOptions[index] = {label = 'Heal Player', description = 'Give the player max health', args = {'heal_player'}, close = false}
        index += 1
    end

    if perms.Set_Armor_Type then
        menuOptions[index] = {label = 'Set Armor Type', description = 'Set the armor level/type for your player', args = {'set_armor_type'}, values = {'No Armor', GetLabelText('WT_BA_0'), GetLabelText('WT_BA_1'), GetLabelText('WT_BA_2'), GetLabelText('WT_BA_3'), GetLabelText('WT_BA_4')}, defaultIndex = 1, close = false}
        index += 1
    end

    if perms.Adjust_Player_Clothes then
        menuOptions[index] = {label = 'Clean Player Clothes', description = 'Clean your player clothes', args = {'clean_player_clothes'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Dry Player Clothes', description = 'Dry your player clothes', args = {'dry_player_clothes'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Wet Player Clothes', description = 'Wet your player clothes', args = {'wet_player_clothes'}, close = false}
        index += 1
    end

    if perms.Suicide then
        menuOptions[index] = {label = 'Commit Suicide', description = 'Kill yourself by taking the pill. Or by using a pistol if you have one', args = {'suicide'}}
        index += 1
    end

    if perms.AutoPilot then
        menuOptions[index] = {label = 'Auto Pilot', description = 'Vehicle auto pilot options', args = {'bMenu_player_autopilot_options'}}
        index += 1
    end

    if perms.Freeze_Player then
        menuOptions[index] = {label = 'Freeze Player', description = 'Freezes your ped at the current location', args = {'freeze'}, checked = freezePlayer, close = false}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_player_options',
        title = 'Player Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_player_related_options')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_player_options'] = selected
        end,
        onCheck = function(selected, checked, args)
            if args[1] == 'godmode' then
                godmode = checked
                SetEntityInvincible(cache.ped, godmode)
                lib.setMenuOptions('bMenu_player_options', {label = 'Godmode', description = 'Makes you invincible', args = {'godmode'}, checked = godmode, close = false}, selected)
            elseif args[1] == 'invisible' then
                invisible = checked
                SetEntityVisible(cache.ped, not invisible, false)
                lib.setMenuOptions('bMenu_player_options', {label = 'Invisible', description = 'Makes you invisible to yourself and others', args = {'invisible'}, checked = invisible, close = false}, selected)
            elseif args[1] == 'unlimited_stamina' then
                unlimitedStamina = checked
                StatSetInt(`MP0_STAMINA`, unlimitedStamina and 100 or 0, true)
                lib.setMenuOptions('bMenu_player_options', {label = 'Unlimited Stamina', description = 'Allows you to run forever without slowing down or taking damage', args = {'unlimited_stamina'}, checked = unlimitedStamina, close = false}, selected)
            elseif args[1] == 'fast_run' then
                fastRun = checked
                SetRunSprintMultiplierForPlayer(cache.playerId, fastRun and 1.49 or 1)
                lib.setMenuOptions('bMenu_player_options', {label = 'Fast Run', description = 'Get Snail powers and run very fast', args = {'fast_run'}, checked = fastRun, close = false}, selected)
            elseif args[1] == 'fast_swim' then
                fastSwim = checked
                SetSwimMultiplierForPlayer(cache.playerId, fastSwim and 1.49 or 1)
                lib.setMenuOptions('bMenu_player_options', {label = 'Fast Swim', description = 'Get Snail 2.0 powers and swim super fast', args = {'fast_swim'}, checked = fastSwim, close = false}, selected)
            elseif args[1] == 'super_jump' then
                superJump = checked
                lib.setMenuOptions('bMenu_player_options', {label = 'Super Jump', description = 'Get Snail 3.0 powers and jump like a champ', args = {'super_jump'}, checked = superJump, close = false}, selected)
            elseif args[1] == 'no_ragdoll' then
                noRagdoll = checked
                SetPedCanRagdoll(cache.ped, not noRagdoll)
                lib.setMenuOptions('bMenu_player_options', {label = 'No Ragdoll', description = 'Disables player ragdoll, makes you not fall off your bike anymore', args = {'no_ragdoll'}, checked = noRagdoll, close = false}, selected)
            elseif args[1] == 'ghost' then
                ghostMode = checked
                SetLocalPlayerAsGhost(ghostMode)
                lib.setMenuOptions('bMenu_player_options', {label = 'Ghost Mode', description = 'Be a invisible and untouchable', args = {'ghost'}, checked = ghostMode, close = false}, selected)
            elseif args[1] == 'never_wanted' then
                neverWanted = checked
                SetMaxWantedLevel(neverWanted and 0 or 5)
                if neverWanted then
                    ClearPlayerWantedLevel(cache.playerId)
                end
                lib.setMenuOptions('bMenu_player_options', {label = 'Never Wanted', description = 'Disables all wanted levels', args = {'never_wanted'}, checked = neverWanted, close = false}, selected)
            elseif args[1] == 'ignore_player' then
                IgnorePlayer = checked
                SetEveryoneIgnorePlayer(cache.playerId, ignorePlayer)
                SetPoliceIgnorePlayer(cache.playerId, ignorePlayer)
                SetPlayerCanBeHassledByGangs(cache.playerId, not ignorePlayer)
                lib.setMenuOptions('bMenu_player_options', {label = 'Everyone Ignore Player', description = 'Introverts love this', args = {'ignore_player'}, checked = IgnorePlayer, close = false}, selected)
            elseif args[1] == 'stay_in_vehicle' then
                StayInVehicle = checked
                lib.setMenuOptions('bMenu_player_options', {label = 'Stay In Vehicle', description = 'When this is enabled, NPCs will not be able to drag you out of your vehicle if they get angry at you', args = {'stay_in_vehicle'}, checked = StayInVehicle, close = false}, selected)
            elseif args[1] == 'freeze' then
                freezePlayer = checked
                FreezeEntityPosition(cache.ped, freezePlayer)
                lib.setMenuOptions('bMenu_player_options', {label = 'Freeze Player', description = 'Freezes your ped at the current location', args = {'freeze'}, checked = freezePlayer, close = false}, selected)
            end
        end,
        onSideScroll = function(selected, scrollIndex, args)
            if args[1] == 'set_wanted_level' then
                lib.setMenuOptions('bMenu_player_options', {label = 'Set Wanted Level', args = {'set_wanted_level'}, values = {'0', '1', '2', '3', '4', '5'}, defaultIndex = scrollIndex, close = false}, selected)
                if neverWanted then return end
                SetPlayerWantedLevel(cache.playerId, scrollIndex - 1, false)
                SetPlayerWantedLevelNow(cache.playerId, false)
            elseif args[1] == 'set_armor_type' then
                SetPedArmour(cache.ped, (scrollIndex - 1) * 20)
                lib.setMenuOptions('bMenu_player_options', {label = 'Set Armor Type', description = 'Set the armor level/type for your player', args = {'set_armor_type'}, values = {'No Armor', GetLabelText('WT_BA_0'), GetLabelText('WT_BA_1'), GetLabelText('WT_BA_2'), GetLabelText('WT_BA_3'), GetLabelText('WT_BA_4')}, defaultIndex = 1, close = false}, selected)
            end
        end,
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'heal_player' then
            SetEntityHealth(cache.ped, GetEntityMaxHealth(cache.ped))
            lib.notify({
                description = 'You have been healed',
                type = 'success'
            })
        elseif args[1] == 'clean_player_clothes' then
            ClearPedBloodDamage(cache.ped)
            lib.notify({
                description = 'Your clothes have been cleaned',
                type = 'success'
            })
        elseif args[1] == 'dry_player_clothes' then
            SetPedWetnessHeight(cache.ped, 0)
            lib.notify({
                description = 'Your clothes are now dry',
                type = 'success'
            })
        elseif args[1] == 'wet_player_clothes' then
            SetPedWetnessHeight(cache.ped, 2)
            lib.notify({
                description = 'Your clothes are now wet',
                type = 'success'
            })
        elseif args[1] == 'suicide' then
            local alert = lib.alertDialog({
                header = 'Sure?',
                content = 'Are you sure you want to commit suicide? \n This action cannot be undone.',
                centered = true,
                cancel = true
            })

            if alert == 'confirm' then
                if cache.vehicle then
                    SetEntityHealth(cache.ped, 0)
                    return
                end

                MenuOpen = false

                lib.requestAnimDict('mp_suicide')

                local weaponHash
                local takePill = false

                if HasPedGotWeapon(cache.ped, `WEAPON_PISTOL_MK2`, false) then
                    weaponHash = `WEAPON_PISTOL_MK2`
                elseif HasPedGotWeapon(cache.ped, `WEAPON_COMBATPISTOL`, false) then
                    weaponHash = `WEAPON_COMBATPISTOL`
                elseif HasPedGotWeapon(cache.ped, `WEAPON_PISTOL`, false) then
                    weaponHash = `WEAPON_PISTOL`
                elseif HasPedGotWeapon(cache.ped, `WEAPON_SNSPISTOL_MK2`, false) then
                    weaponHash = `WEAPON_SNSPISTOL_MK2`
                elseif HasPedGotWeapon(cache.ped, `WEAPON_SNSPISTOL`, false) then
                    weaponHash = `WEAPON_SNSPISTOL`
                elseif HasPedGotWeapon(cache.ped, `WEAPON_PISTOL50`, false) then
                    weaponHash = `WEAPON_PISTOL50`
                elseif HasPedGotWeapon(cache.ped, `WEAPON_HEAVYPISTOL`, false) then
                    weaponHash = `WEAPON_HEAVYPISTOL`
                elseif HasPedGotWeapon(cache.ped, `WEAPON_VINTAGEPISTOL`, false) then
                    weaponHash = `WEAPON_VINTAGEPISTOL`
                else
                    takePill = true
                end

                if takePill then
                    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
                else
                    SetCurrentPedWeapon(cache.ped, weaponHash, true)
                    SetPedDropsWeaponsWhenDead(cache.ped, true)
                end

                ClearPedTasks(cache.ped)
                TaskPlayAnim(cache.ped, 'mp_suicide', takePill and 'pill' or 'pistol', 8, -8, -1, 270540800, 0, false, false, false)

                local shot = false
                while true do
                    local time = GetEntityAnimCurrentTime(cache.ped, 'mp_suicide', takePill and 'pill' or 'pistol')
                    if HasAnimEventFired(cache.ped, `Fire`) and not shot then
                        ClearEntityLastDamageEntity(cache.ped)
                        SetPedShootsAtCoord(cache.ped, 0, 0, 0, false)
                        shot = true
                    end

                    if time > (takePill and 0.536 or 0.365) then
                        ClearEntityLastDamageEntity(cache.ped)
                        SetEntityHealth(cache.ped, 0)
                        break
                    end
                    Wait(0)
                end

                RemoveAnimDict('mp_suicide')
            elseif alert == 'cancel' then
                Wait(200)
                lib.showMenu('bMenu_player_options', MenuIndexes['bMenu_player_options'])
            end
        elseif string.match(args[1], 'bMenu') then
            if args[1] == 'bMenu_player_autopilot_options' then
                setupAutoPilotOptions()
            end

            lib.showMenu(args[1], MenuIndexes[args[1]])
        end
    end)
end

--#endregion Functions

--#region Listeners

lib.onCache('ped', function(value)
    SetEntityInvincible(value, godmode)
    SetEntityVisible(value, not invisible, false)
    SetPedCanRagdoll(value, not noRagdoll)
end)

--#endregion Listeners

--#region Threads

CreateThread(function()
    SetRunSprintMultiplierForPlayer(cache.playerId, fastRun and 1.49 or 1)
    SetSwimMultiplierForPlayer(cache.playerId, fastSwim and 1.49 or 1)
    while true do
        if superJump then
            SetSuperJumpThisFrame(cache.playerId)
        end

        Wait(0)
    end
end)

CreateThread(function()
    while true do
        if neverWanted and GetPlayerWantedLevel(cache.playerId) > 0 then
            ClearPlayerWantedLevel(cache.playerId)
            if GetMaxWantedLevel() > 0 then
                SetMaxWantedLevel(0)
            end
        end

        Wait(100)
    end
end)

--#endregion Threads