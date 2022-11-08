--#region Variables

local quitSession = true

--#endregion Variables

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_recording_options',
    title = 'Recording Options',
    position = 'top-right',
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_recording_options'] = selected
    end,
    onCheck = function(_, checked, args)
        if args[1] == 'quit_session' then
            quitSession = checked
            lib.setMenuOptions('berkie_menu_recording_options', {label = 'Quit Session', description = 'Quit the current session before opening the rockstar editor, this can prevent some issues with the editor', args = {'quit_session'}, checked = checked, close = false}, 3)
        end
    end,
    options = {
        {label = 'Start Recording', description = 'Start a new game recording using GTA V\'s built in recording', args = {'start'}, close = false},
        {label = 'Stop Recording', description = 'Stop and save your current recording', args = {'stop'}, close = false},
        {label = 'Quit Session', description = 'Quit the current session before opening the rockstar editor, this can prevent some issues with the editor', args = {'quit_session'}, checked = quitSession, close = false},
        {label = 'Rockstar Editor', description = 'Open the rockstar editor', args = {'editor'}}
    }
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
    end
end)

--#endregion Menu Registration