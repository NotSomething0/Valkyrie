--[[
    Valkyrie Anticheat
]]
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60)
        if NetworkIsInSpectatorMode() then
            TriggerServerEvent('Valkyrie: Detection', 'Spectating')
        end
        local invincibility = GetPlayerInvincible(PlayerId())
        Citizen.Wait(30)
        if invincibility == 1 then
            --TriggerServerEvent('Valkyrie: Detection', 'Invincibility')
        end
        if (GetEntityHealth(PlayerPedId()) >= 201) then
            TriggerServerEvent('Valkyrie: Detection', 'Health')
        end
    end
end)

--[[CreateThread(function()
    while true do 
        Wait(0)
        SetAmbientVehicleRangeMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)
        SetRandomVehicleDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetPedDensityMultiplierThisFrame(0.0)
    end
end)]]