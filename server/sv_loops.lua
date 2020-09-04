CreateThread(function()
    while true do
        ProcessAces()
        Wait(60000) --Check every minute
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        local player = GetPlayerFromIdenx(0)
        local license = ValkyrieIdentifiers(player).license
        local playerPed = GetPlayerPed(player)
        if GetEntityMaxHealth(playerPed) >= 205 then
            ValkyrieLog('Player Kicked', '**Player:** ' ..GetPlayerName(player).. '\n**Reason:** Tried to set their max ped health greater then 205. \n**license:** ' ..license)
            ValkyrieKickPlayer(player, 'Max health: ' ..GetEntityMaxHealth(playerPed))
        end
    end
end)
