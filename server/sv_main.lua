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
local RESOURCE_NAME <const> = GetCurrentResourceName()
local CURRENT_VERSION <const> = GetResourceMetadata(RESOURCE_NAME, 'version', 0)
local LATEST_VERSION = '0.0.0'

AddEventHandler('onResourceStart', function(resourceName)
  if (RESOURCE_NAME ~= resourceName) then
    return
  end

  PerformHttpRequest('https://api.github.com/repos/NotSomething0/Valkyrie/releases', function(code, data)
    if (code == 200) then
      LATEST_VERSION = json.decode(data)[1].name
    end

    if (LATEST_VERSION ~= CURRENT_VERSION) then
      log.info(('This version of Valkyrie is outdated! Please update as soon as possible!\n Latest Version: %s | Current Version: %s^7'):format(LATEST_VERSION, CURRENT_VERSION))
    end
  end)

  TriggerEvent('__vac_internel:initialize', 'all')
end)

local function checkForGodmode()
  local players = GetPlayers()

  for i = 1, #players do
    local netId = players[i]
    local player = VPlayer(netId)

    if (not player) then
      return
    end

    if (IsPlayerAceAllowed(netId, 'vac:godmode')) then
      log.trace(('[MAIN]: %s has bypassed Godmode checks, they have the \'vac:godmode\' permission.'):format(GetPlayerName(netId)))
      return
    end

    if (GetPlayerInvincible(netId)) then
      player:strike('Positive result from GetPlayerInvincible')
    end
  end
end

local godmodeCheck = false
CreateThread(function()
  while true do
    Wait(1000)

    if (godmodeCheck) then
      checkForGodmode()
    end
  end
end)

AddEventHandler('__vac_internel:initialize', function(module)
  if (module ~= 'all' and module ~= 'main') then
    return
  end

  godmodeCheck = GetConvarBool('vac:main:godmodeCheck', false)

  log.info(('[MAIN]: Updating basic checks Godmode Check: %s '):format(godmodeCheck))
end)