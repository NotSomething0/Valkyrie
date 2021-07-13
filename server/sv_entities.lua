local allowedEntities = {}
AddEventHandler('entityCreating', function(entity)
  if not allowedEntities[tonumber(GetEntityModel(entity))] then
    CancelEvent()
  end
end)

AddEventHandler('vac_initalize_server', function(module)
  if module == 'entities' or 'all' then

    for hash in pairs(allowedEntities) do
      allowedEntities[hash] = nil
    end

    local models = json.decode(GetConvar('valkyrie_allowed_entities', '[]'))
    for i = 1, #models do
      local hash = tonumber(GetHashKey(models[i]))

      rawset(allowedEntities, hash, true)
    end
  end
end)
