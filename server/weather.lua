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

local dynamicWeather = GetConvar('bMenu.Dynamic_Weather', 'true') == 'true'
local dynamicWeatherTimer = tonumber(GetConvar('bMenu.Dynamic_Weather_timer', '1')) --[[@as number]]
dynamicWeatherTimer = dynamicWeatherTimer < 0 and 1 or dynamicWeatherTimer
local currentWeather = GetConvar('bMenu.Current_Weather', 'EXTRASUNNY'):upper()
currentWeather = not weatherTypes[currentWeather] and 'EXTRASUNNY' or currentWeather
local lastWeatherChange = 0

--#endregion Variables

--#region Events

RegisterNetEvent('bMenu:server:updateWeather', function(newWeather, newBlackoutState, newDynamicState, newSnowState)
    if not weatherTypes[newWeather] then return end

    SetConvarReplicated('bMenu.Current_Weather', newWeather)
    SetConvarReplicated('bMenu.Enable_Blackout', tostring(newBlackoutState))
    SetConvarReplicated('bMenu.Dynamic_Weather', tostring(newDynamicState))
    SetConvarReplicated('bMenu.Enable_Snow_Effects', tostring(newSnowState))
    currentWeather = newWeather
    dynamicWeather = newDynamicState
    lastWeatherChange = GetGameTimer()

    if newWeather == 'XMAS' or newWeather == 'SNOWLIGHT' or newWeather == 'SNOW' or newWeather == 'BLIZZARD' then
        SetConvarReplicated('bMenu.Enable_Snow_Effects', 'true')
    elseif GetConvar('bMenu.Enable_Snow_Effects', 'false') == 'true' then
        SetConvarReplicated('bMenu.Enable_Snow_Effects', 'false')
    end
end)

RegisterNetEvent('bMenu:server:setClouds', function(removeClouds)
    if removeClouds then
        TriggerClientEvent('bMenu:client:setClouds', -1, 0, 'removed')
        return
    end

    TriggerClientEvent('bMenu:client:setClouds', -1, math.random(), cloudTypes[math.random(#cloudTypes)])
end)

--#endregion Events

--#region Threads

CreateThread(function()
    while true do
        if dynamicWeather then
            Wait(dynamicWeatherTimer * 60000)

            if currentWeather == 'XMAS' or currentWeather == 'HALLOWEEN' or currentWeather == 'NEUTRAL' then
                SetConvarReplicated('bMenu.Dynamic_Weather', 'false')
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

                        SetConvarReplicated('bMenu.Current_Weather', currentWeather)

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