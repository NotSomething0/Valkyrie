RegisterNetEvent('checkAce')
AddEventHandler('checkAce', function(state)
    isAdmin = state
end)
gmStrikes = 0
AddEventHandler('playerSpawned', function()
    CreateThread(function()
        while true do
            Wait(0)
            if Config.GodModeCheck then
                Wait(1000)
                if GetPlayerInvincible(PlayerId()) then
                    TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'GodMode: SetPlayerInvincible()', gmStrikes, 'Invincible')
                end
                local playerPed = PlayerPedId()
                local currentHealth = GetEntityHealth(playerPed)
                SetEntityHealth(playerPed, currentHealth - 2)
                Wait(50)
                if not IsPlayerDead(PlayerId()) then
                    if GetEntityHealth(playerPed) == currentHealth and GetEntityHealth(playerPed) ~= 0 then
                        TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'GodMode: SetEntityHealth()', gmStrikes, 'Invincible')
                    elseif GetEntityHealth(playerPed) == currentHealth - 2 then
                        SetEntityHealth(playerPed, GetEntityHealth(playerPed) + 2)
                    end
                end
            end
        end
    end)
end)

spawned = false
strikes = 0
AddEventHandler('playerSpawned', function()
    if spawned == false then
        spawned = true
        CreateThread(function()
            while true do
                Wait(1000)
                if Config.SpectatorCheck then
                    Wait(500)
                    if isAdmin then
                        if NetworkIsInSpectatorMode() then
                            TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Spectating: NetworkSetInSpectatorMode()', 'Spectating')
                        end
                        local coords = #(GetEntityCoords(PlayerPedId()) - GetFinalRenderedCamCoord())
                        if coords >= 30 and not IsPedInFlyingVehicle(PlayerPedId()) then
                            TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Spectating: GetFinalRenderedCamCoord(): `' ..coords.. '` units.', specStrikes, 'Spectating')
                        end
                    end
                end
            end
        end)

        CreateThread(function()
            while true do
                Wait(0)
                if Config.SpeedDetection then
                    Wait(1000)
                    if GetEntitySpeed(PlayerPedId()) >= Config.MaxSpeed then
                        strikes = strikes + 1
                    end
                    if strikes >= 3 then 
                        TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Speed: SetEntityMaxSpeed(): `' ..GetEntitySpeed(PlayerPedId()), 'Speed')
                    end
                end
            end
        end)
    end
end)
