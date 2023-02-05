--#region Callbacks

lib.callback.register('bMenu:server:saveTeleportLocation', function(source, teleportName)
    local file = {string.strtrim(LoadResourceFile('bMenu', 'config/locations.lua'))}

    if file then
        file[1] = file[1]:gsub('}$', '')

        local playerPed = GetPlayerPed(source)

        file[2] = [[

    {
        name = '%s',
        coords = %s,
        heading = %s
    },
]]

        file[2] = file[2]:format(teleportName, GetEntityCoords(playerPed), GetEntityHeading(playerPed))

        file[3] = '}'

        SaveResourceFile('bMenu', 'config/locations.lua', table.concat(file), -1)

        return true, ('Successfully added location %s'):format(teleportName)
    end

    return false, 'Something went wrong with loading the locations file'
end)

lib.callback.register('bMenu:server:getConfig', function(_, fileName)
    local file = LoadResourceFile('bMenu', ('config/%s.lua'):format(fileName))
    if not file then return end

    local returnVal = load(file, ('@@bMenu/config/%s.lua'):format(fileName))
    if not returnVal then return end

    return returnVal()
end)

--#endregion Callbacks
