--#region Startup

-- I don't want you renaming this because this uses kvp and that requires the resource name to be the same across servers to work correctly
if GetCurrentResourceName() ~= 'bMenu' then
    error('Please don\'t rename this resource, change the folder name (back) to \'bMenu\' (case sensitive) to make sure the saved data can be saved and fetched accordingly from the cache.')
    return
end

--#endregion Startup

--#region Variables

MenuOpen = false
MenuPosition = 'top-right'
MenuIndexes = {}

--#endregion Variables

--#region Functions

---@param v number
---@return integer
function math.sign(v)
	return v >= 0 and 1 or -1
end

---@param value any
---@param array any[]
---@return boolean
function ArrayIncludes(value, array)
    for i = 1, #array do
        local arrayVal = array[i]
        if value == arrayVal then
            return true
        end
    end

    return false
end

---@param str string
function ToProperCase(str)
    return string.gsub(str, '(%a)([%w_\']*)', function(first, rest)
        return first:upper()..rest:lower()
    end)
end

---@param isFullMenuClose boolean
---@param keyPressed? string
---@param previousMenu? string
function CloseMenu(isFullMenuClose, keyPressed, previousMenu)
    if isFullMenuClose or not keyPressed or not previousMenu or keyPressed == 'Escape' then
        lib.hideMenu(false)
        MenuOpen = false
        return
    end

    lib.showMenu(previousMenu, MenuIndexes[previousMenu])
end

---@param text string
---@param x number
---@param y number
---@param size? number
---@param position? 0 | 1 | 2 0: center | 1: left | 2: right
---@param font? number
---@param disableTextOutline? boolean
function DrawTextOnScreen(text, x, y, size, position, font, disableTextOutline)
    if
        not IsHudPreferenceSwitchedOn()
        or IsHudHidden()
        or IsPlayerSwitchInProgress()
        or IsScreenFadedOut()
        or IsPauseMenuActive()
        or IsFrontendFading()
        or IsPauseMenuRestarting()
    then
        return
    end

    size = size or 0.48
    position = position or 1
    font = font or 6

    SetTextFont(font)
    SetTextScale(1.0, size)
    if position == 2 then
        SetTextWrap(0, x)
    end
    SetTextJustification(position)
    if not disableTextOutline then
        SetTextOutline()
    end
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

---@param pos vector3
---@param safeModeDisabled? boolean
function TeleportToCoords(pos, safeModeDisabled)
    if safeModeDisabled then
        RequestCollisionAtCoord(pos.x, pos.y, pos.z)
        local entity = cache.seat == -1 and cache.vehicle or cache.ped
        SetEntityCoords(entity, pos.x, pos.y, pos.z, false, false, false, true)
        return
    end

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

function TeleportToWaypoint()
    if not IsWaypointActive() then return end

    local waypointBlipInfo = GetFirstBlipInfoId(GetWaypointBlipEnumId())
    local waypointBlipPos = waypointBlipInfo ~= 0 and GetBlipInfoIdType(waypointBlipInfo) == 4 and GetBlipInfoIdCoord(waypointBlipInfo) or vec2(0, 0)
    RequestCollisionAtCoord(waypointBlipPos.x, waypointBlipPos.y, 1000)
    local result, z = GetGroundZFor_3dCoord(waypointBlipPos.x, waypointBlipPos.y, 1000, false)
    if not result then
        z = 0
    end

    waypointBlipPos = vec3(waypointBlipPos.x, waypointBlipPos.y, z)

    TeleportToCoords(waypointBlipPos)
end

--#endregion Functions

--#region Commands

RegisterCommand('bmenu', function()
    local hasPermission = lib.callback.await('bMenu:server:hasCommandPermission', false, 'bmenu')
    if not hasPermission then
        MenuOpen = false -- Making sure this property is set accordingly
        return
    end

    MenuOpen = not MenuOpen

    if MenuOpen then
        local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, 'Main', {'OnlinePlayers', 'PlayerRelated', 'VehicleRelated', 'WorldRelated', 'Recording', 'Misc'})
        local menuOptions = {
            {label = 'You don\'t have access to anything', icon = 'face-sad-tear', args = {'none'}}
        }

        local index = 1

        if perms.OnlinePlayers then
            menuOptions[index] = {label = 'Online Players', icon = 'user-group', args = {'bMenu_online_players'}}
            index += 1
        end

        if perms.PlayerRelated then
            menuOptions[index] = {label = 'Player Related Options', icon = 'user-gear', args = {'bMenu_player_related_options'}}
            index += 1
        end

        if perms.VehicleRelated then
            menuOptions[index] = {label = 'Vehicle Related Options', icon = 'car', args = {'bMenu_vehicle_related_options'}}
            index += 1
        end

        if perms.WorldRelated then
            menuOptions[index] = {label = 'World Related Options', icon = 'globe', args = {'bMenu_world_related_options'}}
            index += 1
        end

        if perms.Recording then
            menuOptions[index] = {label = 'Recording Options', icon = 'video', args = {'bMenu_recording_options'}}
            index += 1
        end

        if perms.Misc then
            menuOptions[index] = {label = 'Miscellaneous Options', icon = 'gear', description = 'Show all options that don\'t fit in the other categories', args = {'bMenu_misc_options'}}
            index += 1
        end

        lib.registerMenu({
            id = 'bMenu_main',
            title = 'Berkie Menu',
            position = MenuPosition,
            onClose = function()
                CloseMenu(true)
            end,
            onSelected = function(selected)
                MenuIndexes['bMenu_main'] = selected
            end,
            options = menuOptions
        }, function(_, _, args)
            if args[1] == 'none' then return end

            if args[1] == 'bMenu_online_players' then
                CreatePlayerMenu()
            elseif args[1] == 'bMenu_player_related_options' then
                CreatePlayerOptionsMenu()
            elseif args[1] == 'bMenu_vehicle_related_options' then
                CreateVehicleOptionsMenu()
            elseif args[1] == 'bMenu_world_related_options' then
                CreateWorldMenu()
            elseif args[1] == 'bMenu_recording_options' then
                CreateRecordingMenu()
            elseif args[1] == 'bMenu_misc_options' then
                CreateMiscMenu()
            end

            lib.showMenu(args[1], MenuIndexes[args[1]])
        end)

        lib.showMenu('bMenu_main', MenuIndexes['bMenu_main'])
        return
    end

    lib.hideMenu(true)
end, false)

RegisterKeyMapping('bmenu', 'Open Menu', 'KEYBOARD', 'M')

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() or not MenuOpen then return end

    CloseMenu(true)
end)

--#endregion Commands

--[[
    Things I have to do before the 1.0.0 release

        Finish Misc menu

        Extend private message functionality (under online players)

        Add Player Appearance menu (under player related options)

        Add MP Ped Customization menu (under player related options)

        Add components to Weapon Options menu (under player related options)

        Add Weapon Loadouts menu (under player related options)

        Add Saved Vehicles menu (under vehicle related options)

        Add About menu

        Add updates that vMenu didn't have
]]
