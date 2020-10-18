RegisterCommand('vkick', function(source, args, rawCommand)
    -- Server id of the player being kicked.
    local playerId = tonumber(args[1])
    -- Check to make sure the given argument exists and is a number.
    if not playerId or type(playerId) ~= 'number' then
        if source ~= 0 then
            TriggerClientEvent('notify', source, '~y~No player ID specified please try again.') -- Let the staff member know no id was specified.
        else
            print('[Valkyrie] ^1No player ID specified please try again.^7') -- Let the staff member know no id was specified.
        end
        return -- Don't continue because no argument was given.
    end
    -- :icense of the player being kicked.
    local playerLicense = ValkyrieIdentifiers(playerId).license
    -- Check to make sure the license exists.
    if not playerLicense then
        if source ~= 0 then
            TriggerClientEvent('notify', source, '~y~Invalid ID') -- Let the staff member know the id is invalid.
        else
            print('[Valkyrie] ^1Invalid Id^7') -- Let the staff member know the id is invalid, if we somehow get here.
        end
        return -- Don't continue because the license doesn't exist.
    end
    -- The reason for the players kick.
    local reason = ''
    -- Remove the first argument so when we concat the id isn't included.
    table.remove(args, 1)
    -- Check to see if a reason was given.
    if not args[2] then
        reason = table.concat(args, " ") -- Concat into a string instead of individual arguments.
    else
        reason = 'No reason specified' -- If no reason was given set it to unspecified.
    end
    -- The staff member kicking the player.
    local kickedBy = 'console'
    -- Check to see if the one executing the command is the console or not.
    if source ~= 0 then
        kickedBy = GetPlayerName(source) -- If they aren't then set the kicking staff member to the one executing the command.
    end
    -- Check to make sure the player being kicked isn't a staff memeber.
    if not IsPlayerAceAllowed(playerId, 'command') then
        ValkyrieLog('Player Kicked', '**Player:** ' ..GetPlayerName(playerId).. '\n **Reason:** ' ..reason.. '\n **Player license:** ' ..playerLicense.. '\n **Kicked by:** ' ..kickedBy)
        ValkyrieKickPlayer(playerId, reason)
    else
        TriggerClientEvent('notify', source, '~y~You can\'t kick another user with elevated permissions!') -- Let the staff member know they can't kick this player.
    end
end, true)

RegisterCommand('vban', function(source, args, rawCommand)
   -- Server id of the player being banned.
   local playerId = tonumber(args[1])
   -- Check to make sure the given argument exists and is a number.
   if not playerId or type(playerId) ~= 'number' then
       if source ~= 0 then
           TriggerClientEvent('notify', source, '~y~No player ID specified please try again.') -- Let the staff member know no id was specified.
       else
           print('[Valkyrie] ^1No player ID specified please try again.^7') -- Let the staff member know no id was specified.
       end
       return -- Don't continue because no argument was given.
   end
   -- License of the player being banned.
   local playerLicense = ValkyrieIdentifiers(playerId).license
   -- Check to make sure the license exists.
   if not playerLicense then
       if source ~= 0 then
           TriggerClientEvent('notify', source, '~y~Invalid ID') -- Let the staff member know the id is invalid.
       else
           print('[Valkyrie] ^1Invalid Id^7') -- Let the staff member know the id is invalid.
       end
       return -- Don't continue because the license doesn't exist.
   end
   -- The reason for the players ban.
   local reason = ''
   -- Remove the first argument so when we concat the id isn't included.
   table.remove(args, 1)
   -- Check to see if a reason was given.
   if not args[2] then
       reason = table.concat(args, " ") -- Concat into a string instead of individual arguments.
   else
       reason = 'No reason specified' -- If no reason was given set it to unspecified.
   end
   -- The staff member banning the player.
   local bannedBy = 'console'
   -- Check to see if the one executing the command is the console or not.
   if source ~= 0 then
    bannedBy = GetPlayerName(source) -- If they aren't then set the banning staff member to the one executing the command.
   end
   -- Check to make sure the player being banned isn't a staff memeber.
   if not IsPlayerAceAllowed(playerId, 'command') then
       ValkyrieLog('Player Banned', '**Player:** ' ..GetPlayerName(playerId).. '\n **Reason:** ' ..reason.. '\n **Player license:** ' ..playerLicense.. '\n **Banned by:** ' ..bannedBy)
       ValkyrieBanPlayer(playerId, reason)
   else
       TriggerClientEvent('notify', source, '~y~You can\'t ban another user with elevated permissions!') -- Let the staff member know they can't ban this player.
   end
end, true)

