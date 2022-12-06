local BanCache = VCache:new('string', 'table')

local function initializeBanlist()
  if next(BanCache.data) ~= nil then
    BanCache:clear()
  end

  local handle = StartFindKvp('vac_ban_')
  local key

  repeat
    key = FindKvp(handle)

    if (key) then
      BanCache:set(key, json.decode(GetResourceKvpString(key)))
    end
  until not key
  EndFindKvp(handle)
end

-- Parse through banlist and remove expired bans
local function cleanBanlist()
  local banlist = BanCache:getData()

  for _, data in pairs(banlist) do
    local expires = data.expires

    if (expires - os.time() <= 0) then
      local banId = data.id

      BanCache:remove(banId)
      DeleteResourceKvp(('vac_ban_%s'):format(banId))
      log.info(('[CONNECT]: Removed expired ban %s'):format(banId))
    end
  end
end

local function isPlayerBanned(netId)
  cleanBanlist()

  local playerIdentifiers = GetIdentifiers(netId)
  local banlist = BanCache:getData()

  for _, data in pairs(banlist) do
    local bannedIdentifiers = data.identifiers

    for suffix, value in pairs(playerIdentifiers) do
      if bannedIdentifiers[suffix] == value then
        return data
      end
    end
  end

  return {}
end

AddEventHandler('__vac_internel:banRevoked', function(banId, reason)
  log.info((('[CONNECT]: Removing ban entry BanId %s | Reason %s'):format(banId, reason)))
  BanCache:remove(banId)
end)

AddEventHandler('__vac_internel:banIssued', function(banId, data)
  log.info(('[CONNECT]: %s has just been banned for: %s\nBan ID:%s\nThey will be unbanned on %s'):format(GetPlayerName(self.source), extended, data.id, os.date('%c', duration)))
  BanCache:set(banId, data)
end)

local invalidUsernameInput = {}
local checkUsername = false

local function isUsernameBlocked(playerName)
  local invalidInput = ''

  if next(invalidUsernameInput) == nil then
    error('The username check is enabled but the filter input is empty. Check vac:connect:invalid_username_input for proper syntax')
  end

  for i = 1, #invalidUsernameInput do
    local string = invalidUsernameInput[i]:lower()

    if playerName:find(string) then
      invalidInput = invalidInput .. string .. '\n'
    end
  end

  return invalidInput
end

local contactLink = GetConvar('vac:internal:contact_link', 'nobody')
local function onPlayerConnecting(playerName, _, deferrals)
  local source = source

  deferrals.defer()

  -- Mandatory Wait!
  Wait(0)

  deferrals.update(('Hello %s thanks for joining! Please wait while we check your username.'):format(playerName))

  --Mandatory Wait!
  Wait(0)

  if checkUsername then
    local status, data = pcall(isUsernameBlocked, playerName)

    if (not status) then
      deferrals.done(('Unable to connect to server\nUsername check is not set up properly contact your server administrators.'):format(data))
      error(data)
    end

    if (data ~= '') then
      deferrals.done(('Unable to connect to server\nYour username or part of it contains prohibited text.\nPlease remove the following text from your username and reconnect: %s'):format(data))
    end
  end

  deferrals.update('Your username looks good! Please wait while we check if you\'re banned.')

  local data = isPlayerBanned(source)

  if next(data) ~= nil then
    deferrals.done(('You have been banned from this server!\nBan ID: %s\nExpires: %s\nReason: %s\nIf you feel this was done in error rech out to %s'):format(data.id, os.date('%c', data.expires), data.reason, contactLink))
  end

  deferrals.done()
end

AddEventHandler('playerConnecting', onPlayerConnecting)

local function onServerInitalize(module)
  if (module ~= 'all' and module ~= 'connect') then
    return
  end

  -- prevent blocking of other data initalization
  CreateThread(initializeBanlist)

  checkUsername = GetConvarBool('vac:connect:username_check', false)

  if (checkUsername) then
    local data = GetConvar('vac:connect:invalid_username_input', '[]')

    -- ensure the username filter wont proceed if data is invalid
    table.clear(invalidUsernameInput)

    if (not data:find(']')) then
      error('Unable to parse username filter input check vac:connect:invalid_username_input for proper syntax.')
    end

    invalidUsernameInput = json.decode(data)
  end

  contactLink = GetConvar('vac:connect:contact_link', 'nobody')

  log.info(('[CONNECT]: Data synced | Username check: %s | Contact link: %s'):format(checkUsername, contactLink))
end
AddEventHandler('__vac_internel:initialize', onServerInitalize)