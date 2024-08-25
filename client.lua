local hersePositions = {}

function GetHersePositions()
    local objects = GetGamePool("CObject") 
    for _, object in ipairs(objects) do
        local modelHash = GetEntityModel(object)
        if modelHash == GetHashKey("p_ld_stinger_s") then
            local objectCoords = GetEntityCoords(object)
            table.insert(hersePositions, objectCoords)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        hersePositions = {}  
        GetHersePositions()   
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            for _, herseCoords in ipairs(hersePositions) do
                local distance = GetDistanceBetweenCoords(vehicleCoords, herseCoords, true)
                if distance < 5.0 then 
                    local allTiresIntact = true
                    for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
                        if IsVehicleTyreBurst(vehicle, i, false) then
                            allTiresIntact = false
                            break
                        end
                    end
                    if allTiresIntact then
                        for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
                            SetVehicleTyreBurst(vehicle, i, true, 1000.0)
                        end
                        print("Pneus du véhicule crevés par la herse.")
                    end
                end
            end
        end
    end
end)
