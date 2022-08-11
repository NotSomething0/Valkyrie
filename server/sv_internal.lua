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
local VAC_BAN_PREFIX <const> = 'vac_ban_'
local VAC_DEFAULT_BAN_LENGTH <const> = 31536000

local cache = {}
cache.identifiers = {}
cache.bans = {}
cache.outdated = true

-- @param netId | string | player source
-- @param temp | bool | Is this connection deferred
-- @return table | player identifiers 
function cache.getIdentifiers(netId, deferred)
  local t = {}

  if (tonumber(netId) >= 1 and not cache.identifiers[netId]) then
    for _, v in pairs(GetPlayerIdentifiers(netId)) do
      local idx, value = v:match("^([^:]+):(.+)$")

      -- high variance/unreliable
      -- also prevents abuse by bad actors
      if (idx ~= 'ip') then
        t[idx] = value
      end
    end

    for _, v in pairs(GetPlayerTokens(netId)) do
      local idx, value = v:match("^([^:]+):(.+)$")

      -- unreliable multiple users can have the same first and second token
      if (idx ~= '0' and idx ~= '1') then
        t[idx] = value
      end
    end

    -- if the player doesn't have a permanent netId
    -- don't populate the cache table as they might be dropped in connection
    if (not deferred) then
      cache.identifiers[netId] = t
      return cache.identifiers[netId]
    end

    return t
  end

  return cache.identifiers[netId]
end

-- @return table | All player bans currently on the server
function cache.getBans()
  if (not cache.outdated) then
    return cache.bans
  end

  local handle = StartFindKvp(VAC_BAN_PREFIX)
  local collectedBans = {}
  local key
  
  repeat
    key = FindKvp(handle)
    
    if (key) then
      collectedBans[key] = json.decode(GetResourceKvpString(key))
    end
  until not key
  EndFindKvp(handle)

  if (next(collectedBans) == nil) then
    return {}
  end

  cache.outdated = false
  cache.bans = collectedBans
  return cache.bans
end

VPlayer = {}

setmetatable(VPlayer, {
  __call = function(self, netId)
    if (not VPlayer[netId]) then
      return VPlayer.createPlayer(netId)
    end

    return VPlayer[netId]
  end
})

function VPlayer.createPlayer(netId)
  if (type(netId) ~= 'string' and type(netId) ~= 'number') then
    log('error', 'Invalid argument passed at index #1, player source of type string or number got ' ..type(netId))
    return
  end

  if (not GetPlayerEndpoint(netId)) then
    log('error', string.format('Invalid player source pased at index #1, GetPlayerEndpoint returned nil'))
    return
  end

  if (not VPlayer[netId]) then
    local player_data = {
      source = netId,
      strikes = 0,
      permissions = {},
      identifiers = cache.getIdentifiers(netId, false)
    }
    
    VPlayer[netId] = player_data
  end

  return VPlayer[netId]
end

