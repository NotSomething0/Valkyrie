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
local BAN_KEY <const> = 'vac_ban_%s'

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
    banInProgress = false,
    identifiers = GetPlayerIdentifiers(netId),
    strikes = {},
    explosions = {}
  }

  self.__index = self

  return setmetatable(playerObject, self)
end

local punishmentNameToType = {}

function VPlayer:punish(punishmentName, punishmentReason, staffReason)
  local punishmentType = punishmentNameToType[punishmentName]

  if punishmentType == 'strike' then
    self:strike(punishmentReason)
  end

  if punishmentType == 'kick' then
    -- TODO: Add a kick function
  end

  if tonumber(punishmentType) then
    local duration = tonumber(punishmentType)

    self:ban(duration, punishmentReason, staffReason)
  end
end

local strikeLimit = 5

-- @param reason | string
function VPlayer:strike(reason)
  self.strikes[#self.strikes + 1] = reason

  log.info(('[INTERNAL]: %s has just recieved a strike for %s'):format(GetPlayerName(self.source), reason))

  if #self.strikes >= strikeLimit and not self.banInProgress then
    local staffReason = 'Strike Information: \n'
    for i = 1, #self.strikes do
      staffReason = staffReason..('Strike #%d: %s'):format(i, self.strikes[i])
    end

    self:ban(0, 'Recieved more than the allotted amount of strikes', staffReason)
  end
end

-- This needs a rewrite we shouldn't store the entire json object in one entry
-- @param duration | number | epoch timestamp to be added to os.time()
-- @param reason | string | reason given to player as to why they've been banned
-- @param extended | string | reason given to staff/console as to why this player was banned
function VPlayer:ban(duration, playerReason, staffReason)
  local banId <const> = BAN_KEY:format(UUID())

  self.banInProgress = true

  local playerIdentifiers = self.identifiers
  local playerBanReason = playerReason or 'No reason specified'
  local playerBanExpires = duration
  local staffBanReason = staffReason or 'No reason specified'

  if type(playerBanExpires) ~= 'number' or playerBanExpires < 86400 then
    playerBanExpires = 86400 + os.time()
  else
    playerBanExpires = playerBanExpires + os.time()
  end

  local playerBanData = {
    id = banId,
    expires = playerBanExpires,
    identifiers = playerIdentifiers,
    reason = playerBanReason
  }

  SetResourceKvp(banId, json.encode(playerBanData))

  if not GetResourceKvpString(banId) then
    log.info(('Unable to create ban for %s dropping player with reason \'Goodbye\''):format(GetPlayerName(self.source)))
    DropPlayer(self.source, 'Goodbye')
    return
  end

  log.info(('%s has just been banned from the server for %s. Their ban will expire on %s'):format(GetPlayerName(self.source), staffBanReason, os.date('!%c', playerBanExpires)))
  DropPlayer(self.source, ('You have been banned from this server!\nBanId: %s\nExpires: %s\nReason: %s'):format(banId, os.date('!%c', duration), playerBanReason))
end

AddEventHandler('__vac_internel:initialize', function(module)
  if GetInvokingResource() ~= RESOURCE_NAME or module ~= 'all' and module ~= 'internal' then
    return
  end

  strikeLimit = GetConvarInt('vac:internal:strikeLimit', 5)

  log.info(('[INTERNAL]: Data synced | Strike Limit %d'):format(strikeLimit))
end)