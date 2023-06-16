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

function math.sign(v)
	return v >= 0 and 1 or -1
end

function math.round(v, bracket)
	bracket = bracket or 1
	return math.floor(v / bracket + math.sign(v) * 0.5) * bracket
end

function ArrayIncludes(value, array)
    for i = 1, #array do
        local arrayVal = array[i]
        if value == arrayVal then
            return true
        end
    end

    return false
end

function ToProperCase(str)
    return string.gsub(str, '(%a)([%w_\']*)', function(first, rest)
        return first:upper()..rest:lower()
    end)
end

function CloseMenu(isFullMenuClose, keyPressed, previousMenu)
    if isFullMenuClose or not keyPressed or keyPressed == 'Escape' then
        lib.hideMenu(false)
        MenuOpen = false
        return
    end

    lib.showMenu(previousMenu, MenuIndexes[previousMenu])
end

function DrawTextOnScreen(text, x, y, size, position --[[ 0: center | 1: left | 2: right ]], font, disableTextOutline)
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

--#endregion Functions

--#region Menu Registration

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
    options = {
        {label = 'Online Players', icon = 'user-group', args = {'bMenu_online_players'}},
        {label = 'Player Related Options', icon = 'user-gear', args = {'bMenu_player_related_options'}},
        {label = 'Vehicle Related Options', icon = 'car', args = {'bMenu_vehicle_related_options'}},
        {label = 'World Related Options', icon = 'globe', args = {'bMenu_world_related_options'}},
        {label = 'Recording Options', icon = 'video', args = {'bMenu_recording_options'}},
        {label = 'Miscellaneous Options', icon = 'gear', description = 'Show all options that don\'t fit in the other categories', args = {'bMenu_misc_options'}}
    }
}, function(_, _, args)
    if args[1] == 'bMenu_online_players' then
        CreatePlayerMenu()
    elseif args[1] == 'bMenu_recording_options' then
        CreateRecordingMenu()
    elseif args[1] == 'bMenu_world_related_options' then
        CreateWorldMenu()
    elseif args[1] == 'none' then
        return
    end

    lib.showMenu(args[1], MenuIndexes[args[1]])
end)

--#endregion Menu Registration

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
        lib.setMenuOptions('bMenu_main', {
            {label = 'You don\'t have access to anything', icon = 'face-sad-tear', args = {'none'}}
        })

        local index = 1

        if perms.OnlinePlayers then
            lib.setMenuOptions('bMenu_main', {label = 'Online Players', icon = 'user-group', args = {'bMenu_online_players'}}, index)
            index += 1
        end

        if perms.PlayerRelated then
            lib.setMenuOptions('bMenu_main', {label = 'Player Related Options', icon = 'user-gear', args = {'bMenu_player_related_options'}}, index)
            index += 1
        end

        if perms.VehicleRelated then
            lib.setMenuOptions('bMenu_main', {label = 'Vehicle Related Options', icon = 'car', args = {'bMenu_vehicle_related_options'}}, index)
            index += 1
        end

        if perms.WorldRelated then
            lib.setMenuOptions('bMenu_main', {label = 'World Related Options', icon = 'globe', args = {'bMenu_world_related_options'}}, index)
            index += 1
        end

        if perms.Recording then
            lib.setMenuOptions('bMenu_main', {label = 'Recording Options', icon = 'video', args = {'bMenu_recording_options'}}, index)
            index += 1
        end

        if perms.Misc then
            lib.setMenuOptions('bMenu_main', {label = 'Miscellaneous Options', icon = 'gear', description = 'Show all options that don\'t fit in the other categories', args = {'bMenu_misc_options'}}, index)
            index += 1
        end

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

        Add permissions for every option

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
