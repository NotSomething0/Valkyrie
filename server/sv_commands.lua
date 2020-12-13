RegisterCommand('vkick', function(source, args)
    -- PlayerId of the user being kicked.
    local playerId = tonumber(args[1])
    -- Check to make sure the given argument exists and is a number.
    if playerId == nil or type(playerId) ~= 'number' then
        -- Check to see if the command was executed in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, no playerId was specified.
            TriggerClientEvent('notify', source, '~y~No PlayerId specified please try again.')
        else
            -- Let the staff member (if not in the server) know, no playerId was specified.
            print('^1[WARN] [Valkyrie]^7 No PlayerId specified please try again.')
        end
        -- Exit because no argument was specified.
        return
    end
    -- Name of the player being kicked.
    local playerName = GetPlayerName(playerId)
    -- Check to make sure the username exists.
    if playerName == nil then
        -- Check if the command was executed in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, the playerId was invalid.
            TriggerClientEvent('notify', source, '~y~Invalid PlayerId specified please try again.')
        else
            -- Let the staff member (if not in the server) know, the playerId was invalid.
            print('^1[WARN] [VALKYRIE]^7 Invalid PlayerId specified please try again.')
        end
        -- Exit because the playerId was invalid.
        return
    end
    -- The reason for the users kick.
    local reason = ''
    -- Remove the first argument so when we concat the playerId isn't included.
    table.remove(args, 1)
    -- Check to see if a reason was given.
    if not args[2] then
        -- Concat into a string instead of individual arguments.
        reason = table.concat(args, " ")
    else
        -- If no reason was given set it to unspecified.
        reason = 'No reason specified'
    end
    -- The staff member kicking the player.
    local kickedBy = 'console'
    -- Check if the command was executed in the console or not.
    if source ~= 0 then
        -- If it wasn't then set the kicking staff memeber.
        kickedBy = GetPlayerName(source)
    end
    -- Check to make sure the user being kicked isn't a staff memeber.
    if not IsPlayerAceAllowed(playerId, 'command') then
        ValkyrieKickPlayer(playerId, reason)
        -- Check to see if the command was executed in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know the user was successfully kicked.
            TriggerClientEvent('notify', source, '~g~Kick successful user ' ..playerName.. ' kicked with reason ' ..reason)
        else
            -- Let the staff member (if not in the server) know the user was successfully kicked.
            print('^6[INFO] [VALKYRIE]^7 Kick successful user ' ..playerName.. ' kicked with reason ' ..reason)
        end
        -- Log the information to discord.
        ValkyrieLog('Kicked', '**Player:** ' ..playerName.. '\n**Reason:** ' ..reason.. '\n**Kicked by:** ' ..kickedBy)
    else
        -- Check to see if the command was executed in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, they can't kick another staff member.
            TriggerClientEvent('notify', source, '~y~You can\'t kick another user with elevated permissions!')
        else
            -- Let the staff member (if not in the server) know, they can't kick another staff member.
            print('^6[INFO] [VALKYRIE]^7 You can\'t kick another user with elevated permissions!')
        end
    end
end, true)