RegisterCommand('vunban', function(source, args, rawCommand)
    -- The license of the banned player.
    local banId = args[1]
    -- Check to make sure the given argument exists.
    if not banId then
        if source ~= 0 then
            TriggerClientEvent('notify', source, '~y~No license specified please try again.') -- Let the staff member know no license was specified.
        else
            print('[Valkyrie] ^1No license specified please try again.^7') -- Let the staff member know no license was specified.
        end
        return  -- Don't continue because no argument was given.
    end
    -- Check to make sure the banned license is in the data base.
    if not GetResourceKvpString(banId) then
        return print('This license does not have a ban associated with it, are you sure you typed it correctly?') -- Don't continue because it is not in the data base.
    end
    -- Delete the license from the data base.
    DeleteResourceKvp(banId)
    -- Let the staff member know the player was unbanned.
    print('license: ' ..banId.. ' successfully unbanned')
    -- The reason for unbanning the license
    local reason = ''
    -- Remove the first argument so when we concat the license isn't included.
    table.remove(args, 1)
    -- Check to see if a reason was given.
    if args[2] ~= nil then
        reason = table.concat(args, " ") -- Concat into a string instead of individual arguments.
    else
        reason = 'No reason specified' -- If no reason was given set it to unspecified.
    end
    -- The staff member unbanning the player.
    local unbannedBy = 'console'
    -- Check to see if the one executing is the console or not.
    if source ~= 0 then
        unbannedBy = GetPlayerName(source) -- If they aren't then set the unbanning staff member to the one executing the command.
    end
    -- Log the action to discord.
    ValkyrieLog('Server Info', '**license:** ' ..banId.. '\n **Unbanned by:** ' ..unbannedBy.. '\n**Reason:** ' ..reason)
end, true)

local frozen = false
RegisterCommand('vfreeze', function(source, args, rawCommand)
    -- Server id of the player being forzen.
    local playerId = tonumber(args[1])
    -- Check to make sure the given argument exists and is a number.
    if not playerId or type(playerId) ~= 'number' then
        if source ~= 0 then
            TriggerClientEvent('notify', source, '~y~No player ID specified please try again.') -- Let the staff member know no id was specified.
        else
            print('[Valkyrie] ^1No player ID specified please try again.^7') -- Let the staff member know no id was specified.
        end
        return -- Don't continue because no argument was given.
    end
    -- License of the player being frozen
    local playerLicense = ValkyrieIdentifiers(playerId).license
    -- Check to make sure the license exists
    if not playerLicense then
        if source ~= 0 then
            TriggerClientEvent('notify', source, '~y~Invalid ID') -- Let the staff member know the id is invalid.
        else
            print('[Valkyrie] ^1Invalid Id^7') -- Let the staff member know the id is invalid.
        end
        return -- Don't continue because the license doesn't exist
    end
    -- Check to make sure the player being forzen isn't a staff member
    if IsPlayerAceAllowed(playerId, 'command') then
        -- Get the ped of the player being frozen
        local playerPed = GetPlayerPed(playerId)
        -- Freeze the player
        FreezeEntityPosition(playerPed, not frozen)
        -- Set the frozen variable to false (not frozen)
        frozen = not frozen
        -- If they are already frozen then unfreeze them
        if frozen then
            FreezeEntityPosition(playerPed, frozen)
        end
        -- Log the action to discord.
        ValkyrieLog('Server Info', '**Player:** ' ..GetPlayerName(playerId).. '\n**Information:** Was (un)frozen by staff \n**Player license:** ' ..playerLicense.. '\n **Staff Member:** ' ..GetPlayerName(source))
    else
        TriggerClientEvent('notify', source, '~y~You can\'t freeze another user with elevated permissions!') -- Let the staff member know they can't freeze this player.
    end
end, true)