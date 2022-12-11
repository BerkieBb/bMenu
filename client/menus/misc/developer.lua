--#region Variables

local showCoords = false

--#endregion Variables

--#region Functions

local function drawTextOnScreen(text, x, y, size, position --[[ 0: center | 1: left | 2: right ]], font, disableTextOutline)
    if
    not IsHudPreferenceSwitchedOn()
    or IsHudHidden()
    or IsPlayerSwitchInProgress()
    or IsScreenFadedOut()
    or IsPauseMenuActive()
    or IsFrontendFading()
    or IsPauseMenuRestarting()
    then
        return
    end

    size = size or 0.48
    position = position or 1
    font = font or 6

    SetTextFont(font)
    SetTextScale(1.0, size)
    if position == 2 then
        SetTextWrap(0, x)
    end
    SetTextJustification(position)
    if not disableTextOutline then
        SetTextOutline()
    end
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

--#endregion Functions

--#region Events

RegisterNetEvent('berkie_menu:client:clearArea', function(pos)
    -- Make sure this is only triggered from the server
    if GetInvokingResource() then return end
    ClearAreaLeaveVehicleHealth(pos.x, pos.y, pos.z, 100, false, false, false, false)
end)

--#endregion Events

--#region Menu Registration

lib.registerMenu({
    id = 'berkie_menu_misc_options_developer_options',
    title = 'Development Tools',
    position = 'top-right',
    onSelected = function(selected)
        MenuIndexes['berkie_menu_misc_options_developer_options'] = selected
    end,
    onCheck = function(_, checked, args)
        if args[1] == 'show_coords' then
            showCoords = checked
        end
    end,
    options = {
        {label = 'Clear Area', description = 'Clears the area around your player (100 meters). Damage, dirt, peds, props, vehicles, etc. Everything gets cleaned up, fixed and reset to the default world state', args = {'clear_area'}},
        {label = 'Show Coordinates', description = 'Show your current coordinates at the top of your screen', checked = showCoords, args = {'show_coords'}}
    }
}, function(_, _, args)
    if args[1] == 'clear_area' then
        TriggerServerEvent('berkie_menu:server:clearArea', GetEntityCoords(cache.ped))
    end
end)

--#endregion Menu Registration

--#region Threads

CreateThread(function()
    while true do
        Wait(0)
        if showCoords then
            local coords = GetEntityCoords(cache.ped)
            SetScriptGfxAlign(0, 84)
            SetScriptGfxAlignParams(0, 0, 0, 0)
            local screenWidth = GetActiveScreenResolution()
            drawTextOnScreen(("~r~X~s~ \t\t%s\n~r~Y~s~ \t\t%s\n~r~Z~s~ \t\t%s\n~r~Heading~s~ \t%s"):format(coords.x, coords.y, coords.z, GetEntityHeading(cache.ped)), 0.5 - (30 / screenWidth), 0, 0.5, 1, 6, false)
            ResetScriptGfxAlign()
        end
    end
end)

--#endregion Threads