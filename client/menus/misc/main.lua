--#region Variables

local enablePMs = true
local speedKmh = false
local speedMph = false
local displayLocation = false
local showTime = false
local joinNotifs = GetConvarInt('chat_showJoins', 1) == 1
local quitNotifs = GetConvarInt('chat_showQuits', 1) == 1
local safeZoneSizeX = (1 / GetSafeZoneSize() / 3) - 0.358

--#endregion Variables

--#region Events

RegisterNetEvent('berkie_menu:client:updateConvar', function(convar, value)
    if GetInvokingResource() then return end

    if convar == 'chat_showJoins' then
        joinNotifs = value == 1
    elseif convar == 'chat_showQuits' then
        quitNotifs = value == 1
    end
end)

--#endregion Events

--#region Callbacks

lib.callback.register('berkie_menu:client:canSendMessage', function()
    return enablePMs
end)

--#endregion Callbacks

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_misc_options',
    title = 'Miscellaneous Options',
    position = MenuPosition,
    onClose = function(keyPressed)
        CloseMenu(false, keyPressed, 'berkie_menu_main')
    end,
    onSelected = function(selected)
        MenuIndexes['berkie_menu_misc_options'] = selected
    end,
    onCheck = function(selected, checked, args)
        if args[1] == 'enable_pms' then
            enablePMs = checked
            lib.setMenuOptions('berkie_menu_misc_options', {label = 'Enable Private Messages', description = 'If this is enabled, other people can send you a private message via the online players tab', checked = checked, args = {'enable_pms'}, close = false}, selected)
        elseif args[1] == 'speed_kmh' then
            speedKmh = checked
            lib.setMenuOptions('berkie_menu_misc_options', {label = 'Show Speed KM/H', checked = checked, args = {'speed_kmh'}, close = false}, selected)
        elseif args[1] == 'speed_mph' then
            speedMph = checked
            lib.setMenuOptions('berkie_menu_misc_options', {label = 'Show Speed MPH', checked = checked, args = {'speed_mph'}, close = false}, selected)
        elseif args[1] == 'display_location' then
            displayLocation = checked
            lib.setMenuOptions('berkie_menu_misc_options', {label = 'Display Location', description = 'Shows your current location and heading, as well as the nearest cross road', checked = checked, args = {'display_location'}, close = false}, selected)
        elseif args[1] == 'show_time' then
            showTime = checked
            lib.setMenuOptions('berkie_menu_misc_options', {label = 'Show Time', description = 'Shows you the current time on screen', checked = checked, args = {'show_time'}, close = false}, selected)
        elseif args[1] == 'show_join_notifs' then
            joinNotifs = checked
            lib.callback.await('berkie_menu:server:setConvar', false, 'chat_showJoins', checked and 1 or 0)
            lib.setMenuOptions('berkie_menu_misc_options', {label = 'Show Join Notifications', description = 'Receive notifications when someone joins the server', checked = checked, args = {'show_join_notifs'}, close = false}, selected)
        elseif args[1] == 'show_quit_notifs' then
            quitNotifs = checked
            lib.callback.await('berkie_menu:server:setConvar', false, 'chat_showQuits', checked and 1 or 0)
            lib.setMenuOptions('berkie_menu_misc_options', {label = 'Show Quit Notifications', description = 'Receive notifications when someone leaves the server', checked = checked, args = {'show_quit_notifs'}, close = false}, selected)
        end
    end,
    options = {
        {label = 'Teleport Options', args = {'berkie_menu_misc_options_teleport_options'}},
        {label = 'Development Tools', args = {'berkie_menu_misc_options_developer_options'}},
        {label = 'Connection Options', args = {'berkie_menu_misc_options_connection_options'}},
        {label = 'Enable Private Messages', description = 'If this is enabled, other people can send you a private message via the online players tab', checked = enablePMs, args = {'enable_pms'}, close = false},
        {label = 'Show Speed KM/h', description = 'Show a speedometer on your screen indicating your speed in KM/h', checked = speedKmh, args = {'speed_kmh'}, close = false},
        {label = 'Show Speed MPH', description = 'Show a speedometer on your screen indicating your speed in MPH', checked = speedMph, args = {'speed_mph'}, close = false},
        {label = 'Display Location', description = 'Shows your current location and heading, as well as the nearest cross road. WARNING: you should not keep this on at all times as this is a very heavy action', checked = displayLocation, args = {'display_location'}, close = false},
        {label = 'Show Time', description = 'Shows you the current time on screen', checked = showTime, args = {'show_time'}, close = false},
        {label = 'Show Join Notifications', description = 'Receive notifications when someone joins the server', checked = joinNotifs, args = {'show_join_notifs'}, close = false},
        {label = 'Show Quit Notifications', description = 'Receive notifications when someone leaves the server', checked = quitNotifs, args = {'show_quit_notifs'}, close = false}
    }
}, function(_, _, args)
    if string.match(args[1], 'berkie_menu') then
        if args[1] == 'berkie_menu_misc_options_teleport_options' then
            SetupTeleportOptions()
        end
        lib.showMenu(args[1], MenuIndexes[args[1]])
    end
