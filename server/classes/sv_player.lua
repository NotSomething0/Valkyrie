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

VPlayer = {}

-- Create a new player object
-- @param netId | number | player source
-- @return table | player object
function VPlayer:create(netId)
  if netId < 1 or not GetPlayerEndpoint(netId) then
    error(('Invalid server ID specified: %s'):format(netId))
  end

  local player = {
    source = netId,
    identifiers = GetIdentifiers(netId),
    strikes = 0,
    strikeInfo = {}
  }

  setmetatable(player, self)
  self.__index = self

  return player
end

local UUID_TEMPLATE <const> = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
-- https://gist.github.com/jrus/3197011
-- @return string | UUID
local function uuid()
  return string.gsub(UUID_TEMPLATE, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

local BAN_LENGTHS = {}
-- @param duration | number | epoch timestamp to be added to os.time()
-- @param reason | string | reason given to player as to why they've been banned
-- @param extended | string | reason given to staff/console as to why this player was banned
function VPlayer:ban(duration, reason, extended)
  local banId = ('vac_ban_%s'):format(uuid())
  local duration = BAN_LENGTHS[duration]

  if (not duration) then
    duration = 31536000
  end

  duration = (duration + os.time())
  reason = reason or "No reason specified"

  local data = {
    id = banId,
    expires = duration,
    identifiers = self.identifiers,
    reason = reason
  }

  SetResourceKvp(banId, json.encode(data))

  if not GetResourceKvpString(banId) then
    DropPlayer(self.source, 'Goodbye')
    error(('Unable to create ban for player %s dumping ban data %s'):format(self.source, json.encode(data, {indent = true})))
  end

  DropPlayer(self.source, ('You have been banned from this server!\nBanId: %s\nExpires: %s\nReason: %s'):format(banId, os.date('%c', duration), reason))
  TriggerEvent('__vac_internel:banIssued', banId, data, extended)
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

AddEventHandler('__vac_internel:initialize', function(module)
  if (module ~= 'all' and module ~= 'internal') then
    return
  end

  -- TODO: Custom ban lengths
  --banLength = GetConvarInt('vac:internal:banLength', 31536000)
  strikeLimit = GetConvarInt('vac:internal:strikeLimit', 5)

  log.info(('[INTERNAL]: Data synced | Ban Length: %s | Strike Limit %d'):format('12 months', strikeLimit))

  local players = GetPlayers()

  for i = 1, #players do
    local player = tonumber(players[i])
    VPlayer:create(player)
  end
end)