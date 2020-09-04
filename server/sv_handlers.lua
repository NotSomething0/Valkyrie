RegisterNetEvent('Valkyrie:ClientDetection')
AddEventHandler('Valkyrie:ClientDetection', function(user, log, reason)
  local license = ValkyrieIdentifiers(source).license
  if not license then return end
  if user == nil or user == '' then user = GetPlayerName(source) end
  if log == nil or log == '' then log = 'Triggerd `Valkyrie:ClientDetection` with no parameters.' end
  ValkyrieLog('Player Kicked', '**Player:** ' ..user.. '\n**Reason:** ' ..log.. '\n**license:** ' ..license)
  ValkyrieKickPlayer(source, reason)
end)

local entityStrikes = 0
AddEventHandler('entityCreating', function(entity)
  local entityOwner = NetworkGetEntityOwner(entity)
  if not entityOwner then return end
  local license = ValkyrieIdentifiers(entityOwner).license
  if not license then return end
  if Config.bannedModels[GetEntityModel(entity)] then
    entityStrikes = entityStrikes + 1
    CancelEvent()
  end
  if entityStrikes >= Config.maxEntityStrikes then
    ValkyrieLog('Player Kicked', '**Player:** ' ..GetPlayerName(entityOwner).. '\n**Reason:** Exceded strike limit for entity creation. Strikes: ' ..entityStrikes.. '\n**license:** ' ..license)
    ValkyrieKickPlayer(entityOwner, 'Exceded strike limit for entity creation.')
  end
end)

for _, eventName in pairs(Config.blockedServerEvents) do
  RegisterNetEvent(eventName)
  AddEventHandler(eventName, function()
    local license = ValkyrieIdentifiers(source).license
    if not license then return end
    ValkyrieLog('Player Kicked', '**Player:** ' ..GetPlayerName(source).. '\n**Reason:** Blocked server event `' ..eventName.. '`\n**license:** ' ..license)
    ValkyrieKickPlayer(source, 'Blocked Event')
  end)
end

AddEventHandler('explosionEvent', function(sender, ev)
  local license = ValkyrieIdentifiers(sender).license
  if not license then return end
  for _, expNum in pairs(Config.blockedExplosion) do
    if ev.damageScale <= 0 or ev.isInvisible == true or ev.isAudible == false then return end
    if ev.explosionType == expNum and ev.damageScale >= 1 then
      CancelEvent()
      ValkyrieLog('Player Kicked', '**Player:** ' ..GetPlayerName(sender).. '\n**Reason:** Explosion created `' ..expNum.. '`\n**license:**' ..license)
      ValkyrieKickPlayer(sender, 'Blocked Explosion')
    end
  end
end)

AddEventHandler('chatMessage', function(source, author, text)
  local sender = GetPlayerName(source)
  local license = ValkyrieIdentifiers(source).license
  if not license then return end
  for _, messages in pairs(Config.blockedMessages) do
    if string.match(string.lower(text), string.lower(messages)) then
      ValkyrieLog('Player kicked', '**Player:** ' ..sender.. '\n**Reason:** Blocked chat message `' ..text.. '`\n **license:** ' ..license)
      ValkyrieKickPlayer(source, 'Blocked chat message')
    end
  end
  if sender ~= author then
    CancelEvent()
    ValkyrieLog('Player kicked', '**Player:** ' ..sender.. '\n**Reason:** Tried to say: `' ..text.. '` as `' ..author..'`\n**license:** ' ..license)
    ValkyrieKickPlayer(source, 'Fake chat message')
  end
end)
