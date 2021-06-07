local format = string.format
local remove = table.remove
local gsub = string.gsub
local webhook = GetConvar("valkyrie_discord_webhook", "")
local modules = {
  ['entities'] = true,
  ['explosion'] = true,
  ['filter'] = true
}

RegisterCommand('kick', function(source, args)
  local netId = tonumber(args[1])
  local reason = 'No reason specified'

  if not netId or netId == 0 or not GetPlayerName(netId) then
    if source > 0 then
      TriggerClientEvent('vac_notify_client', source, '~y~Invalid netId, please try again.')
    else
      print('^1[WARN] [Valkyrie]^7 Invalid netId, please try again.')
    end
    return
  end

  if args[2] then
    remove(args, 1)
    reason = table.concat(args, " ")
  end

  if IsPlayerAceAllowed(netId, 'vac.kick') then
    if source > 0 then
      return TriggerClientEvent('vac_notify_client', source, '~y~You can\'t kick another user with elevated permissions!')
    else
      return print('^6[INFO] [VALKYRIE]^7 You can\'t kick another user with elevated permissions!')
    end
  end

  if source > 0 then
    TriggerClientEvent('vac_notify_client', source, format('~g~Kicked user %s with reason %s.', GetPlayerName(netId), reason))
  else
    print(format('^6[INFO] [VALKYRIE]^7 Kicked user %s with reason %s.', GetPlayerName(netId), reason))
  end

  exports.Valkyrie:kickPlayer(netId, reason)
end, true)

RegisterCommand('ban', function(source, args)
  local netId = tonumber(args[1])
  local year, month, day, hour = tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), tonumber(args[5])
  local reason = 'No reason specified'

  if #args >= 5 then

    if not netId or netId == 0 or not GetPlayerName(netId) then
      if source > 0 then
        TriggerClientEvent('vac_notify_client', source, '~y~Invalid netId, please try again.')
      else
        print('^1[WARN] [Valkyrie]^7 Invalid netId, please try again.')
      end
      return
    end

    if IsPlayerAceAllowed(netId, 'vac.ban') then
      if source > 0 then
        return TriggerClientEvent('vac_notify_client', source, '~y~You can\'t ban another user with elevated permissions!')
      else
        return print('^6[INFO] [VALKYRIE]^7 You can\'t ban another user with elevated permissions!')
      end
    end

    year = year * 31556926 or 0
    month = month * 2629743 or 0
    day = day * 86400 or 0
    hour = hour * 3600 or 0

    local banDuration = year + month + day + hour

    if args[6] then
      -- Lua removes from table the element at position shifting down to close space
      -- So we remove the first element every time leaving only the sixth now first arg
      for i = 1, 5 do
        remove(args, 1)
      end
      reason = table.concat(args, " ")
    end

    if source > 0 then
      TriggerClientEvent('vac_notify_client', source, format('~g~Banned user %s with reason %s.', GetPlayerName(netId), reason))
    else
      print(format('^6[INFO] [VALKYRIE]^7 Banned user %s with reason %s.', GetPlayerName(netId), reason))
    end

    exports.Valkyrie:banPlayer(netId, reason, banDuration)
  else
    if source > 0 then
      TriggerClientEvent('vac_notify_client', source, '~y~Invalid number of arguments, please try again.')
    else
      print('^1[WARN] [Valkyrie]^7 Invalid number of arguments, please try again.')
    end
  end
end, true)

RegisterCommand('unban', function(source, args)
  local banId = args[1]
  local reason = 'No reason specified'
  local banRevoker = 'console'

  if not banId then
    if source > 0 then
      TriggerClientEvent('vac_notify_client', source, '~y~Invalid banId, please try again.')
    else
      print('^1[WARN] [Valkyrie]^7 Invalid banId, please try again.')
    end
    return
  end

  if args[2] then
    table.remove(args, 1)
    reason = table.concat(args, " ")
  end

  if source > 0 then
    banRevoker = GetPlayerName(source)
  end

  if not GetResourceKvpString(format('vac_ban_%s', banId)) then
    if source > 0 then
      TriggerClientEvent('vac_notify_client', source, '~y~No ban associated with this Id, did you type it correctly?')
    else
      print('^1[WARN] [VALKYRIE]^7 No ban associated with this Id, did you type it correctly?')
    end
    return
  end

  DeleteResourceKvp(format('vac_ban_%s', banId))

  if source > 0 then
    TriggerClientEvent('vac_notify_client', source, format('~g~ BanId: %s successfully unbanned with reason %s.', banId, reason))
  else
    print('^6[INFO] [VALKYRIE]^7 BanId ' ..banId.. ' successfully unbanned with reason ' ..reason)
  end

  local logTemplate = '**Valkyrie: Unbanned**\nBanId: `%s`\nUnbanned by: %s\nReason: %s'
  local logMessage = format(logTemplate, banId, banRevoker, reason)

  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, content = logMessage}), { ['Content-Type'] = 'application/json' })
end, true)

RegisterCommand('clearo', function()
  for _, netId in pairs(GetPlayers()) do
    TriggerClientEvent('vac_clear_objects', netId)
  end
end, true)

RegisterCommand('clearv', function()
  for _, vehicles in pairs(GetAllVehicles()) do
    DeleteEntity(vehicles)
  end
end, true)

RegisterCommand('clearp', function(source, args)
  for _, pedHandle in pairs(GetAllPeds()) do
    DeleteEntity(pedHandle)
  end
end, true)

RegisterCommand('reload', function(source, args)
  local module = 'all'

  ExecuteCommand('exec resources\\[local]\\Valkyrie\\valkyrie.cfg')

  if modules[args[1]] then
    module = args[1]
  end

  if source > 0 then
    exports.chat:addMessage(source, {
      color = {255, 0, 0},
      args = {'Valkyrie', format('Reloaded module: %s', module)}
    })
  else
    print(format('[Valkyrie] Reloaded: %s', module))
  end

  TriggerEvent('vac_initalize_server', module)
end, true)
