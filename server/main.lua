--#region Startup

-- I don't want you renaming this because this uses kvp and that requires the resource name to be the same across servers to work correctly
if GetCurrentResourceName() ~= 'bMenu' then
    error('Please don\'t rename this resource, change the folder name (back) to \'bMenu\' (case sensitive) to make sure the saved data can be saved and fetched accordingly from the cache.')
    return
end

--#endregion Startup

--#region Callbacks

lib.callback.register('bMenu:server:setConvar', function(_, convar, value, replicated, sendUpdate, menuId, option, optionId)
    if sendUpdate then
        TriggerClientEvent('bMenu:client:updateConvar', -1, convar, value, menuId, option, optionId)
    end
    return replicated and SetConvarReplicated(convar, value) or SetConvar(convar, value)
end)

lib.callback.register('bMenu:server:hasCommandPermission', function(source, command)
    return IsPlayerAceAllowed(source, ('command.%s'):format(command))
end)

lib.callback.register('bMenu:server:hasConvarPermission', function(source, category, convar)
    if not convar then return end

    if type(convar) == 'table' then
        local allowed = {}

        if GetConvar('bMenu.Use_Permissions', 'true') == 'false' then
            for i = 1, #convar do
                allowed[convar[i]] = true
            end

            return allowed
        end

        local categoryType = type(category)
        local categoryText = category
        if categoryType == 'table' then
            categoryText = ''
            for i = 1, #category do
                local text = category[i]
                local length = #text
                local endStr = text:sub(length, length)
                text = endStr == '.' and text or text..'.'
                categoryText = string.format('%s%s', categoryText, text)
            end
        elseif categoryType == 'string' then
            local length = #categoryText
            local endStr = categoryText:sub(length, length)
            categoryText = endStr == '.' and categoryText or categoryText..'.'
        end

        local hasAllPermission = IsPlayerAceAllowed(source, string.format('%sAll', categoryText))
        for i = 1, #convar do
            local c = convar[i]
            allowed[c] = hasAllPermission or IsPlayerAceAllowed(source, string.format('bMenu.%s%s', categoryText or '', c))
        end

        return allowed
    end

    local categoryType = type(category)
    local categoryText = category
    if categoryType == 'table' then
        categoryText = ''
        for i = 1, #category do
            local text = category[i]
            local length = #text
            local endStr = text:sub(length, length)
            text = endStr == '.' and text or text..'.'
            categoryText = string.format('%s%s', categoryText, text)
        end
    elseif categoryType == 'string' then
        local length = #categoryText
        local endStr = categoryText:sub(length, length)
        categoryText = endStr == '.' and categoryText or (categoryText .. '.')
    end

    return GetConvar('bMenu.Use_Permissions', 'false') == 'false' or IsPlayerAceAllowed(source, string.format('%sAll', categoryText)) or IsPlayerAceAllowed(source, string.format('bMenu.%s%s', categoryText or '', convar))
end)

--#endregion Callbacks
