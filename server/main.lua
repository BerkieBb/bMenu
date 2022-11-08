--#region Startup

-- I don't want you renaming this because this uses kvp and that requires the resource name to be the same across servers to work correctly
if GetCurrentResourceName() ~= 'berkie_menu' then
    error('Please don\'t rename this resource, change the folder name (back) to \'berkie_menu\' (case sensitive) to make sure the saved data can be saved and fetched accordingly from the cache.')
    return
end

--#endregion Startup

--#region Variables

local cloudTypes = {
    'Cloudy 01',
    'RAIN',
    'horizonband1',
    'horizonband2',
    'Puffs',
    'Wispy',
    'Horizon',
    'Stormy 01',
    'Clear 01',
    'Snowy 01',
    'Contrails',
    'altostratus',
    'Nimbus',
    'Cirrus',
    'cirrocumulus',
    'stratoscumulus',
    'horizonband3',
    'Stripey',
    'horsey',
    'shower'
}

local weatherTypes = {
    ['EXTRASUNNY'] = 'Extra Sunny',
    ['CLEAR'] = 'Clear',
    ['NEUTRAL'] = 'Neutral',
    ['SMOG'] = 'Smog',
    ['FOGGY'] = 'Foggy',
    ['CLOUDS'] = 'Cloudy',
    ['OVERCAST'] = 'Overcast',
    ['CLEARING'] = 'Clearing',
    ['RAIN'] = 'Rainy',
    ['THUNDER'] = 'Thunder',
    ['BLIZZARD'] = 'Blizzard',
    ['SNOW'] = 'Snow',
    ['SNOWLIGHT'] = 'Light Snow',
    ['XMAS'] = 'X-MAS Snow',
    ['HALLOWEEN'] = 'Halloween'
}

local currentHour = tonumber(GetConvar('berkie_menu_current_hour', '7')) --[[@as number]]
local currentMinute = tonumber(GetConvar('berkie_menu_current_minute', '0')) --[[@as number]]
local timeFrozen = GetConvar('berkie_menu_freeze_time', 'false') == 'true'
local timeSyncedWithMachine = GetConvar('berkie_menu_sync_time_to_machine_time', 'false') == 'true'
currentHour = currentHour < 0 and 0 or currentHour > 23 and 23 or currentHour
currentMinute = currentMinute < 0 and 0 or currentMinute > 59 and 59 or currentMinute
local dynamicWeather = GetConvar('berkie_menu_dynamic_weather', 'true') == 'true'
local dynamicWeatherTimer = tonumber(GetConvar('berkie_menu_dynamic_weather_timer', '1')) --[[@as number]]
dynamicWeatherTimer = dynamicWeatherTimer < 0 and 1 or dynamicWeatherTimer
local currentWeather = GetConvar('berkie_menu_current_weather', 'EXTRASUNNY'):upper()
currentWeather = not weatherTypes[currentWeather] and 'EXTRASUNNY' or currentWeather
local lastWeatherChange = 0

--#endregion Variables

--#region Callbacks

lib.callback.register('berkie_menu:server:getOnlinePlayers', function()
    local players = GetPlayers()
    local data = {}
    for i = 1, #players do
        local src = players[i]
        data[#data + 1] = {
            source = tonumber(src),
            name = GetPlayerName(src)
        }
    end
    return data
end)

lib.callback.register('berkie_menu:server:playerListAction', function(source, action, playerSource, canActOnSelf, message)
    if source == playerSource and not canActOnSelf then return false, 'You can\'t act on yourself' end

    local messageArg = action == 'message'
    local teleportVehicleArg = action == 'teleport_vehicle'
    local teleportArg = action == 'teleport'
    local summonArg = action == 'summon'
    local spectateArg = action == 'spectate'
    local waypointArg = action == 'waypoint'
    local blipArg = action == 'blip'
    local killArg = action == 'kill'
    local playerName = GetPlayerName(playerSource)
    local playerPed = GetPlayerPed(playerSource)
    local ped = GetPlayerPed(source)

    if messageArg then
        TriggerClientEvent('chat:addMessage', playerSource, {
            color = { 255, 0, 0 },
            multiline = true,
            args = { ('PM from %s'):format(GetPlayerName(source)), message }
        })
        return true, ('Successfully sent a message to %s'):format(playerName)
    elseif teleportArg then
        local playerCoords = GetEntityCoords(playerPed)
        SetEntityCoords(ped, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false, false)
        return true, ('Successfully teleported to %s'):format(playerName)
    elseif teleportVehicleArg then
        local veh = GetVehiclePedIsIn(playerPed, false)
        if veh == 0 then return false, ('%s is not in a vehicle'):format(playerName) end
        return true, ('Successfully teleported into the vehicle of %s'):format(playerName), NetworkGetNetworkIdFromEntity(veh)
    elseif summonArg then
        local playerCoords = GetEntityCoords(ped)
        SetEntityCoords(playerPed, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false, false)
        return true, ('Successfully summoned %s'):format(playerName)
    elseif spectateArg then
        return true, ('Successfully spectating %s'):format(playerName), GetEntityCoords(playerPed)
    elseif waypointArg then
        return true, ('Successfully set your waypoint to %s'):format(playerName), GetEntityCoords(playerPed).xy
    elseif blipArg then
        return true, ('Successfully toggled the blip to %s'):format(playerName), NetworkGetNetworkIdFromEntity(playerPed)
    elseif killArg then
        return true, ('Successfully killed %s'):format(playerName), NetworkGetNetworkIdFromEntity(playerPed)
    end

    return false, ('Invalid action %s'):format(action)
end)

