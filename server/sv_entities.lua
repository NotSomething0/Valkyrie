local isActive
local allowedEntities = {}

AddEventHandler('entityCreating', function(entity)
  if (not allowedEntities[tonumber(GetEntityModel(entity))] and isActive) then
    CancelEvent()
  end
end)

AddEventHandler('__vac_internel:intalizeServer', function(module)
  if (module == 'entities' or 'all') then

    if (GetConvar('sv_entityLockdown', 'inactive') == 'inactive') then
      print('[^1WARNING^7]: Client side spawning of entities is discouraged learn more here: https://github.com/NotSomething0/Valkyrie#q-what-is-entity-lockdown')

      local next = next
      if (next(allowedEntities) ~= nil) then
        for hash in pairs(allowedEntities) do
          allowedEntities[hash] = nil
        end
      end

      local allowedModels = json.decode(GetConvar('vac:entity:allowedEntities', '[]'))

      if (allowedModels ~= '') then
        for i = 1, #models do
          local hash = tonumber(GetHashKey(models[i]))

          allowedEntities[hash] = true
        end
    end
    isActive = true
  end
  isActive = false
end)
