function GetConvarBoolean(convar)
    return GetConvar(convar, 'false') == 'true'
end

function GetConvarNumber(convar)
    local int = GetConvarInt(convar, -1)
    if int == -1 then
        local stringCheck = tonumber(GetConvar(convar, '-1'))
        if stringCheck then
            return stringCheck
        end
    end

    return int
end

function GetConvarString(convar)
    return GetConvar(convar, '')
end