--#region Functions

function SetupConnectionOptions()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'Misc', 'ConnectionOptions'}, {'Quit_Join_Session', 'Quit_Game'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_misc_options'}}
    }
    local index = 1

    if perms.Quit_Join_Session then
        menuOptions[index] = {label = 'Quit Session', description = 'Leaves you connected to the server, but quits the network session. Can not be used when you are the host', args = {'quit_session'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Rejoin Session', description = 'This may not work in all cases, but you can try to use this if you want to re-join the previous session after clicking \'Quit Session\'', args = {'rejoin_session'}, close = false}
        index += 1
    end

    if perms.Quit_Game then
        menuOptions[index] = {label = 'Quit Game', description = 'Exits the game after 5 seconds', args = {'quit_game'}}
        index += 1
    end

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
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'bMenu_misc_options' then
            lib.showMenu(args[1], MenuIndexes[args[1]])
            return
        end

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

            NetworkSessionHost(-1, lib.callback.await('bMenu:server:getMaxClients', false), false)
        elseif args[1] == 'quit_game' then
            lib.notify({
                description = 'The game will exit in 5 seconds',
                type = 'inform'
            })
            Wait(5000)
            RestartGame()
        end
    end)
end

--#endregion Functions