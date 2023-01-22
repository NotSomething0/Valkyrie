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
local CURRENT_VERSION <const> = GetResourceMetadata(RESOURCE_NAME, 'version', 0)

AddEventHandler('onResourceStart', function(resourceName)
  if RESOURCE_NAME ~= resourceName then
    return
  end

  PerformHttpRequest('https://api.github.com/repos/NotSomething0/Valkyrie/releases', function(code, data, _)
    local latestVersion = CURRENT_VERSION

    if code == 200 then
      latestVersion = json.decode(data)[1].name
    end

    if latestVersion ~= CURRENT_VERSION then
      log.info(('This version of Valkyrie is outdated! Please update as soon as possible!\n Latest Version: %s | Current Version: %s^7'):format(latestVersion, CURRENT_VERSION))
    end
  end)

  TriggerEvent('__vac_internel:initialize', 'all')
end)

local invincibilityCheck = false
local function checkForInvincibility()
  local players = PlayerCache()

  for netId, player in pairs(players) do
    if not IsPlayerAceAllowed(netId, 'vac:invincible') then
      goto continue
    end

    if GetPlayerInvincible(netId) then
      player:strike('Positive result from GetPlayerInvincible')
    end

    ::continue::
  end
end

CreateThread(function()
  while true do
    Wait(1000)

    if invincibilityCheck then
      checkForInvincibility()
    end
  end
end)

local function checkForSuperJump()
  local players = PlayerCache()

  for netId, player in pairs(players) do
    if IsPlayerAceAllowed(netId, 'vac:superJump') then
      goto continue
    end

    if IsPlayerUsingSuperJump(netId) then
      player:strike('Positive result from IsPlayerUsingSuperJump')
    end

    ::continue::
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
  if GetInvokingResource() ~= RESOURCE_NAME and module ~= 'all' and module ~= 'main' then
    return
  end

  invincibilityCheck = GetConvarBool('vac:main:god_mode', false)
  superJumpCheck = GetConvarBool('vac:main:super_jump', false)

  log.info(('[MAIN]: Data synced | Invincibility Check: %s | Super Jump Check: %s'):format(invincibilityCheck, superJumpCheck))
end)