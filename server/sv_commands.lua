RegisterCommand('kick', function(source, args, rawCommand)
    
    local playerId = tonumber(args[1])
    if (not playerId or type(playerId) ~= 'number') then
        if (source ~= 0) then
            TriggerClientEvent('notify', source, '~y~Invalid ID')
        else
            print('Kick: Invalid Id')
        end
        return
    end

    local playerLicense = ValkyrieIdentifiers(playerId).license
    if (not playerLicense) then
        if (source ~= 0) then
            TriggerClientEvent('notify', source, '~y~Invalid ID')
        else
            print('Kick: Invalid Id')
        end
        return
    end

    local reason = ''

    table.remove(args, 1)

    if (args[2] ~= nil) then
        reason = table.concat(args, " ")
    else
        reason = 'No reason specified'
    end

    local kickBy = "console"
    if source ~= 0 then
        kickBy = GetPlayerName(source)
    end
    if IsPlayerAceAllowed(playerId, 'command') then
        ValkyrieLog('Player Kicked', '**Player:** ' ..GetPlayerName(playerId).. '\n **Reason:** ' ..reason.. '\n **Player license:** ' ..playerLicense.. '\n **Kicked by:** ' ..kickBy)
        ValkyrieKickPlayer(playerId, reason)
    else
        TriggerClientEvent('notify', source, '~y~You can\'t kick another user with elevated permissions!')
    end
end, true)

frozen = false
RegisterCommand('freeze', function(source, args, rawCommand)

    local playerId = tonumber(args[1])
    if (not playerId or type(playerId) ~= 'number') then
        return TriggerClientEvent('notify', source, '~y~Invalid ID')
    end

    local playerLicense = ValkyrieIdentifiers(playerId).license
    if (not license) then
        return TriggerClientEvent('notify', source, '~y~Invalid ID')
    end

    if IsPlayerAceAllowed(playerId, 'command') then
        local playerPed = GetPlayerPed(playerId)
        FreezeEntityPosition(playerPed, not frozen)
        if frozen then
            FreezeEntityPosition(playerPed, frozen)
        end
        ValkyrieLog('Information', '**Player:** ' ..GetPlayerName(playerId).. '\n**Information:** Was (un)frozen by staff \n**Player license:** ' ..playerLicense.. '\n **Staff Member:** ' ..GetPlayerName(source))
    else
        TriggerClientEvent('notify', source, '~y~You can\'t freeze another user with elevated permissions!')
    end
end, false)

RegisterCommand('spectate', function(source, args, rawCommand)
    local playerId = tonumber(args[1])
    if playerId == nil or type(playerId) ~= 'number' then
        return TriggerClientEvent('notify', source, '~y~Invalid ID')
    end
    local license = ValkyrieIdentifiers(playerId).license
    if not license then
        return TriggerClientEvent('notify', source, '~y~Invalid ID')
    end
    local currentCoords = GetEntityCoords(GetPlayerPed(source))
    local newCoords = GetEntityCoords(GetPlayerPed(args[1]))
    print(currentCoords)
    print(newCoords)
end, false)

RegisterCommand('dv', function(source, args, rawCommand)
    local playerPed = GetPlayerPed(source)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    DeleteEntity(vehicle)
end, false)

RegisterCommand('model', function(source, args, rawCommand)
    SetPlayerModel(source, `a_m_y_skater_01`)
end, false)
