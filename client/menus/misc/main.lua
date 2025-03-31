--#region Variables

local enablePMs = true
local speedKmh = false
local speedMph = false
local displayLocation = false
local showTime = false
local joinNotifs = GetConvarInt('chat_showJoins', 1) == 1
local quitNotifs = GetConvarInt('chat_showQuits', 1) == 1
local deathNotifs = false
local nightVision = false
local thermalVision = false
local playerNames = false
local driftMode = false
local playerNamesDistance = 500
local safeZoneSizeX = (1 / GetSafeZoneSize() / 3) - 0.358
local gamerTags = {}
local menuPositionIndexes = {
    ['top-right'] = 1,
    ['top-left'] = 2,
    ['bottom-left'] = 3,
    ['bottom-right'] = 4
}

local menuPositionNames = {}

for k, v in pairs(menuPositionIndexes) do
    menuPositionNames[v] = k
end

--#endregion Variables

--#region Functions

function CreateMiscMenu()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, 'Misc', {'TeleportOptions', 'DevTools', 'ConnectionOptions', 'Menu_Position', 'Toggle_PM', 'Show_Speed', 'Display_Location', 'Show_Time', 'Toggle_Join_Notifications', 'Toggle_Quit_Notifications', 'Toggle_Death_Notifications', 'Toggle_Night_Vision', 'Toggle_Thermal_Vision', 'Toggle_Player_Names'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_main'}}
    }
    local index = 1

    if perms.TeleportOptions then
        menuOptions[index] = {label = 'Teleport Options', args = {'bMenu_misc_options_teleport_options'}}
        index += 1
    end

    if perms.DevTools then
        menuOptions[index] = {label = 'Development Tools', args = {'bMenu_misc_options_developer_options'}}
        index += 1
    end

    if perms.ConnectionOptions then
        menuOptions[index] = {label = 'Connection Options', args = {'bMenu_misc_options_connection_options'}}
        index += 1
    end

    if perms.Menu_Position then
        menuOptions[index] = {label = 'Menu Position', values = {'Top Left', 'Top Right', 'Bottom Left', 'Bottom Right'}, defaultIndex = menuPositionIndexes[MenuPosition], args = {'menu_position'}, close = false}
        index += 1
    end

    if perms.Toggle_PM then
        menuOptions[index] = {label = 'Enable Private Messages', description = 'If this is enabled, other people can send you a private message via the online players tab', checked = enablePMs, args = {'enable_pms'}, close = false}
        index += 1
    end

    if perms.Show_Speed then
        menuOptions[index] = {label = 'Show Speed KM/h', description = 'Show a speedometer on your screen indicating your speed in KM/h', checked = speedKmh, args = {'speed_kmh'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Show Speed MPH', description = 'Show a speedometer on your screen indicating your speed in MPH', checked = speedMph, args = {'speed_mph'}, close = false}
        index += 1
    end

    if perms.Display_Location then
        menuOptions[index] = {label = 'Display Location', description = 'Shows your current location and heading, as well as the nearest cross road. WARNING: you should not keep this on at all times as this is a very heavy action', checked = displayLocation, args = {'display_location'}, close = false}
        index += 1
    end

    if perms.Show_Time then
        menuOptions[index] = {label = 'Show Time', description = 'Shows you the current time on screen', checked = showTime, args = {'show_time'}, close = false}
        index += 1
    end

    if perms.Toggle_Join_Notifications then
        menuOptions[index] = {label = 'Show Join Notifications', description = 'Receive notifications when someone joins the server', checked = joinNotifs, args = {'show_join_notifs'}, close = false}
        index += 1
    end

    if perms.Toggle_Quit_Notifications then
        menuOptions[index] = {label = 'Show Quit Notifications', description = 'Receive notifications when someone leaves the server', checked = quitNotifs, args = {'show_quit_notifs'}, close = false}
        index += 1
    end

    if perms.Toggle_Death_Notifications then
        menuOptions[index] = {label = 'Show Death Notifications', description = 'Receive notifications when someone dies or gets killed', checked = deathNotifs, args = {'show_death_notifs'}, close = false}
        index += 1
    end

    if perms.Toggle_Night_Vision then
        menuOptions[index] = {label = 'Toggle Night Vision', description = 'Enable or disable night vision', checked = nightVision, args = {'night_vision'}, close = false}
        index += 1
    end

    if perms.Toggle_Thermal_Vision then
        menuOptions[index] = {label = 'Toggle Thermal Vision', description = 'Enable or disable thermal vision', checked = thermalVision, args = {'thermal_vision'}, close = false}
        index += 1
    end

    if perms.Toggle_Player_Names then
        menuOptions[index] = {label = 'Show Player Names', description = 'Enables or disables players names over their head', checked = playerNames, args = {'show_player_names'}, close = false}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_misc_options',
        title = 'Miscellaneous Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_main')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_misc_options'] = selected
        end,
        onCheck = function(selected, checked, args)
            if args[1] == 'enable_pms' then
                enablePMs = checked
                lib.setMenuOptions('bMenu_misc_options', {label = 'Enable Private Messages', description = 'If this is enabled, other people can send you a private message via the online players tab', checked = checked, args = {'enable_pms'}, close = false}, selected)
            elseif args[1] == 'speed_kmh' then
                speedKmh = checked
                lib.setMenuOptions('bMenu_misc_options', {label = 'Show Speed KM/H', checked = checked, args = {'speed_kmh'}, close = false}, selected)
            elseif args[1] == 'speed_mph' then
                speedMph = checked
                lib.setMenuOptions('bMenu_misc_options', {label = 'Show Speed MPH', checked = checked, args = {'speed_mph'}, close = false}, selected)
            elseif args[1] == 'display_location' then
                displayLocation = checked
                lib.setMenuOptions('bMenu_misc_options', {label = 'Display Location', description = 'Shows your current location and heading, as well as the nearest cross road', checked = checked, args = {'display_location'}, close = false}, selected)
            elseif args[1] == 'show_time' then
                showTime = checked
                lib.setMenuOptions('bMenu_misc_options', {label = 'Show Time', description = 'Shows you the current time on screen', checked = checked, args = {'show_time'}, close = false}, selected)
            elseif args[1] == 'show_join_notifs' then
                joinNotifs = checked
                lib.callback.await('bMenu:server:setConvar', false, 'chat_showJoins', checked and 1 or 0, true, true, 'bMenu_misc_options', {label = 'Show Join Notifications', description = 'Receive notifications when someone joins the server', checked = checked, args = {'show_join_notifs'}, close = false}, selected)
                lib.setMenuOptions('bMenu_misc_options', {label = 'Show Join Notifications', description = 'Receive notifications when someone joins the server', checked = checked, args = {'show_join_notifs'}, close = false}, selected)
            elseif args[1] == 'show_quit_notifs' then
                quitNotifs = checked
                lib.callback.await('bMenu:server:setConvar', false, 'chat_showQuits', checked and 1 or 0, true, true, 'bMenu_misc_options', {label = 'Show Quit Notifications', description = 'Receive notifications when someone leaves the server', checked = checked, args = {'show_quit_notifs'}, close = false}, selected)
                lib.setMenuOptions('bMenu_misc_options', {label = 'Show Quit Notifications', description = 'Receive notifications when someone leaves the server', checked = checked, args = {'show_quit_notifs'}, close = false}, selected)
            elseif args[1] == 'show_death_notifs' then
                deathNotifs = checked
                lib.callback.await('bMenu:server:setConvar', false, 'bMenu_showDeaths', checked and 1 or 0)
                lib.setMenuOptions('bMenu_misc_options', {label = 'Show Death Notifications', description = 'Receive notifications when someone dies or gets killed', checked = deathNotifs, args = {'show_death_notifs'}, close = false}, selected)
            elseif args[1] == 'night_vision' then
                nightVision = checked
                SetNightvision(checked)
                lib.setMenuOptions('bMenu_misc_options', {label = 'Toggle Night Vision', description = 'Enable or disable night vision', checked = checked, args = {'night_vision'}, close = false}, selected)
            elseif args[1] == 'thermal_vision' then
                thermalVision = checked
                SetSeethrough(checked)
                lib.setMenuOptions('bMenu_misc_options', {label = 'Toggle Thermal Vision', description = 'Enable or disable thermal vision', checked = checked, args = {'thermal_vision'}, close = false}, selected)
            elseif args[1] == 'show_player_names' then
                playerNames = checked
                lib.setMenuOptions('bMenu_misc_options', {label = 'Show Player Names', description = 'Enables or disables players names over their head', checked = checked, args = {'show_player_names'}, close = false}, selected)
            end
        end,
        onSideScroll = function(selected, scrollIndex, args)
            if args[1] == 'menu_position' then
                MenuPosition = menuPositionNames[scrollIndex]
                lib.setMenuOptions('bMenu_misc_options', {label = 'Menu Position', values = {'Top Left', 'Top Right', 'Bottom Left', 'Bottom Right'}, defaultIndex = menuPositionIndexes[MenuPosition], args = {'menu_position'}, close = false}, selected)
                lib.hideMenu(false)
                lib.showMenu('bMenu_misc_options', MenuIndexes['bMenu_misc_options'])
            end
        end,
        options = menuOptions
    }, function(_, _, args)
        if string.match(args[1], 'bMenu') then
            if args[1] == 'bMenu_misc_options_teleport_options' then
                SetupTeleportOptions()
            elseif args[1] == 'bMenu_misc_options_connection_options' then
                SetupConnectionOptions()
            elseif args[1] == 'bMenu_misc_options_developer_options' then
                SetupDeveloperOptions()
            end

            lib.showMenu(args[1], MenuIndexes[args[1]])
        end
    end)
