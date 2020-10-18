CreateThread(function()
    while true do
        ProcessAces()
        Wait(60000) --Check every minute
    end
end)

CreateThread(function()
    while true do
        Wait(1500)
        if GetNumPlayerIndices() > 0 then
            local player = GetPlayerFromIndex(0)
            local license = ValkyrieIdentifiers(player).license
            local playerPed = GetPlayerPed(player)
            local name = GetPlayerName(player)
            if not license then return end
            if not IsPlayerAceAllowed(player, 'command') then
                local pedHash = GetEntityModel(playerPed)
                if Config._blacklistedPeds[pedHash] then
                    TriggerClientEvent('setPed', player)
                    ValkyrieLog('Player Info', '**Player:** `' ..name..'`\n**Reason:** Tried to set themselves as a blacklisted ped `' ..Config._blacklistedPeds[pedHash].. '`\n**license:** ' ..license)
                end
                local wepHash = GetSelectedPedWeapon(playerPed) 
                if Config._blacklistedWeapons[wepHash] then
                    Wait(500)
                    RemoveWeaponFromPed(playerPed, wepHash)
                    ValkyrieLog('Player Info', '**Player:** `' ..name..'`\n **Reason:** Tried to use a blacklisted weapon `' ..Config._blacklistedWeapons[wepHash]..'`\n**license:** ' ..license)
                    TriggerClientEvent('notify', player, 'Blacklisted Weapon')
                end
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if Config._blacklistedVehicles[GetEntityModel(vehicle)] then
                    DeleteEntity(vehicle)
                    ValkyrieLog('Player Info', '**Player:** `' ..name..'`\n **Reason:** Tried to use a blacklisted vehicle `' ..Config._blacklistedVehicles[GetEntityModel(vehicle)].. '`\n**license:** ' ..license)
                    TriggerClientEvent('notify', player, 'Blacklisted Vehicle')    
                end
            end
            local entityHealth = GetEntityMaxHealth(playerPed) 
            if entityHealth > 201 then
                ValkyrieLog('Player Kicked', '**Player:** ' ..name.. '\n**Reason:** Set maximum health to `' ..entityHealth.. '`\n**license:** ' ..license)
                ValkyrieBanPlayer(player, 'Max health: ' ..entityHealth)
            end
            if IsPlayerUsingSuperJump(player) then
                ValkyrieBanPlayer(player, 'Super Jump')
                ValkyrieLog('Player Kicked', '**Player:** ' ..name.. '\n**Reason:** Super Jump \n**license:** ' ..license)
            end
        end
    end
end)