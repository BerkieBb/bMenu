--#region Startup

-- I don't want you renaming this because this uses kvp and that requires the resource name to be the same across servers to work correctly
if GetCurrentResourceName() ~= 'berkie_menu' then
    error('Please don\'t rename this resource, change the folder name (back) to \'berkie_menu\' (case sensitive) to make sure the saved data can be saved and fetched accordingly from the cache.')
    return
end

--#endregion Startup

--#region Variables

MenuOpen = false
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

--#endregion Functions

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_main',
    title = 'Berkie Menu',
    position = 'top-right',
    onClose = function()
        CloseMenu(true)
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_main'] = selected
    end,
    options = {
        {label = 'Online Players', icon = 'user-group', args = {'berkie_menu_online_players'}},
        {label = 'Player Related Options', icon = 'user-gear', args = {'berkie_menu_player_related_options'}},
        {label = 'Vehicle Related Options', icon = 'car', args = {'berkie_menu_vehicle_related_options'}},
        {label = 'World Related Options', icon = 'globe', args = {'berkie_menu_world_related_options'}},
        {label = 'Recording Options', icon = 'video', args = {'berkie_menu_recording_options'}},
        {label = 'Miscellaneous Options', icon = 'gear', description = 'Show all options that don\'t fit in the other categories', args = {'berkie_menu_miscellaneous_options'}}
    }
}, function(_, _, args)
    if args[1] == 'berkie_menu_online_players' then
        CreatePlayerMenu()
    end

    lib.showMenu(args[1], MenuIndexes[args[1]])
end)

--#endregion Menu Registration

--#region Commands

RegisterCommand('berkiemenu', function()
    MenuOpen = not MenuOpen

    if MenuOpen then
        lib.showMenu('berkie_menu_main', MenuIndexes['berkie_menu_main'])
    else
        lib.hideMenu(true)
    end
end, true)

RegisterKeyMapping('berkiemenu', 'Open Menu', 'KEYBOARD', 'M')

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() or not MenuOpen then return end

    CloseMenu(true)
end)

--#endregion Commands

--[[
    Things I have to do before the 1.0.0 release

        Add updates that vMenu didn't have

        Add translations

        Extend private message functionality (under online players)

        Add Player Appearance menu (under player related options)

        Add MP Ped Customization menu (under player related options)

        Add components to Weapon Options menu (under player related options)

        Add Weapon Loadouts menu (under player related options)

        Add Saved Vehicles menu (under vehicle related options)

        Finish Misc menu

        Add About menu

        Add permissions for every option

]]