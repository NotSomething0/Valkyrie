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

local _GetPlayerIdentifiers <const> = GetPlayerIdentifiers

-- Overridden GetPlayerIdentifiers implementation exlcuding IP's and including tokens
-- @param netId | string | player source
-- @return table | all player identifiers and tokens
function GetPlayerIdentifiers(netId)
  if netId < 1 or not GetPlayerEndpoint(netId) then
    return {}
  end

  -- FxDK does not support identifier functions
  if GetConvarInt('sv_fxdkMode', 0) == 1 then
    return {['license'] = 'h8xor'}
  end

  local retval = {}
  local playerIdentifiers = _GetPlayerIdentifiers(netId)
  local playerTokens = GetPlayerTokens(netId)
  local suffix, value

  for i = 1, #playerIdentifiers do
    suffix, value = playerIdentifiers[i]:match("^([^:]+):(.+)$")

    -- Unrelible we don't check for VPN connections
    if suffix ~= 'ip' then
      retval[suffix] = value
    end
  end

  for i = 1, #playerTokens do
    suffix, value = playerTokens[i]:match("^([^:]+):(.+)$")

    -- These can be unrelible so we'll ignore them
    if suffix ~= '0' and suffix ~= '1' then
      retval[suffix] = value
    end
  end

  return retval
end

-- https://github.com/jaymo1011/hackban/blob/master/convars.lua
-- Utility function instead of doing ternary statements  
-- @param varName | string | ConVar key to retrive data from
-- @param default | bool | Default value to return if the ConVar isn't specified
-- @return | bool | Value of the ConVar
function GetConvarBool(varName, default)
  local value = GetConvar(varName, '__nil__')

  if value == 'true' then
    return true
  end

  if value == 'false' then
    return false
  end

  return default
end

-- Utility function instead of checking if the message needs to be sent to the console or client
-- @param target | string | whom to send the message to
-- @param message | string | message content  
function AddMessage(target, message)
  if target == '0' then
    print(message)
    return
  end

  TriggerClientEvent('chat:addMessage', target, {
    color = {255, 0, 0},
    args = {'Valkyrie', message}
  })
end

-- https://gist.github.com/jrus/3197011
-- Generate and return a pseudorandom UUID
-- @return string | UUID
function UUID()
  return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end