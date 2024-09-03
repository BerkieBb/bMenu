--#region Variables

local weatherIndexes = {
    EXTRASUNNY = {4, 'Extra Sunny'},
    CLEAR = {5, 'Clear'},
    NEUTRAL = {6, 'Neutral'},
    SMOG = {7, 'Smog'},
    FOGGY = {8, 'Foggy'},
    CLOUDS = {9, 'Cloudy'},
    OVERCAST = {10, 'Overcast'},
    CLEARING = {11, 'Clearing'},
    RAIN = {12, 'Rainy'},
    THUNDER = {13, 'Thunder'},
    BLIZZARD = {14, 'Blizzard'},
    SNOW = {15, 'Snow'},
    SNOWLIGHT = {16, 'Light Snow'},
    XMAS = {17, 'X-MAS Snow'},
    HALLOWEEN = {18, 'Halloween'}
}

local timeSyncedWithMachine = GetConvar('bMenu.Sync_Time_To_Machine_Time', 'false') == 'true'
local timeFrozen = GetConvar('bMenu.Freeze_Time', 'false') == 'true'
local currentHour = tonumber(GetConvar('bMenu.Current_Hour', '7')) --[[@as number]]
local currentMinute = tonumber(GetConvar('bMenu.Current_Minute', '0')) --[[@as number]]
currentHour = currentHour < 0 and 0 or currentHour > 23 and 23 or currentHour
currentMinute = currentMinute < 0 and 0 or currentMinute > 23 and 23 or currentMinute
local showTimeOnScreen = false
local dynamicWeather = GetConvar('bMenu.Dynamic_Weather', 'true') == 'true'
local blackout = GetConvar('bMenu.Enable_Blackout', 'false') == 'true'
local snowEffects = GetConvar('bMenu.Enable_Snow_Effects', 'false') == 'true'
local checkedDynamicWeather = dynamicWeather
local checkedBlackout = blackout
local checkedSnowEffects = snowEffects
local currentWeather = GetConvar('bMenu.Current_Weather', 'EXTRASUNNY'):upper()
currentWeather = not weatherIndexes[currentWeather] and 'EXTRASUNNY' or currentWeather
local currentChecked = 'EXTRASUNNY' -- Leave this so the checkmark can move itself accordingly in the loop
local weatherChangeTime = tonumber(GetConvar('bMenu.Weather_Change_Time', '5')) --[[@as number]]
weatherChangeTime = weatherChangeTime < 0 and 0 or weatherChangeTime
local changingWeather = false

--#endregion Variables

--#region Functions

