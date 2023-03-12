-- Copyright (C) 2019 - 2023  NotSomething

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

VPlayer = {}

-- Creates and returns a new instance of VPlayer for the specified player
-- @param netId | number | player source
-- @return table | VPlayer
function VPlayer:new(netId)
  if not tonumber(netId) or tonumber(netId) < 1 or not GetPlayerEndpoint(netId) then
    error(('Invalid player specified: %s'):format(netId))
  end

  local playerObject = {
    source = netId,
    identifiers = GetPlayerIdentifiers(netId),
    strikes = {},
    explosions = {}
  }

  self.__index = self

  return setmetatable(playerObject, self)
end

local BAN_KEY <const> = 'vac_ban_%s'

-- @param duration | number | epoch timestamp to be added to os.time()
-- @param reason | string | reason given to player as to why they've been banned
-- @param extended | string | reason given to staff/console as to why this player was banned
function VPlayer:ban(duration, playerReason, staffReason)
  local banId = BAN_KEY:format(UUID())
  if (not duration) then
    duration = 31536000
  end

  duration = (duration + os.time())
  playerReason = playerReason or "No reason specified"

  local data = {
    id = banId,
    expires = duration,
    identifiers = self.identifiers,
    reason = playerReason
  }

  SetResourceKvp(banId, json.encode(data))

  if not GetResourceKvpString(banId) then
    DropPlayer(self.source, 'Goodbye')
    error(('Unable to create ban for player %s dumping ban data %s'):format(self.source, json.encode(data, {indent = true})))
  end

  DropPlayer(self.source, ('You have been banned from this server!\nBanId: %s\nExpires: %s\nReason: %s'):format(banId, os.date('%c', duration), playerReason))
  TriggerEvent('__vac_internel:banIssued', banId, data, staffReason)
end

local strikeLimit = 5

-- @param reason | string
function VPlayer:strike(reason)
  self.strikes[#self.strikes + 1] = reason

  log.info(('[INTERNAL]: %s has just recieved a strike for %s'):format(GetPlayerName(self.source), reason))

  if #self.strikes >= strikeLimit then
    local staffReason = 'Strike Information: \n'
    for i = 1, #self.strikes do
      staffReason = staffReason..('Strike #%d: %s'):format(i, self.strikes[i])
    end

    self:ban(0, 'Recieved more than the allotted amount of strikes', staffReason)
  end
end

AddEventHandler('__vac_internel:initialize', function(module)
  if GetInvokingResource() ~= RESOURCE_NAME or module ~= 'all' and module ~= 'internal' then
    return
  end

  strikeLimit = GetConvarInt('vac:internal:strikeLimit', 5)

  log.info(('[INTERNAL]: Data synced | Ban Length: %s | Strike Limit %d'):format('12 months', strikeLimit))
end)