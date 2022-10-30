--#region Variables

--#endregion Variables

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_player_weapon_options',
    title = 'Player Options',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'berkie_menu_player_related_options')
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_player_weapon_options'] = selected
    end,
    options = {
        {label = 'Get All Weapons', args = 'get_all_weapons', close = false}
    }
}, function(_, _, args)

end)

--#endregion Menu Registration