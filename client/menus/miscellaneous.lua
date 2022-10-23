--#region Variables

local showEffects = true -- Show effects when going in and out of noclip or when teleporting

--#endregion Variables

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_miscellaneous_options',
    title = 'Miscellaneous Options',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_miscellaneous_options'] = selected
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

    lib.showMenu(args, MenuIndexes[args])
end)

--#endregion Menu Registration