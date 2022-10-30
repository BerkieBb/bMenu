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
        {label = 'Online Players', icon = 'user-group', args = 'berkie_menu_online_players'},
        {label = 'Player Related Options', icon = 'user-gear', args = 'berkie_menu_player_related_options'},
        {label = 'Vehicle Related Options', icon = 'car', args = 'berkie_menu_vehicle_related_options'},
        {label = 'Recording Options', icon = 'video', args = 'berkie_menu_recording_options'},
        {label = 'Miscellaneous Options', icon = 'gear', description = 'Show all options that don\'t fit in the other categories', args = 'berkie_menu_miscellaneous_options'}
    }
}, function(_, _, args)
    if args == 'berkie_menu_online_players' then
        CreatePlayerMenu()
    end

    lib.showMenu(args, MenuIndexes[args])
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
end, type(MenuPermission) == 'string')
RegisterKeyMapping('berkiemenu', 'Open Menu', 'KEYBOARD', 'M')

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() or not MenuOpen then return end

    CloseMenu(true)
end)

--#endregion Commands

--[[
    TODO

        updates to add:

            https://www.gtabase.com/news/grand-theft-auto-v/title-updates/gta-online-los-santos-tuners-update-patch-notes-summer-2021

            https://www.gtabase.com/news/grand-theft-auto-v/title-updates/gta-online-the-contract-update-december-2021-patch-notes-fixers

            https://www.gtabase.com/news/grand-theft-auto-v/title-updates/gta-v-title-update-1-56-1-59-patch-notes-next-gen-bug-fixes

            https://www.gtabase.com/news/grand-theft-auto-v/title-updates/gta-online-summer-2022-dlc-update-patch-notes-features
]]