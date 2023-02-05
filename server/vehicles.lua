--#region Callbacks

lib.callback.register('bMenu:server:spawnVehicle', function(_, model, coords)
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