end

--#endregion Functions

--#region Events

AddEventHandler('gameEventTriggered', function(name, args)
	if name ~= 'CEventNetworkEntityDamage' or not deathNotifs then return end
	local victim, victimDied = args[1], args[4]
	if not victimDied or not IsPedAPlayer(victim) or (not IsPedDeadOrDying(victim, true) and not IsPedFatallyInjured(victim)) then return end
    local player = NetworkGetPlayerIndexFromPed(victim)
    local killerPed = GetPedSourceOfDeath(victim)
    local killerPlayer = NetworkGetPlayerIndexFromPed(killerPed)
    local deathCause = GetPedCauseOfDeath(victim)
    local description = killerPed ~= cache.ped and NetworkIsPlayerActive(killerPlayer) and ('%s was killed by %s with %s'):format(GetPlayerName(player), GetPlayerName(killerPlayer), deathCause) or ('%s was killed by %s'):format(GetPlayerName(player), deathCause)
    lib.notify({title = 'Death Notification', description = description, type = 'inform'})
end)

--#endregion Events

--#region Callbacks

lib.callback.register('bMenu:client:canSendMessage', function()
    return enablePMs
end)

--#endregion Callbacks

--#region Commands

RegisterCommand('bMenu_toggleDriftMode', function()
    driftMode = not driftMode

    if not cache.vehicle then return end

    SetVehicleReduceGrip(cache.vehicle, driftMode)
end, true)