end)

--#endregion Menu Registration

--#region Threads

CreateThread(function()
    while true do
        Wait(0)

        if cache.vehicle then
            if speedKmh then
                DrawTextOnScreen(('%s KM/h'):format(math.round(GetEntitySpeed(cache.vehicle) * 3.6, 1)), 0.995, 0.955, 0.7, 2, 4)
            end

            if speedMph then
                DrawTextOnScreen(('%s MPH'):format(math.round(GetEntitySpeed(cache.vehicle) * 2.23694, 1)), 0.995, speedKmh and 0.925 or 0.955, 0.7, 2, 4)
                if speedKmh then
                    HideHudComponentThisFrame(9)
                end
            end
        end

        if displayLocation then
            local currentPos = GetEntityCoords(cache.ped, true)
            local nodePos = GetNthClosestVehicleNode(currentPos.x, currentPos.y, currentPos.z, 0, 0, 0, 0) or currentPos
            local heading = GetEntityHeading(cache.ped)
            local safeZoneSize = GetSafeZoneSize()
            safeZoneSizeX = (1 / safeZoneSize / 3) - 0.358
            local _, crossing = GetStreetNameAtCoord(currentPos.x, currentPos.y, currentPos.z) or 1, 1
            local crossingName = GetStreetNameFromHashKey(crossing)
            local suffix = (crossingName and crossingName ~= '' and crossingName ~= 'NULL') and ('~t~ / %s'):format(crossingName) or ''
            local prefix = #(currentPos - nodePos) > 1400 and '~m~Near ~s~' or '~s~'
            local headingCharacter = (heading > 320 or heading < 45) and 'N' or (heading >= 45 and heading <= 135) and 'W' or (heading > 135 and heading < 225) and 'S' or 'E'

            SetScriptGfxAlign(0, 84)
            SetScriptGfxAlignParams(0, 0, 0, 0)

            SetTextWrap(0, 1)
            DrawTextOnScreen(prefix .. crossingName .. suffix, 0.234 + safeZoneSizeX, safeZoneSize - GetRenderedCharacterHeight(0.48, 6) - GetRenderedCharacterHeight(0.48, 6), 0.48, 1, 6, false)

            SetTextWrap(0, 1)
            DrawTextOnScreen(GetLabelText(GetNameOfZone(currentPos.x, currentPos.y, currentPos.z)), 0.234 + safeZoneSizeX, safeZoneSize - GetRenderedCharacterHeight(0.45, 6) - GetRenderedCharacterHeight(0.95, 6), 0.45, 1, 6, false)

            SetTextWrap(0, 1)
            DrawTextOnScreen('~t~|', 0.188 + safeZoneSizeX, safeZoneSize - GetRenderedCharacterHeight(1.2, 6) - GetRenderedCharacterHeight(0.4, 6), 1.2, 1, 6, false)

            SetTextWrap(0, 1)
            DrawTextOnScreen(headingCharacter, 0.208 + safeZoneSizeX, safeZoneSize - GetRenderedCharacterHeight(1.2, 6) - GetRenderedCharacterHeight(0.4, 6), 1.2, 0, 6, false)

            SetTextWrap(0, 1)
            DrawTextOnScreen('~t~|', 0.228 + safeZoneSizeX, safeZoneSize - GetRenderedCharacterHeight(1.2, 6) - GetRenderedCharacterHeight(0.4, 6), 1.2, 2, 6, false)

            ResetScriptGfxAlign()
        end

        if showTime then
            local hour = GetClockHours()
            local minute = GetClockMinutes()
            local formattedTime = string.format('%s:%s', hour < 10 and '0'..hour or hour, minute < 10 and '0'..minute or minute)
            SetScriptGfxAlign(0, 84)
            SetScriptGfxAlignParams(0, 0, 0, 0)
            DrawTextOnScreen('~c~'..formattedTime, 0.208 + safeZoneSizeX, GetSafeZoneSize() - GetRenderedCharacterHeight(0.4, 1), 0.4, 0, 6, false)
            ResetScriptGfxAlign()
        end
    end
end)

--#endregion Threads