RegisterCommand('vban', function(source, args)
    -- playerId of the user being banned.
    local playerId = tonumber(args[1])
    -- Check to make sure the given argument exists and is a number
    if playerId == nil or type(playerId) ~= 'number' then
        -- Check to see if the command was entered in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, no playerId was specified.
            TriggerClientEvent('notify', source, '~y~No PlayerId specified please try again.')
        else
            -- Let the staff member (if not in the server) know, no playerId was specified.
            print('^1[WARN] [VALKYRIE]^7 No PlayerId was specified please try again.')
        end
        -- Exit because no argument was specified
        return
    end
    -- Username of the user being banned.
    local playerName = GetPlayerName(playerId)
    -- Check to make sure the username exists.
    if playerName == nil then
        -- Check to see if the command was executed in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, the playerId is invalid.
            TriggerClientEvent('notify', source, '~y~Invalid PlayerId specified please try again.')
        else
            -- Let the staff member (if not in the server) know, the playerId is invalid.
            print('^1[WARN] [VALKYRIE]^7 Invalid PlayerId specified please try again')
        end
        -- Exit because the playerId was invalid.
        return
    end
    -- The reason for the users ban
    local reason = ''
    -- Remove the first argument so when we concat the playerId isn't included.
    table.remove(args, 1)
    -- Check to see if a reason was given.
    if args[2] ~= nil then
        -- Concat into string instead of individual arguments.
        reason = table.concat(args, " ")
    else
        -- If no reason was given set it to unspecified.
        reason = 'No reason specified'
    end
    -- The staff member banning the user.
    local bannedBy = 'console'
    -- Check to see if the command was entered in the console or not.
    if source ~= 0 then
        -- If it wasn't then set the banning staff memeber.
        bannedBy = GetPlayerName(source)
    end
    -- Check to make sure the user being banned isn't a staff memeber.
    if not IsPlayerAceAllowed(playerId, 'command') then
        ValkyrieBanPlayer(playerId, reason)
        if source ~= 0 then
            -- Let the staff member (if in the server) know the user was successfully kicked.
            TriggerClientEvent('notify', source, '~g~Ban successful user ' ..playerName.. ' banned for reason ' ..reason)
        else
            -- Let the staff member (if not in the server) know the user was successfully kicked.
            print('^6[INFO] [VALKYRIE]^7 Ban successful user ' ..playerName.. ' banned for reason ' ..reason)
        end
    else
        -- Check to see if the command was executed in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, the playerId is invalid.
            TriggerClientEvent('notify', source, '~y~You can\'t ban another user with elevated permissions!')
        else
            -- Let the staff member (if not in the server) know, the playerId is invalid.
            print('^6[INFO] [VALKYRIE]^7 You can\'t ban another user with elevated permissions!')
        end
    end
end, true)

RegisterCommand('vunban', function(source, args)
    -- Prefix of every ban placed by Valkyrie.
    local banPrefix = 'valkyrie_ban_'
    -- Prefix of every ban reason placed by Valkyrie.
    local banReasonPrefix = 'valkyrie_reason_'
    -- The ban uuid of the banned user.
    local banId = args[1]
    -- Check to make sure the given argument exists.
    if banId == nil then
        --Check to see if the command was entered in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, no banId was specified.
            TriggerClientEvent('notify', source, '~y~No BanId specified please try again.')
        else
            -- Let the staff member (if not in the server) know, no banId was specified.
            print('^1[WARN] [VALKYRIE]^7 No BanId specified please try again.')
        end
        -- Exit because no argument was provided.
        return 
    end
    -- The reason for unbanning this user.
    local reason = ''
    -- Remove the first argument so when we concat the given arguments the banId isn't included.
    table.remove(args, 1)
    -- Check to see if a reason was given.
    if args[2] ~= nil then
        -- Concat into a string instead of individual arguments.
        reason = table.concat(args, " ")
    else
        -- If no reason was given set it to unspecified.
        reason = 'No reason specified'
    end
    -- The staff member unbanning the user.
    local unbannedBy = 'console'
    -- Check to see if the command was entered in the console or not.
    if source ~= 0 then
        -- If it wasn't then set the unbanning staff memeber.
        unbannedBy = GetPlayerName(source)
    end
    -- Check to see if the ban uuid is in the database or not.
    if GetResourceKvpString(banPrefix..banId) == nil or GetResourceKvpString(banReasonPrefix..banId) == nil then
        -- Check to see if the command was entered in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, no ban was associated with that Id.
            TriggerClientEvent('notify', source, '~y~No ban associated with this Id, did you type it correctly?')
        else
            -- Let the staff member (if not in the server) know, no ban was associated with that Id.
            print('^1[WARN] [VALKYRIE]^7 No ban associated with this Id, did you type it correctly?')
        end
        -- Exit because there is no ban associated with that Id.
        return
    else
        -- If it is in the database then delete the orignial ban and ban reason.
        DeleteResourceKvp(banPrefix..banId)
        DeleteResourceKvp(banReasonPrefix..banId)
        -- Check to see if the command was entered in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, the ban was removed successfully.
            TriggerClientEvent('notify', source, '~g~BanId ' ..banId.. ' successfully unbanned with reason ' ..reason)
        else
            -- Let the staff member (if not in the server) know, the ban was removed successfully.
            print('^6[INFO] [VALKYRIE]^7 BanId ' ..banId.. ' successfully unbanned with reason ' ..reason)
        end
    end
    -- Log the action to discord.
    ValkyrieLog('Unbanned', '**BanId:** ' ..banId.. '\n **Unbanned by:** ' ..unbannedBy.. '\n**Reason:** ' ..reason)
end, true)

