local BLOCKED_TEXT = {}

local checkUsername = false
local function isUsernameBlocked(playerName)
  if (not checkUsername or next(blockedText) == nil) then
    return false
  end

  local retval = ''

  for i = 1, #BLOCKED_TEXT do
    local text = BLOCKED_TEXT[i]:lower()

    if (playerName:find(text)) then
      retval = retval..text.."\n"
    end
  end

  if (retval ~= '') then
    return true, retval
  end

  return false
end

local function isPlayerBanned(netId)
  local banlist = VCache:getBans()
  local pIdentifiers = getIdentifiers(netId)

  for i = 1, #banlist do
    local data = banlist[i]
    local bIdentifiers = data.identifiers

    for prefix, value in pairs(pIdentifiers) do
      if (bIdentifiers[prefix] == value) then
        return true, data
      end
    end
  end

  return false
end

local function onPlayerConnecting(playerName, _, de)
  local netId = source
  
  d.defer()

  -- Mandatory Wait!
  Wait(0)

  d.update(('Hello %s thanks for joining! Please wait while we check your username.'):format(name))

  Wait(0)

  local result, data = isUsernameBlocked(playerName:lower())

  if (result) then
    d.done(('Cannot connect to server\nYour username or part of it contais prohibited characters.\nPlease remove the following items and reconnect: %s'):format(data))
  end

  d.update((('Your username looks good! Hold tight while we check if you\'re banned.')))

  local result, data = isPlayerBanned(netId)

  if (result) then
    d.done(('You have been banned from this server!\nBan ID: %s\nExpires: %s\nReason: %s\nIf you feel this was done in error rech out to %s'):format(data.id, os.date('%c', data.expires), data.reason, GetConvar('vac:internal:contact', 'Nope')))
  end

  d.done()
end
AddEventHandler('playerConnecting', onPlayerConnecting)