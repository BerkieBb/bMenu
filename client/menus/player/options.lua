--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_player_options',
    title = 'Player Options',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'berkie_menu_player_related_options')
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_player_options'] = selected
    end,
    options = {
        {label = 'Nothing yet', close = false}
    }
})

--#endregion Menu Registration