function VPlayer.addPermission(netId, permissions, identifier)
  if (type(permissions) ~= 'table') then
    error('Invalid argument in function VPlayer.addPermission. Index #2 (permissionType) must be of type table.')
  end

  if (#permissions <= 0) then
    error('Invalid argument in function VPlayer.addPermission. Index #2 (permissionType) must have at least one table entry.')
  end

  local player = VPlayer(netId)

  for _, permission in pairs(permissions) do
    if (player and not player.permissions[permission]) then
      player.permissions[permission] = identifier
      ExecuteCommand(string.format('add_ace identifier.%s %s allow', identifier, permission))
    end

    if (not IsPlayerAceAllowed(netId, permission)) then
      error('An ukown error occured, unable to add ' ..permission..' to player.')
      return false
    end
  end

  return true
end
exports('addPermission', VPlayer.addPermission)

function VPlayer.removePermission(netId, permissions)
  if (type(permissions) ~= 'table') then
    error('Invalid argument in function VPlayer.removePermission. Index #2 (permissionType) must be of type table.')
  end

  if (#permissions <= 0) then
    error('Invalid argument in function VPlayer.removePermission. Index #2 (permissionType) must have at least one table entry.')
  end

  local player = VPlayer(netId)

  for _, permission in pairs(permissions) do
    if (player and player.permissions[permission]) then
      local identifier = player.permissions[permission]

      if (identifier) then
        ExecuteCommand(string.format('remove_ace identifier.%s %s allow', identifier, permission))
        player.permissions[permission] = nil
      end
      
      print(netId, permission)
      print(IsPlayerAceAllowed(netId, permission))

      if (IsPlayerAceAllowed(netId, permission)) then
        error('An ukown error occured, unable to add ' ..permission..' to player.')
        return false
      end
    end
  end

  return false
end
exports('removePermission', VPlayer.removePermission)

-- @return string | Universally unique identifier
local function uuid()
  --https://gist.github.com/jrus/3197011
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

-- @param netId | number | player source
-- @param duration | number | epoch ban length
-- @param reason | string | reason for the ban
-- @param extra | string | any additonal data
local function VPlayer.Ban(netId, duration, reason, extra)
  -- Check if the player is online
  if (not GetPlayerEndpoint(netId)) then
    return false
  end

  if (type(duration) ~= 'number' or duration == -1) then
    duration = (VAC_DEFAULT_BAN_LENGTH + os.time())
  end

  duration = (duration + os.time())

  if (not reason or reason == "") then
    reason = "No reason specified"
  end

  local data = {
    banId = uuid(),
    expires = duration,
    identifiers = json.encode(cache.getIdentifiers(netId, false)),
    reason = reason
  }

  SetResourceKvp(('vac_ban_%s'):format(data.banId), json.encode(data))
  local data = GetResourceKvpString(('vac_ban_%s'):format(data.banId))

  if (not data) then
    log('error', json.encode(data))
    error(('Failed to create ban for player %s, an unkown error has occured'):format(GetPlayerName(netId)))
  end

  DropPlayer(netId, string.format('You have been banned\nBanId: %s\nExpires: %s\nReason: %s', data.banId, os.date('%c', data.expires), data.reason))
  cache.outdated = true
  return true 
end
exports('ban', VPlayer.Ban)

-- @param banId | string | Database BanId with prerfix (vac_ban_)
-- @param reason | string | Reason for the removal of the ban
-- @return bool | Was the ban removed
local function VPlayer.Unban(banId, reason)
  local data = GetResourceKvpString(banId)

  if (not data) then
    log('info', ('BanId %s is not in the database'):format(banId))
    return false
  end

  DeleteResourceKvp(banId)

  if (GetResourceKvpString(banId)) then
    log('error', json.encode(data))
    error(string.format('Failed to delete ban from database BanId %s', banId))
  end

  log('info', string.format('Deleted ban by BanId %s from the database with reason %s', banId, reason))
  return true
end
exports('unban', VPlayer.Unban)

-- @param name | string| player username
-- @return string | Blocked text found in the players username
local function isUsernameBlocked(name)
  local blockedText = ""

  for txt, status in pairs(VAC_FILTER_USERNAME_TEXT) do
    if (status and name:find(txt:lower())) then
      blockedText = blockedText.."\n".."txt"
    end
  end

  if (blockedText) then
    return blockedText
  end

  return ""
end

-- @param netId | string | player network Id
-- @return bool | If the player is banned
-- @return table | Data associated with the ban
local function isPlayerBanned(netId)
  local banlist = cache.getBans()

  -- There are no bans in the database so this user can't be banned
  if (next(banlist) == nil) then
    return false
  end

  local playerIdentifiers = cache.getIdentifiers(netId, true)
  for banId, data in pairs(banlist) do
    -- Automatically clean up expired bans
    if (data.expires - os.time() <= 0) then
      removeBan(banId, 'Ban has expired')
      goto continue
    end

    -- Loop through bannd identifiers and check
    -- If the index of that identifier is equal to a players
    for idx, value in pairs(json.decode(data.identifiers)) do
      print(playerIdentifiers[idx], value)
      if (playerIdentifiers[idx] == value) then
        return true, data
      end
    end

    ::continue::
  end

  return false, {}
end

local function onPlayerConnecting(name, _, d)
  local source = source

  d.defer()

  -- Mandatory Wait!
  Wait(0)

  d.update(string.format('Hello %s. Please wait while your username is being checked.', name))

  if (VAC_FILTER_USERNAME and next(VAC_FILTER_USERNAME_TEXT) ~= nil) then
    local blocked = isUsernameBlocked(name:lower())
    if (blocked ~= "") then
      -- Mandatory Wait!
      Wait(0)

      d.done(string.format('Unable to complete connection, your username or part of it contains blocked characters. Please remove the below items and reconnect.\n%s', blocked))
    end
  end

  -- Mandatory Wait!
  Wait(0)

  d.update('Fetching ban data please wait')

  -- Mandatory Wait!
  Wait(0)

  local isBanned, data = isPlayerBanned(source)
  if (isBanned) then
    d.done(string.format('You have been banned\nBan Id: %s\nExpires: %s\nReason: %s', data.banId, os.date('%c', data.expires), data.reason))
  end

  d.done()
end
AddEventHandler('playerConnecting', onPlayerConnecting)