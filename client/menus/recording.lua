--#region Variables

local quitSession = true

--#endregion Variables

--#region Functions

function CreateRecordingMenu()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, 'Recording', {'Start_Stop', 'Editor'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'return'}}
    }
    local index = 1

    if perms.Start_Stop then
        menuOptions[index] = {label = 'Start Recording', description = 'Start a new game recording using GTA V\'s built in recording', args = {'start'}, close = false}
        index += 1
        menuOptions[index] = {label = 'Stop Recording', description = 'Stop and save your current recording', args = {'stop'}, close = false}
        index += 1
    end

    if perms.Editor then
        menuOptions[index] = {label = 'Quit Session', description = 'Quit the current session before opening the rockstar editor, this can prevent some issues with the editor', args = {'quit_session'}, checked = quitSession, close = false}
        index += 1
        menuOptions[index] = {label = 'Rockstar Editor', description = 'Open the rockstar editor', args = {'editor'}}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_recording_options',
        title = 'Recording Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_main')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_recording_options'] = selected
        end,
        onCheck = function(selected, checked, args)
            if args[1] == 'quit_session' then
                quitSession = checked
                lib.setMenuOptions('bMenu_recording_options', {label = 'Quit Session', description = 'Quit the current session before opening the rockstar editor, this can prevent some issues with the editor', args = {'quit_session'}, checked = checked, close = false}, selected)
            end
        end,
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'start' then
            if IsRecording() then
                lib.notify({
                    description = 'You\'re already recording',
                    type = 'error'
                })
                return
            end

            StartRecording(1)
        elseif args[1] == 'stop' then
            if not IsRecording() then
                lib.notify({
                    description = 'You\'re not recording',
                    type = 'error'
                })
                return
            end

            StopRecordingAndSaveClip()
        elseif args[1] == 'editor' then
            CreateThread(function()
                if quitSession then
                    NetworkSessionEnd(true, true)
                end

                ActivateRockstarEditor()

                while IsPauseMenuActive() do
                    Wait(0)
                end

                DoScreenFadeIn(1)

                if quitSession then
                    lib.notify({
                        description = 'You have left your previous session before opening the Rockstar Editor. Restart the game to be able to rejoin the server\'s main session',
                        type = 'inform'
                    })
                end
            end)
        elseif args[1] == 'return' then
            lib.showMenu('bMenu_main', MenuIndexes['bMenu_main'])
        end
    end)
end

--#endregion Functions