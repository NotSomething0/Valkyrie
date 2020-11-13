RegisterNetEvent('checkAce')
AddEventHandler('checkAce', function(state)
    isAdmin = state
end)

local spawned = false
AddEventHandler('playerSpawned', function()
    if not spawned then
        spawned = not spawned
    end
end)

CreateThread(function()
    while spawned do
        playerPed = PlayerPedId()
        playerId = PlayerId()
        playerName = GetPlayerName(playerId)
        Wait(15000)
    end
end)

local godModeStrikes = 0
CreateThread(function()
    if Config.GodModeCheck then
        while spawned do
            Wait(1500)
            if GetPlayerInvincible_2(playerId) then
                if not isAdmin then
                    TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(playerId), 'GodMode: SetPlayerInvincible, SetEntityInvincible, or SetPlayerInvincibleKeepRagdollEnabled', 'Invincible', true)
                else
                    print('^5[Valkyrie] Info: ^3Skipped banning of ' ..playerName.. ' this user is an Admin!^7')
                end
            end
            local currentHealth = GetEntityHealth(playerPed)
                    
            SetEntityHealth(playerPed, currentHealth - 2)
            Wait(50)
            if not IsPlayerDead(playerId) then
                if GetEntityHealth(playerPed) == currentHealth and GetEntityHealth(playerPed) ~= 0 then
                    godModeStrikes = godModeStrikes + 1
                end
                if godModeStrikes >= Config.MaxGodModeStrikes then
                    TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(playerId), 'GodMode: SetEntityHealth()', 'Invincible', true)
                elseif GetEntityHealth(playerPed) == currentHealth - 2 then
                    SetEntityHealth(playerPed, GetEntityHealth(playerPed) + 2)
                end
            end
        end
    end
end)

local specStrikes = 0
CreateThread(function()
    if Config.SpectatorCheck then
        while spawned do
            Wait(1500)
            if NetworkIsInSpectatorMode() then
                specStrikes = specStrikes + 1
            end

            local coords = #(GetEntityCoords(playerPed) - GetFinalRenderedCamCoord())

            if coords >= 50 and not IsPedInFlyingVehicle(playerPed) then
                specStrikes = specStrikes + 1
            end
            if specStrikes >= Config.MaxSpectatorStrikes then
                TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(playerId), 'Spectating without permission', 'Spectating', false)
            end
        end
    end
end)