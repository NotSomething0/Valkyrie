-- Copyright (C) 2019 - Present, NotSomething

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

---@class CPlayer
---@field m_banInProgress boolean Is the player currently being banned
---@field m_source string Player index
---@field m_identifiers table<string, string> Players identifiers constructed as follows \[license\] = 'xxxx'
---@field m_tokens table<string, string> Players tokens constructed as follows \[token\] = 'xxxx'
---@field m_strikes table<number, string> Players strike data constructed as follows \[strikeNum\] = 'strike reason'
CPlayer = {
  m_banInProgress = false,
  m_source = '-1',
  m_identifiers = {},
  m_tokens = {},
  m_strikes = {}
}
CPlayer.__index = CPlayer

---Retrives a table of player identifiers for the specified player index.
---@param playerIndex string The player index you want to retrieve identifiers form
---@return table playerIdentifiers 
local function getPlayerIdentifiers(playerIndex)
  if not DoesPlayerExist(playerIndex) then
    error(('Invalid player index specified %s does not exist'):format(playerIndex))
  end

  -- FxDK does not support player identifiers
  if GetConvarInt('sv_fxdkMode', 0) == 1 then
    return {['license'] = 'h8xor'}
  end

  local playerIdentifiers = {}

  for identifierIndex = 0, GetNumPlayerIdentifiers(playerIndex) - 1 do
    local playerIdentifier = GetPlayerIdentifier(playerIndex, identifierIndex)
    local identifierType, identifierValue = playerIdentifier:match("^([^:]+):(.+)$")

    -- IP's are unreliable
    if identifierType ~= 'ip' then
      playerIdentifiers[identifierType] = identifierValue
    end
  end

  return playerIdentifiers
end

---Retrives a table of player (HWID) tokens for the specified player index.
---@param playerIndex string The player index you want to retrieve tokens from
---@return table playerTokens
local function getPlayerTokens(playerIndex)
  if not DoesPlayerExist(playerIndex) then
    error(('Invalid player index: %s does not exist'):format(playerIndex))
  end

  if GetConvarInt('sv_fxdkMode', 0) == 1 then
    return {['fxdk'] = 'h8xor'}
  end

  local playerTokens = {}

  for i = 0, GetNumPlayerTokens(playerIndex) - 1 do
    local rawToken = GetPlayerToken(playerIndex, i)
    local baseType, tokenValue = rawToken:match("^([^:]+):(.+)$")
    local finalKey = baseType
    local counter = 0

    while playerTokens[finalKey] do
      counter += 1
      finalKey = ("%s+%d"):format(baseType, counter)
    end

    playerTokens[finalKey] = tokenValue
  end

  return playerTokens
end

---Attempts to create a new CPlayer instance
---@param playerIndex string player index
---@return CPlayer? player
function CPlayer.new(playerIndex)
  assert(DoesPlayerExist(playerIndex), ('CPlayer.new unable to create new CPlayer instance for player %s as they do not exist'):format(playerIndex))

  local player = setmetatable({
    m_source = playerIndex,
  }, CPlayer)

  player.m_identifiers = getPlayerIdentifiers(playerIndex)
  player.m_tokens = getPlayerTokens(playerIndex)

  return player
end

---Get the players identifiers
---@return table<string, string>
function CPlayer:getIdentifiers()
  return self.m_identifiers
end

---Get the players tokens
---@return table<string, string>
function CPlayer:getTokens()
  return self.m_tokens
end