local function createTimeOptions()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'WorldRelated', 'TimeOptions'}, {'Freeze_Unfreeze_Time', 'Sync_Time', 'Show_Time', 'Presets', 'Set_Hour', 'Set_Minute'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_world_related_options'}}
    }
    local index = 1

    if perms.Freeze_Unfreeze_Time then
        menuOptions[index] = {label = 'Freeze/Unfreeze Time', args = {'freeze_time'}, close = false}
        index += 1
    end

    if perms.Sync_Time then
        menuOptions[index] = {label = 'Sync Time To Server', args = {'sync_to_server'}, close = false}
        index += 1
    end

    if perms.Show_Time then
        menuOptions[index] = {label = 'Show Time On Screen', args = {'show_time'}, checked = showTimeOnScreen, close = false}
        index += 1
    end

    if perms.Presets then
        menuOptions[index] = {label = 'Early Morning (06:00, 6 AM)', args = {'set_time_preset', 6}, close = false}
        index += 1

        menuOptions[index] = {label = 'Morning (09:00, 9 AM)', args = {'set_time_preset', 9}, close = false}
        index += 1

        menuOptions[index] = {label = 'Noon (12:00, 12 PM)', args = {'set_time_preset', 12}, close = false}
        index += 1

        menuOptions[index] = {label = 'Early Afternoon (15:00, 3 PM)', args = {'set_time_preset', 15}, close = false}
        index += 1

        menuOptions[index] = {label = 'Afternoon (18:00, 6 PM)', args = {'set_time_preset', 18}, close = false}
        index += 1

        menuOptions[index] = {label = 'Evening (21:00, 9 PM)', args = {'set_time_preset', 21}, close = false}
        index += 1

        menuOptions[index] = {label = 'Midnight (00:00, 12 AM)', args = {'set_time_preset', 0}, close = false}
        index += 1

        menuOptions[index] = {label = 'Night (03:00, 3 AM)', args = {'set_time_preset', 3}, close = false}
        index += 1
    end

    if perms.Set_Hour then
        menuOptions[index] = {label = 'Set Custom Hour', args = {'set_time_custom', 'hours'}, values = {'00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23'}, defaultIndex = 1, close = false}
        index += 1
    end

    if perms.Set_Minute then
        menuOptions[index] = {label = 'Set Custom Minute', args = {'set_time_custom', 'minutes'}, values = {'00', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', '51', '52', '53', '54', '55', '56', '57', '58', '59'}, defaultIndex = 1, close = false}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_time_options',
        title = 'Time Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_world_related_options')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_time_options'] = selected
        end,
        onCheck = function(selected, checked, args)
            if args[1] == 'show_time' then
                showTimeOnScreen = checked
                lib.setMenuOptions('bMenu_time_options', {label = 'Show Time On Screen', args = {'show_time'}, checked = showTimeOnScreen, close = false}, selected)
            end
        end,
        options = menuOptions
    }, function(_, scrollIndex, args)
        if args[1] == 'bMenu_world_related_options' then
            lib.showMenu(args[1], MenuIndexes[args[1]])
            return
        end

        timeSyncedWithMachine = GetConvar('bMenu.Sync_Time_To_Machine_Time', 'false') == 'true'

        if args[1] == 'sync_to_server' then
            TriggerServerEvent('bMenu:server:updateTime', currentHour, currentMinute, timeFrozen, not timeSyncedWithMachine)
        end

        if timeSyncedWithMachine and args[1] ~= 'sync_to_server' then
            lib.notify({
                description = 'Can\'t change the time when the time is synced to the server',
                type = 'error'
            })
            return
        end

        timeFrozen = GetConvar('bMenu.Freeze_Time', 'false') == 'true'
        if args[1] == 'freeze_time' then
            TriggerServerEvent('bMenu:server:updateTime', currentHour, currentMinute, not timeFrozen, timeSyncedWithMachine)
        elseif args[1] == 'set_time_preset' then
            TriggerServerEvent('bMenu:server:updateTime', args[2], 0, timeFrozen, timeSyncedWithMachine)
        elseif args[1] == 'set_time_custom' then
            if args[2] == 'hours' then
                local hour = scrollIndex - 1
                TriggerServerEvent('bMenu:server:updateTime', hour, currentMinute, timeFrozen, timeSyncedWithMachine)
            elseif args[2] == 'minutes' then
                local minute = scrollIndex - 1
                TriggerServerEvent('bMenu:server:updateTime', currentHour, minute, timeFrozen, timeSyncedWithMachine)
            end
        end
    end)
end

