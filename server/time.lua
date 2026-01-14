--#region Variables

local timeEnabled = GetConvar('bMenu.Enable_Time', 'true') == 'true'
local currentHour = tonumber(GetConvar('bMenu.Current_Hour', '7')) --[[@as number]]
local currentMinute = tonumber(GetConvar('bMenu.Current_Minute', '0')) --[[@as number]]
local timeSyncedWithMachine = GetConvar('bMenu.Sync_Time_To_Machine_Time', 'false') == 'true'
currentHour = currentHour < 0 and 0 or currentHour > 23 and 23 or currentHour
currentMinute = currentMinute < 0 and 0 or currentMinute > 59 and 59 or currentMinute

--#endregion Variables

--#region Events

---@param newHour integer
---@param newMinute integer
---@param newSyncState boolean
---@param newTimeEnabled boolean
RegisterNetEvent('bMenu:server:updateTime', function(newHour, newMinute, newSyncState, newTimeEnabled)
    newHour = newHour < 0 and 0 or newHour > 23 and 23 or newHour
    newMinute = newMinute < 0 and 0 or newMinute > 23 and 23 or newMinute

    SetConvarReplicated('bMenu.Enable_Time', tostring(newTimeEnabled))
    SetConvarReplicated('bMenu.Current_Hour', tostring(newHour))
    SetConvarReplicated('bMenu.Current_Minute', tostring(newMinute))
    SetConvarReplicated('bMenu.Sync_Time_To_Machine_Time', tostring(newSyncState))

    timeEnabled = newTimeEnabled
    timeSyncedWithMachine = newSyncState
    currentHour = newHour
    currentMinute = newMinute

    TriggerClientEvent('bMenu:client:updateTime', -1, newHour, newMinute, newSyncState, newTimeEnabled, true)
end)

--#endregion Events

--#region Threads

CreateThread(function()
    local sleep = tonumber(GetConvar('bMenu_ingame_minute_duration', '2000')) --[[@as number]]
    sleep = sleep < 100 and 100 or sleep
    while true do
        if timeEnabled then
            if timeSyncedWithMachine then
                local hour = os.date('%H')
                local minute = os.date('%M')
                currentHour = tonumber(hour) --[[@as number]]
                currentMinute = tonumber(minute) --[[@as number]]
                SetConvarReplicated('bMenu.Current_Hour', hour --[[@as string]])
                SetConvarReplicated('bMenu.Current_Minute', minute --[[@as string]])
                TriggerClientEvent('bMenu:client:updateTime', -1, currentHour, currentMinute, timeSyncedWithMachine, timeEnabled, false)
                Wait(10000)
            else
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

                SetConvarReplicated('bMenu.Current_Hour', tostring(currentHour))
                SetConvarReplicated('bMenu.Current_Minute', tostring(currentMinute))
                TriggerClientEvent('bMenu:client:updateTime', -1, currentHour, currentMinute, timeSyncedWithMachine, timeEnabled, false)
            end
        end

        Wait(sleep)
    end
end)

--#endregion Threads