local format = string.format
local explosionLimit = 5
local explosionIndex = {}
local tracker = {}

AddEventHandler('explosionEvent', function(sender, ev)
  local sender = tonumber(sender)

  if explosionIndex[ev.explosionType] and ev.damageScale ~= 0.0 then
    CancelEvent()

    if tracker[sender] then
      tracker[sender] = tracker[sender] + 1
    else
      tracker[sender] = 1
    end

    if tracker[sender] >= explosionLimit then
      exports.Valkyrie:kickPlayer(sender, 'Blocked Explosion', format('Blocked Explosion | Count: %s', tracker[sender]))
    end
  end
end)

AddEventHandler('vac_initalize_server', function(module)
  if module == 'explosion' or 'all' then

    for index in pairs(explosionIndex) do
      explosionIndex[index] = nil
    end

    for _, idx in pairs(json.decode(GetConvar('vac:explosion:allowedExp ', '[]'))) do
      explosionIndex[idx] = true
    end

    explosionLimit = GetConvarInt('vac:explosion:maxAllowedExp', 5)
  end
end)

AddEventHandler('playerDropped', function()
  tracker[source] = nil
end)