local function createWeatherOptions()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, {'WorldRelated', 'WeatherOptions'}, {'Toggle_Dynamic_Weather', 'Toggle_Blackout', 'Toggle_Snow_Effects', 'Change_Weather_Type', 'Set_Clouds'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_world_related_options'}}
    }
    local index = 1

    if perms.Toggle_Dynamic_Weather then
        menuOptions[index] = {label = 'Dynamic Weather', description = 'Whether to randomize the state of the weather or not', args = {'dynamic_weather'}, checked = checkedDynamicWeather, close = false}
        index += 1
    end

    if perms.Toggle_Blackout then
        menuOptions[index] = {label = 'Blackout', description = 'If turned on, disables all light sources', args = {'blackout'}, checked = checkedBlackout, close = false}
        index += 1
    end

    if perms.Toggle_Snow_Effects then
        menuOptions[index] = {label = 'Snow Effects', description = 'This will force snow to appear on the ground and enable snow particles for peds and vehicles. Combine with X-MAS or Light Snow for the best results', args = {'snow_effects'}, checked = checkedSnowEffects, close = false}
        index += 1
    end

    if perms.Change_Weather_Type then
        menuOptions[index] = {label = 'Extra Sunny', icon = currentWeather == 'EXTRASUNNY' and 'circle-check', args = {'set_weather', 'EXTRASUNNY'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Clear', icon = currentWeather == 'CLEAR' and 'circle-check', args = {'set_weather', 'CLEAR'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Neutral', icon = currentWeather == 'NEUTRAL' and 'circle-check', args = {'set_weather', 'NEUTRAL'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Smog', icon = currentWeather == 'SMOG' and 'circle-check', args = {'set_weather', 'SMOG'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Foggy', icon = currentWeather == 'FOGGY' and 'circle-check', args = {'set_weather', 'FOGGY'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Cloudy', icon = currentWeather == 'CLOUDS' and 'circle-check', args = {'set_weather', 'CLOUDS'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Overcast', icon = currentWeather == 'OVERCAST' and 'circle-check', args = {'set_weather', 'OVERCAST'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Clearing', icon = currentWeather == 'CLEARING' and 'circle-check', args = {'set_weather', 'CLEARING'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Rainy', icon = currentWeather == 'RAIN' and 'circle-check', args = {'set_weather', 'RAIN'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Thunder', icon = currentWeather == 'THUNDER' and 'circle-check', args = {'set_weather', 'THUNDER'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Blizzard', icon = currentWeather == 'BLIZZARD' and 'circle-check', args = {'set_weather', 'BLIZZARD'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Snow', icon = currentWeather == 'SNOW' and 'circle-check', args = {'set_weather', 'SNOW'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Light Snow', icon = currentWeather == 'SNOWLIGHT' and 'circle-check', args = {'set_weather', 'SNOWLIGHT'}, close = false}
        index += 1

        menuOptions[index] = {label = 'X-MAS Snow', icon = currentWeather == 'XMAS' and 'circle-check', args = {'set_weather', 'XMAS'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Halloween', icon = currentWeather == 'HALLOWEEN' and 'circle-check', args = {'set_weather', 'HALLOWEEN'}, close = false}
        index += 1
    end

    if perms.Set_Clouds then
        menuOptions[index] = {label = 'Remove All Clouds', args = {'remove_clouds'}, close = false}
        index += 1

        menuOptions[index] = {label = 'Randomize Clouds', args = {'randomize_clouds'}, close = false}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_weather_options',
        title = 'Weather Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_world_related_options')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_weather_options'] = selected
        end,
        onCheck = function(selected, checked, args)
            blackout = GetConvar('bMenu.Enable_Blackout', 'false') == 'true'
            snowEffects = GetConvar('bMenu.Enable_Snow_Effects', 'false') == 'true'
            dynamicWeather = GetConvar('bMenu.Dynamic_Weather', 'true') == 'true'

            if args[1] == 'dynamic_weather' then
                checkedDynamicWeather = checked
                TriggerServerEvent('bMenu:server:updateWeather', currentWeather, blackout, checked, snowEffects)
                lib.setMenuOptions('bMenu_weather_options', {label = 'Dynamic Weather', description = 'Whether to randomize the state of the weather or not', args = {'dynamic_weather'}, checked = checked, close = false}, selected)
            elseif args[1] == 'blackout' then
                checkedBlackout = checked
                TriggerServerEvent('bMenu:server:updateWeather', currentWeather, checked, dynamicWeather, snowEffects)
                lib.setMenuOptions('bMenu_weather_options', {label = 'Blackout', description = 'If turned on, disables all light sources', args = {'blackout'}, checked = checked, close = false}, selected)
            elseif args[1] == 'snow_effects' then
                checkedSnowEffects = checked
                TriggerServerEvent('bMenu:server:updateWeather', currentWeather, blackout, dynamicWeather, checked)
                lib.setMenuOptions('bMenu_weather_options', {label = 'Snow Effects', description = 'This will force snow to appear on the ground and enable snow particles for peds and vehicles. Combine with X-MAS or Light Snow for the best results', args = {'snow_effects'}, checked = checked, close = false}, selected)
            end
        end,
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'bMenu_world_related_options' then
            lib.showMenu(args[1], MenuIndexes[args[1]])
            return
        end

        if args[1] == 'set_weather' then
            if changingWeather then
                lib.notify({
                    description = 'Already changing weather, please wait',
                    type = 'error'
                })
                return
            end

            lib.notify({
                description = ('Changing weather to %s'):format(weatherIndexes[args[2]][2]),
                type = 'inform',
                duration = weatherChangeTime * 1000 + 2000
            })
            changingWeather = true
            blackout = GetConvar('bMenu.Enable_Blackout', 'false') == 'true'
            snowEffects = GetConvar('bMenu.Enable_Snow_Effects', 'false') == 'true'
            dynamicWeather = GetConvar('bMenu.Dynamic_Weather', 'true') == 'true'
            TriggerServerEvent('bMenu:server:updateWeather', args[2], blackout, dynamicWeather, snowEffects)
        elseif args[1] == 'remove_clouds' then
            TriggerServerEvent('bMenu:server:setClouds', true)
        elseif args[1] == 'randomize_clouds' then
            TriggerServerEvent('bMenu:server:setClouds', false)
        end
    end)
end

function CreateWorldMenu()
    local perms = lib.callback.await('bMenu:server:hasConvarPermission', false, 'WorldRelated', {'TimeOptions', 'WeatherOptions'})
    local menuOptions = {
        {label = 'No access', description = 'You don\'t have access to any options, press enter to return', args = {'bMenu_main'}}
    }
    local index = 1

    if perms.TimeOptions then
        menuOptions[index] = {label = 'Time Options', args = {'bMenu_time_options'}}
        index += 1
    end

    if perms.WeatherOptions then
        menuOptions[index] = {label = 'Weather Options', args = {'bMenu_weather_options'}}
        index += 1
    end

    lib.registerMenu({
        id = 'bMenu_world_related_options',
        title = 'World Related Options',
        position = MenuPosition,
        onClose = function(keyPressed)
            CloseMenu(false, keyPressed, 'bMenu_main')
        end,
        onSelected = function(selected)
            MenuIndexes['bMenu_world_related_options'] = selected
        end,
        options = menuOptions
    }, function(_, _, args)
        if args[1] == 'bMenu_time_options' then
            createTimeOptions()
        elseif args[1] == 'bMenu_weather_options' then
            createWeatherOptions()
        end

        lib.showMenu(args[1], MenuIndexes[args[1]])
    end)
end

--#endregion Functions

--#region Events

RegisterNetEvent('bMenu:client:setClouds', function(opacity, cloudType)
    if opacity == 0 and cloudType == 'removed' then
        ClearCloudHat()
        return
    end

    SetCloudsAlpha(opacity)
    LoadCloudHat(cloudType, 4)
end)

--#endregion Events

--#region Threads

CreateThread(function()
    local sleep = 100
    while true do
        if showTimeOnScreen then
            sleep = 0
            DrawTextOnScreen(('Current Time: %s:%s'):format(currentHour < 10 and '0'..currentHour or currentHour, currentMinute < 10 and '0'..currentMinute or currentMinute), 0.5, 0.0)
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        currentHour = tonumber(GetConvar('bMenu.Current_Hour', '7')) --[[@as number]]
        currentMinute = tonumber(GetConvar('bMenu.Current_Minute', '0')) --[[@as number]]
        currentHour = currentHour < 0 and 0 or currentHour > 23 and 23 or currentHour
        currentMinute = currentMinute < 0 and 0 or currentMinute > 59 and 59 or currentMinute
        NetworkOverrideClockTime(currentHour, currentMinute, 0)
        Wait(1000)
    end
end)

CreateThread(function()
    local changedThings = false
    while true do
        local openMenu = lib.getOpenMenu()
        blackout = GetConvar('bMenu.Enable_Blackout', 'false') == 'true'
        snowEffects = GetConvar('bMenu.Enable_Snow_Effects', 'false') == 'true'
        dynamicWeather = GetConvar('bMenu.Dynamic_Weather', 'true') == 'true'

        if checkedBlackout ~= blackout and openMenu == 'bMenu_weather_options' then
            lib.setMenuOptions('bMenu_weather_options', {label = 'Blackout', description = 'If turned on, disables all light sources', args = {'blackout'}, checked = blackout, close = false}, 2)
            checkedBlackout = blackout
            changedThings = true
        end

        if checkedSnowEffects ~= snowEffects and openMenu == 'bMenu_weather_options' then
            lib.setMenuOptions('bMenu_weather_options', {label = 'Snow Effects', description = 'This will force snow to appear on the ground and enable snow particles for peds and vehicles. Combine with X-MAS or Light Snow for the best results', args = {'snow_effects'}, checked = snowEffects, close = false}, 3)
            checkedSnowEffects = snowEffects
            changedThings = true
        end

        if checkedDynamicWeather ~= dynamicWeather and openMenu == 'bMenu_weather_options' then
            lib.setMenuOptions('bMenu_weather_options', {label = 'Dynamic Weather', description = 'Whether to randomize the state of the weather or not', args = {'dynamic_weather'}, checked = dynamicWeather, close = false}, 1)
            checkedDynamicWeather = dynamicWeather
            changedThings = true
        end

        ForceSnowPass(snowEffects)
        SetForceVehicleTrails(snowEffects)
        SetForcePedFootstepsTracks(snowEffects)

        if snowEffects then
            lib.requestNamedPtfxAsset('core_snow')
            UseParticleFxAsset('core_snow')
        else
            RemoveNamedPtfxAsset('core_snow')
        end

        SetArtificialLightsState(blackout)

        currentWeather = GetConvar('bMenu.Current_Weather', 'EXTRASUNNY'):upper()
        currentWeather = not weatherIndexes[currentWeather] and 'EXTRASUNNY' or currentWeather

        if currentChecked ~= currentWeather and openMenu == 'bMenu_weather_options' then
            local oldData = weatherIndexes[currentChecked]
            local newData = weatherIndexes[currentWeather]
            lib.setMenuOptions('bMenu_weather_options', {label = oldData[2], args = {'set_weather', currentChecked}, close = false}, oldData[1])
            lib.setMenuOptions('bMenu_weather_options', {label = newData[2], icon = 'circle-check', args = {'set_weather', currentWeather}, close = false}, newData[1])
            currentChecked = currentWeather
            changedThings = true
        end

        if changedThings and openMenu == 'bMenu_weather_options' then
            lib.hideMenu(false)
            Wait(100)
            lib.showMenu('bMenu_weather_options', MenuIndexes['bMenu_weather_options'])
            changedThings = false
        elseif changedThings then
            changedThings = false
        end

        if GetNextWeatherTypeHashName() ~= joaat(currentWeather) then
            SetWeatherTypeOvertimePersist(currentWeather, weatherChangeTime)
            Wait(weatherChangeTime * 1000 + 2000)
            if changingWeather then
                lib.notify({
                    description = ('Changed weather to %s'):format(weatherIndexes[currentWeather][2]),
                    type = 'success'
                })
            end
            changingWeather = false
            TriggerEvent('bMenu:client:weatherChangeComplete', currentWeather)
        end
        Wait(1000)
    end
end)

--#endregion Threads