RegisterKeyMapping('bMenu_toggleDriftMode', 'Toggle drift mode for bMenu', 'KEYBOARD', 'LSHIFT')

--#endregion Commands

--#region Threads

lib.onCache('vehicle', function(value, oldValue)
    if oldValue then SetVehicleReduceGrip(oldValue, false) end
    if value then SetVehicleReduceGrip(value, false) end
end)

CreateThread(function()
    while true do
        Wait(0)

        if cache.vehicle then
            if speedKmh then
                DrawTextOnScreen(('%s KM/h'):format(lib.math.round(GetEntitySpeed(cache.vehicle) * 3.6)), 0.995, 0.955, 0.7, 2, 4)
            end

            if speedMph then
                DrawTextOnScreen(('%s MPH'):format(lib.math.round(GetEntitySpeed(cache.vehicle) * 2.23694)), 0.995, speedKmh and 0.925 or 0.955, 0.7, 2, 4)
                if speedKmh then
                    HideHudComponentThisFrame(9)
                end
            end
        end

        if displayLocation then
            local currentPos = GetEntityCoords(cache.ped, true)
            local _, nodePos = GetNthClosestVehicleNode(currentPos.x, currentPos.y, currentPos.z, 0, 0, 0, 0)
            nodePos = nodePos or currentPos
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

        if playerNames then
            local players = GetActivePlayers()
            local coords = GetEntityCoords(cache.ped)
            for i = 1, #players do
                local player = players[i]
                local ped = GetPlayerPed(player)
                local pedCoords = GetEntityCoords(ped)
                if #(pedCoords - coords) < playerNamesDistance then
                    if not gamerTags[player] then
                        gamerTags[player] = CreateFakeMpGamerTag(ped, GetPlayerName(player) .. ' [' .. GetPlayerServerId(player) .. ']', false, false, '', 0)
                    end
                    SetMpGamerTagVisibility(gamerTags[player], 2, true)
                    local wantedLevel = GetPlayerWantedLevel(player)
                    if wantedLevel > 0 then
                        SetMpGamerTagVisibility(gamerTags[player], 7, true)
                        SetMpGamerTagWantedLevel(gamerTags[player], wantedLevel)
                    else
                        SetMpGamerTagVisibility(gamerTags[player], 7, false)
                    end
                elseif gamerTags[player] then
                    RemoveMpGamerTag(gamerTags[player])
                    gamerTags[player] = nil
                end
            end
        else
            if table.type(gamerTags) ~= 'empty' then
                for _, v in pairs(gamerTags) do
                    RemoveMpGamerTag(v)
                end
                table.wipe(gamerTags)
            end
        end
    end
end)

--#endregion Threads
