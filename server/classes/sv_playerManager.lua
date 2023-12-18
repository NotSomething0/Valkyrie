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

local RESOURCE_NAME <const> = GetCurrentResourceName()

-- PlayerCache | key: player source | value: VPlayer
PlayerCache = VCache:new('number', 'table')

function PlayerCache:initialize()
  local players = GetPlayers()

  ---@diagnostic disable-next-line: undefined-field
  table.clear(self.data)

  for i = 1, #players do
    local netId = tonumber(players[i])

    self:set(netId, VPlayer:new(netId))
  end
end

-- Handle creation of new entries into the PlayerCache once the player transitions to joining
AddEventHandler('playerJoining', function()
  if IsPlayerAceAllowed(source, 'vac:ultraviolet') then
    return
  end

  PlayerCache:set(source, VPlayer:new(source))
end)

-- Handle deltion of PlayerCache entries upon player disconnection
AddEventHandler('playerDropped', function()
  if IsPlayerAceAllowed(source, 'vac:ultraviolet') then
    return
  end

  PlayerCache:invalidate(source)
end)

-- BanCache | key: Ban Id | value: Ban Data
BanCache = VCache:new('string', 'table')

function BanCache:initialize()
  local handle = StartFindKvp('vac_ban_')
  local key

  ---@diagnostic disable-next-line: undefined-field
  table.clear(self.data)

  repeat
    key = FindKvp(handle)

    if key then
      BanCache:set(key, json.decode(GetResourceKvpString(key)))
    end
  until not key

  EndFindKvp(handle)
end

function BanCache:prune()
  local banData = self.data

  for banId, data in pairs(banData) do
    if data.expires - os.time() <= 0 then
      self:invalidate(banId)
      DeleteResourceKvp(('vac_ban_%s'):format(banId))
    end
  end
end

-- Check if a connecting player is banned
-- @param netId | string | player source
-- @param deferrals | object | playerConnecting deferrals object
-- @return bool | whether the player is banned
function BanCache:isPlayerBanned(netId, deferrals)
  self:prune()

  local playerIdentifiers = GetPlayerIdentifiers(netId)

  for _, data in pairs(self.data) do
    for suffix, value in pairs(playerIdentifiers) do
      if data.identifiers[suffix] == value then
        deferrals.done(('You have been banned from this server!\nBan ID: %s\nExpires: %s (UTC)\nReason: %s\nIf you feel this was done in error rech out to %s'):format(data.id, os.date('!%c', data.expires), data.reason, GetConvar('vac:internal:contact_link', '')))

        return true
      end
    end
  end

  return false
end

local checkUsernameInput = false
local prohibitedUsernameInput = {}

AddEventHandler('playerConnecting', function(playerName, _, deferrals)
  local source = source

  deferrals.defer()

  -- Mandatory Wait!
  Wait(0)

  if checkUsernameInput then
    deferrals.update(('Hello %s thanks for joining! Please wait while we check your username.'):format(playerName))

    -- Mandatory Wait!
    Wait(0)

    -- normalize connecting players name for this scope only 
    local playerName = playerName:lower()

    for i = 1, #prohibitedUsernameInput do
      local prohibitedInput = prohibitedUsernameInput[i]:lower()

      if playerName:find(prohibitedInput) then
        deferrals.done(('Unable to connect to server!\nYour username contains prohibited input %s. Please remove the prohibited input and reconnect.'):format(prohibitedInput))
      end
    end
  end

  if BanCache:isPlayerBanned(source, deferrals) then
    log.info(('Banned player %s has just attempted to connect'):format(playerName))
    return
  end

  deferrals.done()
end)

AddEventHandler('__vac_internel:initialize', function(module)
  if GetInvokingResource() ~= RESOURCE_NAME or module ~= 'all' and module ~= 'connect' then
    return
  end

  PlayerCache:initialize()
  BanCache:initialize()

  checkUsernameInput = GetConvarBool('vac:internal:check_username_input', false)

  if checkUsernameInput then
    table.clear(prohibitedUsernameInput)

    local prohibitedInput = json.decode(GetConvar('vac:internal_prohibited_username_input', '{}'))

    for i = 1, #prohibitedInput do
      prohibitedUsernameInput[i] = prohibitedInput[i]
    end
  end

  log.info(('[CONNECT]: Data synced | Username check: %s'):format(checkUsernameInput))
end)