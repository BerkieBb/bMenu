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
    onCheck = function(_, checked, args)
        if args[1] == 'show_effects' then
            showEffects = checked
            lib.setMenuOptions('berkie_menu_miscellaneous_options', {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', args = {'show_effects'}, checked = checked, close = false}, 1)
        end
    end,
    options = {
        {label = 'Show Effects', icon = 'hat-wizard', description = 'Show effects when going in and out of noclip or when teleporting', args = {'show_effects'}, checked = showEffects, close = false}
    }
})

--#endregion Menu Registration