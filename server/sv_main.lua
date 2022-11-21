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

AddEventHandler('onResourceStart', function(resourceName)
  if (RESOURCE_NAME ~= resourceName) then
    return
  end

  ---@diagnostic disable-next-line: missing-parameter
  PerformHttpRequest('https://api.github.com/repos/NotSomething0/Valkyrie/releases', function(code, data)
    local latestVersion = CURRENT_VERSION

    if (code == 200) then
      latestVersion = json.decode(data)[1].name
    end

    if (latestVersion ~= CURRENT_VERSION) then
      log.info(('This version of Valkyrie is outdated! Please update as soon as possible!\n Latest Version: %s | Current Version: %s^7'):format(latestVersion, CURRENT_VERSION))
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
      return
    end

    if (GetPlayerInvincible(netId)) then
      player:strike('Positive result from GetPlayerInvincible')
    end
  end
end

local godModeCheck = false
CreateThread(function()
  while true do
    Wait(1000)

    if (godModeCheck) then
      checkForGodmode()
    end
  end
end)

local function checkForSuperJump()
  local players = GetPlayers()

  for i = 1, #players do
    local netId = players[i]
    local player = VPlayer(netId)

    if (not player) then
      return
    end

    if (IsPlayerAceAllowed(netId, 'vac:superjump')) then
      return
    end

    if (IsPlayerUsingSuperJump(netId)) then
      player:strike('Positive result from IsPlayerUsingSuperJump')
    end
  end
end

local superJumpCheck = false
CreateThread(function()
  while true do
    Wait(1000)

    if (superJumpCheck) then
      checkForSuperJump()
    end
  end
end)

AddEventHandler('__vac_internel:initialize', function(module)
  if (module ~= 'all' and module ~= 'main') then
    return
  end

  godModeCheck = GetConvarBool('vac:main:godModeCheck', false)
  superJumpCheck = GetConvarBool('vac:main:superJumpCheck', false)

  log.info(('[MAIN]: Updating basic checks Godmode Check: %s | Super Jump Check: %s'):format(godModeCheck, superJumpCheck))
end)