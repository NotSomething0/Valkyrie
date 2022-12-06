-- Copyright (C) 2019 - 2022  NotSomething

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
local BAN_PREFIX <const> = 'vac_ban_%s'

VPlayer = {}
VPlayer.__index = VPlayer

local playerStorage = {}
setmetatable(VPlayer, {
  __call = function(_, netId)
    if (not playerStorage[netId]) then
      return false
    end

    return playerStorage[netId]
  end
})

-- @param netId | string | valid player network ID
function VPlayer:forge(netId)
  if (tonumber(netId) < 1 or not GetPlayerEndpoint(netId)) then
    log.error('[INTERNAL]: Invalid network ID specified a valid online network ID is required.')
  end

  if (playerStorage[netId]) then
    log.trace(('[INTERNAL]: Player object already exists for network ID %s'):format(netId))
    return
  end

  log.trace(('[INTERNAL]: Forging new player object by network ID %s'):format(netId))

  local data = {
    source = netId,
    strikes = 0,
    strikeInfo = {},
    identifiers = getIdentifiers(netId),
  }

  setmetatable(data, VPlayer)
  playerStorage[netId] = data
end

AddEventHandler('playerJoining', function()
  VPlayer:forge(source)
end)

function VPlayer:destroy(netId)
  if (tonumber(netId) < 1 or not GetPlayerEndpoint(netId)) then
    log.error('[INTERNAL]: Invalid network ID specified a valid online network ID is required.')
  end

  log.trace(('[INTERNAL]: Destroying player object by network ID %s'):format(netId))
  playerStorage[netId] = nil
end

AddEventHandler('playerDropped', function()
 VPlayer:destroy(source)
end)

-- https://gist.github.com/jrus/3197011
local function uuid()
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

-- @param duration | number | epoch timestamp to be added to os.time()
-- @param reason | string | reason given to player as to why they've been banned
-- @param extended | string | reason given to staff/console as to why this player was banned
function VPlayer:ban(duration, reason, extended)
  local banId = uuid()

  if (type(duration) ~= 'number' or duration == -1) then
    duration = 31536000
  end

  duration = (duration + os.time())
  reason = reason or "No reason specified"

  local ban_data = {
    id = banId,
    expires = duration,
    identifiers = self.identifiers,
    reason = reason
  }

  SetResourceKvp(BAN_PREFIX:format(banId), json.encode(ban_data))

  if (not GetResourceKvpString(BAN_PREFIX:format(banId))) then
    log.error(('[INTERNAL]: Unable to create ban for player %s dumping ban data %s'):format(json.encode(ban_data, {indent = true})))
  end

  log.info(('[INTERNAL]: %s has just been banned for %s their Ban ID is %s and they will be unbanned on %s'):format(GetPlayerName(self.source), ban_data.id, os.date('%c', duration)))
  DropPlayer(self.source, ('You have been banned from this server!\nBanId: %s\nExpires: %s\nReason: %s'):format(banId, os.date('%c', duration), reason))
  cache.outdated = true
end

local strikeLimit = 5
function VPlayer:strike(reason)
  self.strikes += 1
  self.strikeInfo[#self.strikeInfo + 1] = reason

  log.info(('[INTERNAL]: %s has just recieved a strike for %s'):format(GetPlayerName(self.source), reason))

  if (self.strikes >= strikeLimit) then
    local extendedReason = "Strike Information:\n"
    local strikeData = self.strikeInfo

    for i = 1, #strikeData do
      extendedReason = extendedReason..('Strike #%s: %s'):format(i, strikeData[i])
    end

    self:ban(-1, 'Recieved more than the allotted amount of strikes', extendedReason)
  end
end

local checkUsername = false
local filterText = {}
-- @param name | string| player username
-- @return string | Blocked text found in the players username
local function isUsernameBlocked(name)
  local blockedText = ""

  if (not checkUsername) then
    return blockedText
  end

  for txt in pairs(filterText) do
    if (name:find(txt:lower())) then
      blockedText = blockedText.."\n"..txt
    end
  end

  return blockedText
end

-- @param netId | string | player network Id
-- @return bool | If the player is banned
-- @return table | Data associated with the ban
local function isPlayerBanned(netId, name)
  local banlist = cache.getBans()

  for i = 1, #banlist do
    local ban = banlist[i]

    if (ban.expires - os.time() <= 0) then
      local key = BAN_PREFIX:format(ban.id)

      if (not GetResourceKvpString(key)) then
        return
      end

      DeleteResourceKvp(key)
      cache.outdated = true
    end
  end

  if (cache.outdated) then
    banlist = cache.getBans()
  end

  local playerIdentifiers = getIdentifiers(netId)

  if (not playerIdentifiers) then
    error(('[INTERNAL]: Unable to gather identifiers for %s'):format(name))
  end

  if (next(banlist) == nil) then
    return false, {}
  end

  for i = 1, #banlist do
    local ban = banlist[i]
    local identifiers = ban.identifiers

    for i = 1, #identifiers do
      local pIdentifier = playerIdentifiers[i]
      local bIdentifier = playerIdentifiers[i]

      if (pIdentifier == bIdentifier) then
        return true, ban
      end
    end
  end

  return false, {}
end

local contactInfo = 'unkown'
local function onPlayerConnecting(name, _, d)
  local source = source

  d.defer()

  -- Mandatory Wait!
  Wait(0)

  d.update(('Hello %s thanks for joining! Please wait while we check your username.'):format(name))

  -- Mandatory Wait!
  Wait(0)

  local isUsernameAllowed = isUsernameBlocked(name)
  if (isUsernameAllowed ~= "") then
    d.done(('Cannot connect to server, your username or part of it contains blocked characters.\nPlease remove the following items and reconnect: %s'):format(isUsernameAllowed))
    return
  end

  d.update(('Your username looks good! Hold tight while we check if you\'re banned.'))

  -- Mandatory Wait!
  Wait(0)

  local isBanned, data = isPlayerBanned(source, name)
  if (isBanned) then
    d.done(('You have been banned from this server!\nBan ID: %s\nExpires: %s\nReason: %s\nIf you feel this was done in error rech out to %s'):format(data.id, os.date('%c', data.expires), data.reason, contactInfo))
  end

  d.done()
end
AddEventHandler('playerConnecting', onPlayerConnecting)

AddEventHandler('__vac_internel:initialize', function(module)
  if (module ~= 'all' and module ~= 'internal') then
    return
  end

  deaultBanLength = GetConvarInt('vac:internal:banLength', 31536000)
  strikeLimit = GetConvarInt('vac:internal:strikeLimit', 5)
  contactInfo = GetConvar('vac:internal:contactInfo', 'unkown')
  checkUsername = GetConvarBool('vac:connect:checkUsername', false)

  log.info(('[INTERNAL]: Updating logic Username check: %s | Strike Limit: %d'):format(checkUsername, strikeLimit))
  log.info(('[INTERNAL]: Updating logic Contact Info: %s | Ban length: %d months'):format(contactInfo, math.floor(deaultBanLength/2592000)))

  table.clear(filterText)

  if (not checkUsername) then
    return
  end

  local impassableText = GetConvar('vac:connect:filterText', '{}')

  if (not impassableText:find('}')) then
    error('[INTERNAL]: Unable to parse text for username check, ensure vac:connect:filterText is properly formatted')
  end

  impassableText = json.decode(impassableText)

  for text in pairs(impassableText) do
    filterText[text] = true
  end

  for _, netId in pairs(GetPlayers()) do
    if (not VPlayer(netId)) then
      VPlayer:forge(netId)
    end
  end
end)