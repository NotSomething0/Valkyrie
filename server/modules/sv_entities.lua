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

local filteredEntities = {}
local entityValidation = false

AddEventHandler('entityCreating', function(handle)
  local modelHash = tonumber(GetEntityModel(handle))

  if entityValidation and filteredEntities[modelHash] then
    CancelEvent()
  end
end)

AddEventHandler('__vac_internel:initialize', function(module)
  if GetInvokingResource() ~= GetCurrentResourceName() or module ~= 'all' and module ~= 'entities' then
    return
  end

  entityValidation = GetConvar('vac:entity:validate_entities', 'false') == true and true or false

  if GetConvar('sv_entityLockdown', 'inactive') ~= 'inactive' then
    entityValidation = false
  end

  local blockedEntityCount = 0

  if entityValidation then
    local models = GetConvar('vac:entity:blocked_models', '{}')

    table.clear(filteredEntities)

    if not models:find('}') then
      error('Unable to parse \'vac:entity:blocked_models\' check for proper syntax')
    end

    models = json.decode(models)

    for modelHash, modelName in pairs(models) do
      filteredEntities[modelHash] = modelName
      blockedEntityCount = blockedEntityCount + 1
    end
  end

  if blockedEntityCount >= 50 then
    log.warn('[ENTITIES]: Your blocked entity count is rather large consider using sv_entityLockdown instead.')
  end

  log.info(('[ENTITIES]: Data synced | Entity Validation: %s'):format(entityValidation and 'Enabled' or 'Disabled'))
end)