local frozen = false
RegisterCommand('vfreeze', function(source, args)
    -- PlayerId of the user being frozen.
    local playerId = tonumber(args[1])
    -- Check to make sure the given argument exists and is a number.
    if playerId == nil or type(playerId) ~= 'number' then
        -- Check to if the command was entered in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, no playerId was specified.
            TriggerClientEvent('notify', source, '~y~No PlayerId specified please try again.')
        else
            -- Let the staff member (if not in the server) know, no playerId was specified.
            print('^1[WARN] [VALKYRIE]^7 No PlayerId specified please try again.')
        end
        -- Exit because no playerId was specified
        return
    end
    -- Username of the staff member.
    local staffName = 'console'
    -- Check if the command was executed in the console or not.
    if source ~= 0 then
        -- If it wasn't then set the staff name.
        staffName = GetPlayerName(source)
    end
    -- Username of the user getting frozen.
    local userName = GetPlayerName(playerId)
    -- Check if the user exists
    if userName == nil then
        -- Check if the command was executed in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, the playerId specified was invalid.
            TriggerClientEvent('notify', source, '~y~Invalid PlayerId specified please try again.')
        else
            -- Let the staff member (if not in the server) know, the playerId specified was invalid.
            print('^1[WARN] [VALKYRIE]^7 Invalid PlayerId specified please try again.')
        end
        -- Exit because the user doesn't exist.
        return
    end
    -- Check to make sure the user being frozen isn't a staff member
    if not IsPlayerAceAllowed(playerId, 'command') then
        -- Get the ped of the user being frozen.
        local playerPed = GetPlayerPed(playerId)
        -- Set the frozen variable to the opposite of its current state.
        frozen = not frozen
        -- Freeze the user.
        FreezeEntityPosition(playerPed, frozen)
        -- Log the action to discord.
        ValkyrieLog('Info', '**Player:** ' ..userName.. '\n**Information:** Was (un)frozen by staff \n **Staff Member:** ' ..staffName)
    else
        -- Check to see if the command was executed in the console or not.
        if source ~= 0 then
            -- Let the staff member (if in the server) know, the playerId is invalid.
            TriggerClientEvent('notify', source, '~y~You can\'t freeze another user with elevated permissions!')
        else
            -- Let the staff member (if not in the server) know, the playerId is invalid.
            print('^6[INFO] [VALKYRIE]^7 You can\'t freeze another user with elevated permissions!')
        end
    end
end, true)

RegisterCommand('vclearobjects', function()
    -- Loop through all players on the server
    for _, players in pairs(GetPlayers()) do
        -- Trigger client event to wipe all entitys
        TriggerClientEvent('Valkyrie:ClearObjects', players)
    end
end, true)

RegisterCommand('vclearvehicles', function()
    -- Loop through all vehicles on the server
    for _, vehicles in pairs(GetAllVehicles()) do
        -- Delete all vehicles
        DeleteEntity(vehicles)
    end
end, true)

RegisterCommand('vclearpeds', function()
    -- Loop through all peds on the server
    for _, peds in pairs(GetAllPeds()) do
        -- Delete all peds.
        DeleteEntity(peds)
    end
end, true)