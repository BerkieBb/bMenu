--#region Variables

local noClipEnabled = false
local followCamMode = true
local currentScalefrom = -1
local movingSpeed = 0
local movingSpeeds = {
    [0] = 'Very Slow',
    [1] = 'Slow',
    [2] = 'Normal',
    [3] = 'Fast',
    [4] = 'Very Fast',
    [5] = 'Extremely Fast',
    [6] = 'Staggeringly Fast',
    [7] = 'Max Speed'
}

--#endregion Variables

--#region Functions

local function toggleNoClip()
    if not lib.callback.await('bMenu:server:hasCommandPermission', false, 'toggle_noclip') then return end

    local noclipEntity = cache.vehicle or cache.ped
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        currentScalefrom = RequestScaleformMovie('INSTRUCTIONAL_BUTTONS')
        while not HasScaleformMovieLoaded(currentScalefrom) do
            Wait(0)
        end

        BeginScaleformMovieMethod(currentScalefrom, 'CLEAR_ALL')
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(0)
        ScaleformMovieMethodAddParamTextureNameString('~INPUT_STRING~')
        ScaleformMovieMethodAddParamTextureNameString(('Change Speed: %s'):format(movingSpeeds[movingSpeed]))
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(1)
        ScaleformMovieMethodAddParamTextureNameString('~INPUT_MOVE_LR~')
        ScaleformMovieMethodAddParamTextureNameString('Turn Left/Right')
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(2)
        ScaleformMovieMethodAddParamTextureNameString('~INPUT_MOVE_UD~')
        ScaleformMovieMethodAddParamTextureNameString('Move')
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(3)
        ScaleformMovieMethodAddParamTextureNameString('~INPUT_MULTIPLAYER_INFO~')
        ScaleformMovieMethodAddParamTextureNameString('Down')
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(4)
        ScaleformMovieMethodAddParamTextureNameString('~INPUT_COVER~')
        ScaleformMovieMethodAddParamTextureNameString('Up')
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(currentScalefrom, 'SET_DATA_SLOT')
        ScaleformMovieMethodAddParamInt(5)
        ScaleformMovieMethodAddParamTextureNameString('~INPUT_VEH_HEADLIGHT~')
        ScaleformMovieMethodAddParamTextureNameString('Cam Mode')
        EndScaleformMovieMethod()

        BeginScaleformMovieMethod(currentScalefrom, 'DRAW_INSTRUCTIONAL_BUTTONS')
        ScaleformMovieMethodAddParamInt(0)
        EndScaleformMovieMethod()

        DrawScaleformMovieFullscreen(currentScalefrom, 255, 255, 255, 0, 0)

        FreezeEntityPosition(noclipEntity, true)
        SetEntityInvincible(noclipEntity, true)

        SetEntityVisible(noclipEntity, false, false)
        SetEntityCollision(noclipEntity, false, false)
        SetLocalPlayerVisibleLocally(true)
        SetEntityAlpha(noclipEntity, 51, false)

        SetEveryoneIgnorePlayer(cache.playerId, true)
        SetPoliceIgnorePlayer(cache.playerId, true)
    else
        SetScaleformMovieAsNoLongerNeeded(currentScalefrom)
        currentScalefrom = -1

        FreezeEntityPosition(noclipEntity, false)
        SetEntityInvincible(noclipEntity, false)

        SetEntityVisible(noclipEntity, true, false)
        SetEntityCollision(noclipEntity, true, true)
        SetLocalPlayerVisibleLocally(true)
        ResetEntityAlpha(noclipEntity)

        SetEveryoneIgnorePlayer(cache.playerId, false)
        SetPoliceIgnorePlayer(cache.playerId, false)
    end
end

function CreatePlayerOptionsMenu()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, 'PlayerRelated', {'PlayerOptions', 'WeaponOptions', 'Toggle_NoClip'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_main'}}
    }
    local index = 1

    if perms.PlayerOptions then
        menuOptions[index] = {label = 'Player Options', description = 'Common player options can be accessed here', args = {'bMenu_player_options'}}
        index += 1
    end

    if perms.WeaponOptions then
        menuOptions[index] = {label = 'Weapon Options', description = 'Add/remove weapons, modify weapons and set ammo options', args = {'bMenu_player_weapon_options'}}
        index += 1
    end

    if perms.Toggle_NoClip then
        menuOptions[index] = {label = 'Toggle NoClip', description = 'Toggle NoClip on or off', args = {'toggle_noclip'}, close = false}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_player_related_options',
        title = 'Player Related Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_main')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_player_related_options'] = selected
        end,
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'toggle_noclip' then
            toggleNoClip()
        else
            if args[1] == 'bMenu_player_options' then
                SetupPlayerOptions()
            elseif args[1] == 'bMenu_player_weapon_options' then
                SetupWeaponsMenu()
            end

            lib.showMenu(args[1], MenuIndexes[args[1]])
        end
    end)
end

--#endregion Functions

--#region Commands

RegisterCommand('bMenu_toggleNoClip', toggleNoClip, true)

RegisterKeyMapping('bMenu_toggleNoClip', 'Toggle NoClip', 'KEYBOARD', 'F2')

--#endregion Commands

--#region Threads

CreateThread(function()
    while true do
        if noClipEnabled then
            if not IsHudHidden() and currentScalefrom ~= -1 then
                DrawScaleformMovieFullscreen(currentScalefrom, 255, 255, 255, 255, 0)
            end

            local noclipEntity = cache.vehicle or cache.ped

            DisableControlAction(0, 20, true)
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 74, true)
            if cache.vehicle then
                DisableControlAction(0, 75, true)
                DisableControlAction(0, 85, true)
            end
            DisableControlAction(0, 266, true)
            DisableControlAction(0, 267, true)
            DisableControlAction(0, 268, true)
            DisableControlAction(0, 269, true)

            local yOff = 0.0
            local zOff = 0.0
            local currentHeading = GetEntityHeading(noclipEntity)

            if IsUsingKeyboard(2) and UpdateOnscreenKeyboard() ~= 0 and not IsPauseMenuActive() then
                if IsControlJustPressed(0, 21) then
                    movingSpeed += 1
                    if movingSpeed == 8 then
                        movingSpeed = 0
                    end
                end

                if IsDisabledControlPressed(0, 32) then
                    yOff = 0.5
                end

                if IsDisabledControlPressed(0, 33) then
                    yOff = -0.5
                end

                if not followCamMode and IsDisabledControlPressed(0, 34) then
                    currentHeading += 3
                end

                if not followCamMode and IsDisabledControlPressed(0, 35) then
                    currentHeading -= 3
                end

                if IsDisabledControlPressed(0, 44) then
                    zOff = 0.21
                end

                if IsDisabledControlPressed(0, 20) then
                    zOff = -0.21
                end

                if IsDisabledControlJustPressed(0, 74) then
                    followCamMode = not followCamMode
                end
            end

            local moveSpeed = movingSpeed

            if movingSpeed > 4 then
                moveSpeed *= 1.8
            end

            moveSpeed = moveSpeed / (1 / GetFrameTime()) * 60
            local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yOff * (moveSpeed + 0.3), zOff * (moveSpeed + 0.3))

            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, followCamMode and GetGameplayCamRelativePitch() or 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, followCamMode and GetGameplayCamRelativeHeading() or currentHeading)
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, false, false)

            SetLocalPlayerVisibleLocally(true)
        end

        Wait(0)
    end
end)

--#endregion Threads