--#region Menu Registration

lib.registerMenu({
    id = 'bMenu_misc_options_connection_options',
    title = 'Connection Options',
    position = MenuPosition,
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'bMenu_misc_options')
    end,
    onSelected = function(selected)
        MenuIndexes['bMenu_misc_options_connection_options'] = selected
    end,
    options = {
        {label = 'Quit Session', description = 'Leaves you connected to the server, but quits the network session. Can not be used when you are the host', args = {'quit_session'}, close = false},
        {label = 'Rejoin Session', description = 'This may not work in all cases, but you can try to use this if you want to re-join the previous session after clicking \'Quit Session\'', args = {'rejoin_session'}, close = false},
        {label = 'Quit Game', description = 'Exits the game after 5 seconds', args = {'quit_game'}, close = false}
    }
}, function(_, _, args)
    if args[1] == 'quit_session' then
        if not NetworkIsSessionActive() then
            lib.notify({
                description = 'You are currently not in a session',
                type = 'error'
            })
            return
        end

        if NetworkIsHost() then
            lib.notify({
                description = 'You cannot leave the session that you\'re the host of',
                type = 'error'
            })
            return
        end

        NetworkSessionEnd(true, true)
    elseif args[1] == 'rejoin_session' then
        if NetworkIsSessionActive() then
            lib.notify({
                description = 'You are already in a session',
                type = 'error'
            })
            return
        end

        NetworkSessionHost(-1, GetConvarInt('sv_maxclients', 32), false)
    elseif args[1] == 'quit_game' then
        lib.notify({
            description = 'The game will exit in 5 seconds',
            type = 'inform'
        })
        Wait(5000)
        ForceSocialClubUpdate()
    end
end)

--#endregion Menu Registration