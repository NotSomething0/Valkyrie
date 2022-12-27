-- Copyright (C) 2019 - 2023  NotSomething0

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

-- PlayerCache | key: player source | value: VPlayer object
PlayerCache = VCache:new('number', 'table')

-- Extends VCache allows for retrival of a specific player object or the entire set of player objects
setmetatable(PlayerCache, {
  __index = VCache,
  __call = function(self, netId)
    if netId == -1 then
      return self:getData()
    end

    return self:get(netId) or {}
  end
})

-- Re-initialize player data upon a module update
local function initializePlayerCache()
  PlayerCache:clear()

  local players = GetPlayers()

  for i = 1, #players do
    local netId = tonumber(players[i])

    PlayerCache:set(netId, VPlayer:create(netId))
  end
end

-- Handle creation of new entries into the PlayerCache once the player transitions to joining
AddEventHandler('playerJoining', function()
  local netId = tonumber(source)

  PlayerCache:set(netId, VPlayer:create(netId))
end)

-- Handle deltion of PlayerCache entries upon player disconnect
AddEventHandler('playerDropped', function()
  local netId = tonumber(source)

  PlayerCache:remove(netId)
end)

-- Virtual BanCache | key: Ban Id | value: Ban Data
local BanCache = VCache:new('string', 'table')

-- Overloaded VCache:remove which provides a reason for parameter for why the ban is being revoked
-- @param key | string | the ban Id to revoke
-- @param reason | string | the reason for the ban being revoked
function BanCache:remove(key, reason)
  log.info(('[CONNECT]: Removing Ban entry %s for %s'):format(key, reason or 'no reason specified'))
  self.data[key] = nil
end

-- Re-initialize the BanCache upon a module update
local function initializeBanCache()
  BanCache:clear()

  local handle = StartFindKvp('vac_ban_')
  local key

  repeat
    key = FindKvp(handle)

    if key then
      BanCache:set(key, json.decode(GetResourceKvpString(key)))
    end
  until not key

  EndFindKvp(handle)
end

-- Check for expired bans this happens upon any player connection
local function pruneBanCache()
  local cache = BanCache:getData()

  for banId, data in pairs(cache) do
    local expires = data.expires

    if expires - os.time() <= 0 then
      BanCache:remove(banId, 'ban expired')
      DeleteResourceKvp(('vac_ban_%s'):format(banId))
    end
  end
end

-- Used to check if the connecting players identifiers are in the BanCache
-- @param netId | number | player source
-- @return table | banned player data
local function isPlayerBanned(netId)
  pruneBanCache()

  local cache = BanCache:getData()
  local playerIdentifiers = GetIdentifiers(netId)

  for _, data in pairs(cache) do
    local identifiers = data.identifiers

    for suffix, value in pairs(playerIdentifiers) do
      if identifiers[suffix] == value then
        return data
      end
    end
  end

  return {}
end

-- Remove a cached ban entry if it were to be removed externally or via the unban command
AddEventHandler('__vac_internel:banRevoked', function(banId, reason)
  BanCache:remove(banId, reason)
end)

-- Add a new cached ban entry
AddEventHandler('__vac_internel:banIssued', function(banId, data, extended)
  log.info(('[CONNECT]: %s has just been banned for: %s\nBan ID:%s\nThey will be unbanned on %s'):format(GetPlayerName(data.source), extended, data.id, os.date('%c', data.expires)))
  BanCache:set(banId, data)
end)

local blockedUsernameInput = {}
local function isUsernameBlocked(playerName)
  local blockedInput = ''

  if next(blockedUsernameInput) == nil then
    return blockedInput
  end

  for i = 1, #blockedUsernameInput do
    local input = blockedUsernameInput[i]:lower()

    if playerName:find(input) then
      blockedInput = blockedInput .. input .. '\n'
    end
  end

  return blockedInput
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

  local blockedUsernameData = isUsernameBlocked(playerName:lower())

  if blockedUsernameData ~= '' then
    deferrals.done(('Unable to connect to server\nYour username or part of it contains prohibited text.\nPlease remove the following text from your username and reconnect: %s'):format(blockedUsernameData))
  end

  deferrals.update('Your username looks good! Please wait while we check if you\'re banned.')

  local bannedPlayerdata = isPlayerBanned(source)

  if next(bannedPlayerdata) ~= nil then
    local banId = bannedPlayerdata.id
    local expires = os.date('%c', bannedPlayerdata.expires)
    local reason = bannedPlayerdata.reason

    deferrals.done(('You have been banned from this server!\nBan ID: %s\nExpires: %s\nReason: %s\nIf you feel this was done in error rech out to %s'):format(banId, expires, reason, contactLink))
  end

  deferrals.done()
end
AddEventHandler('playerConnecting', onPlayerConnecting)

local function onServerInitalize(module)
  if (module ~= 'all' and module ~= 'connect') then
    return
  end

  contactLink = GetConvar('vac:connect:contact_link', 'nobody')

  CreateThread(initializePlayerCache)
  CreateThread(initializeBanCache)

  table.clear(blockedUsernameInput)

  local _blockedUsernameInput = GetConvar('vac:connect:blocked_username_input', '[]')

  if _blockedUsernameInput:find(']') then
    blockedUsernameInput = json.decode(_blockedUsernameInput)
  end

  log.info(('[CONNECT]: Data synced | Username check: %s | Contact link: %s'):format(checkUsername, contactLink))
end
AddEventHandler('__vac_internel:initialize', onServerInitalize)