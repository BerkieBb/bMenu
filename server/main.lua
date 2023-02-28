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
                categoryText = string.format('%s%s', categoryText, category[i]..'.')
            end
        end

        for i = 1, #convar do
            local c = convar[i]
            allowed[c] = IsPlayerAceAllowed(source, string.format('%s.%s%s', 'bMenu', categoryText or '', c))
        end
        return allowed
    end

    local categoryType = type(category)
    local categoryText = category
    if categoryType == 'table' then
        categoryText = ''
        for i = 1, #category do
            categoryText = string.format('%s%s', categoryText, category[i]..'.')
        end
    end
    return GetConvar('bMenu.Use_Permissions', 'false') == 'false' or IsPlayerAceAllowed(source, string.format('%s.%s%s', 'bMenu', categoryText or '', convar))
end)

--#endregion Callbacks
