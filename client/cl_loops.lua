--[[
    Valkyrie Anticheat
]]
Config = {}
Config.InvisibleCheck = true
Config.SpectatorCheck = true
Config.InvincibilityCheck = true
Config.DemiGodModeCheck = true
--Handler for kicking players
AddEventHandler('Valkyrie:ClientDetection', function(user, log, reason)
    TriggerServerEvent('Valkyrie:ClientDetection', user, log, reason)
end)
--Main thread
CreateThread(function()
    while true do
        Wait(1000)
        if Config.InvisibleCheck then
            Wait(10000)
            if IsEntityVisible(PlayerPedId()) == false then
                TriggerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Was kicked for being invisible.', 'Invisible')
            end
        end
        if Config.SpectatorCheck then
            Wait(60)
            if NetworkIsInSpectatorMode() then
                TriggerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Was kicked for spectating a player without permission.', 'Spectating')
            end
        end
        if Config.InvincibilityCheck then
            Wait(5000)
            if GetPlayerInvincible(PlayerId()) then
                TriggerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Was kicked for being invincible(Gode Mode).', 'God Mode')
            end
        end
        if Config.DemiGodModeCheck then
            Wait(15000)
            local playerPed = PlayerPedId()
            local currentHealth = GetEntityHealth(playerPed)
            SetEntityHealth(playerPed, currentHealth - 2)
            local something = math.random(10, 150)
            Wait(something)
            if not IsPlayerDead(PlayerId()) then
                if GetEntityHealth(playerPed) == currentHealth and GetEntityHealth(playerPed) ~= 0 then
                    TriggerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Was kicked for being invincible(Demi God Mode).', 'Demi God Mode')
                elseif GetEntityHealth(playerPed) == currentHealth - 2 then
                    SetEntityHealth(playerPed, GetEntityHealth(playerPed) + 2)
                end
            end
        end
    end
end)