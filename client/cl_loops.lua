RegisterNetEvent('checkAce')
AddEventHandler('checkAce', function(state)
    isAdmin = state
end)

local spawned = false
AddEventHandler('playerSpawned', function()
    if not spawned then
        spawned = true

        local playerPed = PlayerPedId()
        local specStrikes = 0
        local godModeStrikes = 0

        CreateThread(function()
            while spawned do
                Wait(1000)
                if Config.SpectatorCheck then
                    if not isAdmin then
                        if NetworkIsInSpectatorMode() then
                            specStrikes = specStrikes + 1
                            print('[Valkyrie] ' ..specStrikes.. ' NetworkIsInSpectatorMode()')
                        end

                        local coords = #(GetEntityCoords(PlayerPedId()) - GetFinalRenderedCamCoord())

                        if coords >= 30 and not IsPedInFlyingVehicle(PlayerPedId()) then
                            specStrikes = specStrikes + 1
                            print('[Valkyrie] ' ..specStrikes.. ' vector math GetEntityCoords() - GetFinalRenderedCamCoord()')
                        end
                        if specStrikes >= Config.MaxSpectatorStrikes then
                            TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Spectating without permission', 'Spectating')
                        end
                    end
                end
            end
        end)

        CreateThread(function()
            while true do
                Wait(1000)
                if Config.GodModeCheck then
                    if GetPlayerInvincible(PlayerId()) then
                        TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'GodMode: SetPlayerInvincible()', 'Invincible')
                    end

                    local currentHealth = GetEntityHealth(playerPed)
                    
                    SetEntityHealth(playerPed, currentHealth - 2)
                    Wait(50)
                    if not IsPlayerDead(PlayerId()) then
                        if GetEntityHealth(playerPed) == currentHealth and GetEntityHealth(playerPed) ~= 0 then
                            godModeStrikes = godModeStrikes + 1
                        end
                        if godModeStrikes >= Config.MaxGodModeStrikes then
                            TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'GodMode: SetEntityHealth()', 'Invincible')
                        elseif GetEntityHealth(playerPed) == currentHealth - 2 then
                            SetEntityHealth(playerPed, GetEntityHealth(playerPed) + 2)
                        end
                    end
                end
            end
        end)

        CreateThread(function()
            while spawned do
                Wait(1000)
                local wep = GetSelectedPedWeapon(playerPed)
                for _, dmgType in pairs(Config.BlockedDamageType) do
                    if GetWeaponDamageType(wep) == dmgType then
                        RemoveWeaponFromPed(playerPed, wep)
                        print('[Valkyrie] Weapon removed from player ' ..GetEntityModel(wep).. ' blocked damage type.')
                    end
                end
                if GetWeaponDamageModifier(wep) >= 10 then
                    RemoveWeaponFromPed(playerPed, wep)
                    print('[Valkyrie] Weapon removed from player ' ..GetEntityModel(wep).. ' exceeded maximum damage modifier.')
                end
            end
        end)
    end
end)
