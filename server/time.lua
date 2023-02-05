--#region Variables

local currentHour = tonumber(GetConvar('bMenu_current_hour', '7')) --[[@as number]]
local currentMinute = tonumber(GetConvar('bMenu_current_minute', '0')) --[[@as number]]
local timeFrozen = GetConvar('bMenu_freeze_time', 'false') == 'true'
local timeSyncedWithMachine = GetConvar('bMenu_sync_time_to_machine_time', 'false') == 'true'
currentHour = currentHour < 0 and 0 or currentHour > 23 and 23 or currentHour
currentMinute = currentMinute < 0 and 0 or currentMinute > 59 and 59 or currentMinute

--#endregion Variables

--#region Events

RegisterNetEvent('bMenu:server:updateTime', function(newHour, newMinute, newFreezeState, newSyncState)
    newHour = newHour < 0 and 0 or newHour > 23 and 23 or newHour
    newMinute = newMinute < 0 and 0 or newMinute > 23 and 23 or newMinute
    SetConvarReplicated('bMenu_current_hour', tostring(newHour))
    SetConvarReplicated('bMenu_current_minute', tostring(newMinute))
    SetConvarReplicated('bMenu_freeze_time', tostring(newFreezeState))
    SetConvarReplicated('bMenu_sync_time_to_machine_time', tostring(newSyncState))
    timeSyncedWithMachine = newSyncState
    timeFrozen = newFreezeState
    currentHour = newHour
    currentMinute = newMinute
end)

--#endregion Events

--#region Threads

CreateThread(function()
    local sleep = tonumber(GetConvar('bMenu_ingame_minute_duration', '2000')) --[[@as number]]
    sleep = sleep < 100 and 100 or sleep
    while true do
        if timeSyncedWithMachine then
            local hour = os.date('%H')
            local minute = os.date('%M')
            currentHour = tonumber(hour) --[[@as number]]
            currentMinute = tonumber(minute) --[[@as number]]
            SetConvarReplicated('bMenu_current_hour', hour --[[@as string]])
            SetConvarReplicated('bMenu_current_minute', minute --[[@as string]])
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
                SetConvarReplicated('bMenu_current_hour', tostring(currentHour))
                SetConvarReplicated('bMenu_current_minute', tostring(currentMinute))
            end
            Wait(sleep)
        end
    end
end)

--#endregion Threads