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
local VAC_USE_ALLOWLIST = false
local VAC_USE_BLOCKLIST = false
local VAC_LIST_READY
local VAC_ENTITY_LIST = {}

local function setFilterStatus(allow, block)
  log('info', string.format('[ENTITY]: Changing filter status. Allowlist is %s | Blocklist is %s.', allow, block))

  VAC_USE_ALLOWLIST = allow
  VAC_USE_BLOCKLIST = block
end

local function buildEntityList()
  VAC_LIST_READY = false

  if (VAC_USE_ALLOWLIST and VAC_USE_BLOCKLIST) then
    setFilterStatus(false, false)
    error('Entity allowlist and blocklist cannot be used interchangeably.')
  end

  if (VAC_USE_ALLOWLIST or VAC_USE_BLOCKLIST) then
    table.clear(VAC_ENTITY_LIST)
    
    local entityList = json.decode(GetConvar('vac:entity:entityList', '{}'))

    if (not entityList) then
      setFilterStatus(false, false)

      error('No entries could be gathered for VAC_ENTITY_LIST from ConVar vac:entity:entityList.')
    end

    for model, status in pairs(entityList) do
      VAC_ENTITY_LIST[tonumber(GetHashKey(model))] = status
    end

    VAC_LIST_READY = true
  end
end

local function isModelAllowed(modelHash)
  if (VAC_LIST_READY and VAC_USE_ALLOWLIST) then
    if (VAC_ENTITY_LIST[modelHash]) then
      return true
    end
  end

  if (VAC_LIST_READY and VAC_USE_BLOCKLIST) then
    if (not VAC_ENTITY_LIST[modelHash]) then
      return true
    end
  end

  return false
end
exports('isModelAllowed', isModelAllowed)

AddEventHandler('__vac_internel:initialize', function(module)
  if (GetInvokingResource() ~= GetCurrentResourceName() or module ~= 'all' and module ~= 'entities') then
    return
  end

  if (GetConvar('sv_entityLockdown', 'inactive') ~= 'inactive') then
    log('info', '[ENTITY]: Entity Lockdown is enabled disabiling entity filter')
    setFilterStatus(false, false)
    return
  end

  setFilterStatus(GetConvarBool('vac:entity:allowlistEnabled', false), GetConvarBool('vac:entity:blocklistEnabled', false))
  buildEntityList()
end)

AddEventHandler('entityCreating', function(handle)
  local modelHash = tonumber(GetEntityModel(handle))

  if (VAC_LIST_READY and not isModelAllowed(modelHash)) then
    CancelEvent()
  end
end)