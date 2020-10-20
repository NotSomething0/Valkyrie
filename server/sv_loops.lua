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
                ValkyrieLog('Player Banned', '**Player:** ' ..name.. '\n**Reason:** Set maximum health to `' ..entityHealth.. '`\n**license:** ' ..license)
                ValkyrieBanPlayer(player, 'Max health: ' ..entityHealth)
            end
            if IsPlayerUsingSuperJump(player) then
                ValkyrieBanPlayer(player, 'Super Jump')
                ValkyrieLog('Player Banned', '**Player:** ' ..name.. '\n**Reason:** Super Jump \n**license:** ' ..license)
            end
        end
    end
end)

--[[
    The code below except for a few bits and bops isn't mine. The code was taken from https://github.com/JaredScar/Badger-Anticheat/blob/master/server.lua
    Thanks JamesUK-Developer/JaredScar(Badger) <3
]]

CreateThread(function()
    Wait(1000)
    local added = false
    local numResourceModified = 0
    for i = 1, GetNumResources() do
        local resource_id = i - 1
        local resource_name = GetResourceByFindIndex(resource_id)
        if resource_name ~= GetCurrentResourceName() then
            for k, v in pairs({'fxmanifest.lua', '__resource.lua'}) do
                local data = LoadResourceFile(resource_name, v)
                if data and type(data) == 'string' and string.find(data, 'client/cl_hook.lua') == nil then
                    numResourceModified = numResourceModified + 1
                    data = data .. '\n\nclient_script "@' .. GetCurrentResourceName() .. '/client/cl_hook.lua"'
                    SaveResourceFile(resource_name, v, data, -1)
                    print('Added to resource: ' .. resource_name)
                    added = true
                end
            end
        end
    end
    if added then
        print('Modified ' ..numResourceModified.. ' resource(s) a server restart is required for these changes to take affect.')
    end
end)