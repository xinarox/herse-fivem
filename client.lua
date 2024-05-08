-- Tableau pour stocker les coordonnées des herse
local hersePositions = {}

-- Cette fonction récupère les positions des herse à partir des entités du monde
function GetHersePositions()
    local objects = GetGamePool("CObject")  -- Récupère toutes les entités objets du jeu
    for _, object in ipairs(objects) do
        local modelHash = GetEntityModel(object)
        if modelHash == GetHashKey("p_ld_stinger_s") then
            local objectCoords = GetEntityCoords(object)
            table.insert(hersePositions, objectCoords)
        end
    end
end

-- Fonction pour détecter les collisions avec les herse
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Mettre à jour les positions des herse à chaque boucle
        hersePositions = {}  -- Réinitialiser la liste des positions des herse
        GetHersePositions()   -- Mettre à jour les positions des herse

        -- Vérifie si un véhicule entre en collision avec une des herse
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            for _, herseCoords in ipairs(hersePositions) do
                local distance = GetDistanceBetweenCoords(vehicleCoords, herseCoords, true)
                if distance < 5.0 then  -- Ajustez la distance de détection si nécessaire
                    -- Vérifie si au moins un pneu du véhicule n'est pas déjà crevé
                    local allTiresIntact = true
                    for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
                        if IsVehicleTyreBurst(vehicle, i, false) then
                            allTiresIntact = false
                            break
                        end
                    end

                    -- Si tous les pneus sont intacts, crever tous les pneus du véhicule
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