lib.callback.register('berkie_menu:server:spawnVehicle', function(_, model, coords)
    local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)
    while not DoesEntityExist(tempVehicle) do
        Wait(0)
    end
    local entityType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)
    local veh = CreateVehicleServerSetter(model, entityType, coords.x, coords.y, coords.z, coords.w)
    while not DoesEntityExist(veh) do
        Wait(0)
    end
    return NetworkGetNetworkIdFromEntity(veh)
end)

--#endregion Callbacks

--#region Events

RegisterNetEvent('berkie_menu:server:updateTime', function(newHour, newMinute, newFreezeState, newSyncState)
    newHour = newHour < 0 and 0 or newHour > 23 and 23 or newHour
    newMinute = newMinute < 0 and 0 or newMinute > 23 and 23 or newMinute
    SetConvarReplicated('berkie_menu_current_hour', tostring(newHour))
    SetConvarReplicated('berkie_menu_current_minute', tostring(newMinute))
    SetConvarReplicated('berkie_menu_freeze_time', tostring(newFreezeState))
    SetConvarReplicated('berkie_menu_sync_time_to_machine_time', tostring(newSyncState))
    timeSyncedWithMachine = newSyncState
    timeFrozen = newFreezeState
    currentHour = newHour
    currentMinute = newMinute
end)

RegisterNetEvent('berkie_menu:server:updateWeather', function(newWeather, newBlackoutState, newDynamicState, newSnowState)
    if not weatherTypes[newWeather] then return end

    SetConvarReplicated('berkie_menu_current_weather', newWeather)
    SetConvarReplicated('berkie_menu_enable_blackout', tostring(newBlackoutState))
    SetConvarReplicated('berkie_menu_dynamic_weather', tostring(newDynamicState))
    SetConvarReplicated('berkie_menu_enable_snow_effects', tostring(newSnowState))
    currentWeather = newWeather
    dynamicWeather = newDynamicState
    lastWeatherChange = GetGameTimer()

    if newWeather == 'XMAS' or newWeather == 'SNOWLIGHT' or newWeather == 'SNOW' or newWeather == 'BLIZZARD' then
        SetConvarReplicated('berkie_menu_enable_snow_effects', 'true')
    elseif GetConvar('berkie_menu_enable_snow_effects', 'false') == 'true' then
        SetConvarReplicated('berkie_menu_enable_snow_effects', 'false')
    end
end)

RegisterNetEvent('berkie_menu:server:setClouds', function(removeClouds)
    if removeClouds then
        TriggerClientEvent('berkie_menu:client:setClouds', -1, 0, 'removed')
        return
    end

    TriggerClientEvent('berkie_menu:client:setClouds', -1, math.random(), cloudTypes[math.random(#cloudTypes)])
end)

--#endregion Events

--#region Threads

CreateThread(function()
    local sleep = tonumber(GetConvar('berkie_menu_ingame_minute_duration', '2000')) --[[@as number]]
    sleep = sleep < 100 and 100 or sleep
    while true do
        if timeSyncedWithMachine then
            local hour = os.date('%H')
            local minute = os.date('%M')
            currentHour = tonumber(hour) --[[@as number]]
            currentMinute = tonumber(minute) --[[@as number]]
            SetConvarReplicated('berkie_menu_current_hour', hour --[[@as string]])
            SetConvarReplicated('berkie_menu_current_minute', minute --[[@as string]])
            Wait(10000)
        else
            if not timeFrozen then
                if currentMinute + 1 > 59 then
                    currentMinute = 0
                    if currentHour + 1 > 23 then
                        currentHour = 0
                    else
                        currentHour += 1
                    end
                else
                    currentMinute += 1
                end
                SetConvarReplicated('berkie_menu_current_hour', tostring(currentHour))
                SetConvarReplicated('berkie_menu_current_minute', tostring(currentMinute))
            end
            Wait(sleep)
        end
    end
end)

CreateThread(function()
    while true do
        if dynamicWeather then
            Wait(dynamicWeatherTimer * 60000)

            if currentWeather == 'XMAS' or currentWeather == 'HALLOWEEN' or currentWeather == 'NEUTRAL' then
                SetConvarReplicated('berkie_menu_dynamic_weather', 'false')
                dynamicWeather = false
            else
                if GetGameTimer() - lastWeatherChange > (dynamicWeatherTimer * 60000) then
                    if currentWeather == 'RAIN' or currentWeather == 'THUNDER' then
                        currentWeather = 'CLEARING'
                    elseif currentWeather == 'CLEARING' then
                        currentWeather = 'CLOUDS'
                    else
                        local rand = math.random(0, 20)
                        if rand <= 5 then
                            currentWeather = currentWeather == 'EXTRASUNNY' and 'CLEAR' or 'EXTRASUNNY'
                        elseif rand >= 6 and rand <= 8 then
                            currentWeather = currentWeather == 'SMOG' and 'FOGGY' or 'SMOG'
                        elseif rand >= 9 and rand <= 14 then
                            currentWeather = currentWeather == 'CLOUDS' and 'OVERCAST' or 'CLOUDS'
                        elseif rand == 15 then
                            currentWeather = currentWeather == 'OVERCAST' and 'THUNDER' or 'OVERCAST'
                        elseif rand == 16 then
                            currentWeather = currentWeather == 'CLOUDS' and 'EXTRASUNNY' or 'RAIN'
                        else
                            currentWeather = currentWeather == 'FOGGY' and 'SMOG' or 'FOGGY'
                        end

                        SetConvarReplicated('berkie_menu_current_weather', currentWeather)

                        lastWeatherChange = GetGameTimer()
                    end
                end
            end
        else
            Wait(5000)
        end
    end
end)

--#endregion Threads