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
local filterAllowedModels = {}

AddEventHandler('entityCreating', function(entity)
  if (filterIsActive and not filterAllowedModels[tonumber(GetEntityModel(entity))]) then
    CancelEvent()
  end
end)

AddEventHandler('__vac_internel:intalizeServer', function(module)
  if (module == 'entities' or 'all') then
    if (GetConvar('sv_entityLockdown', 'inactive') == 'inactive') then
      log.warn('client side spawning of entities is discouraged learn more here: https://github.com/NotSomething0/Valkyrie#q-what-is-entity-lockdown')

      for hash in pairs(filterAllowedModels) do
        filterAllowedModels[hash] = nil
      end

      local filterModels = json.decode(GetConvar('vac:entity:allowedEntities', '[]'))

      if (filterModels ~= nil) then
        for i = 1, #filterModels do
          local hash = tonumber(GetHashKey(filterModels[i]))

          filterAllowedModels[hash] = true
        end
      else
        log.error('unable to parse convar `vac:entity:allowedEntities`, ensure the table is proper formatted')
        return
      end
    end
  end
end)