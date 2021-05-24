local format = string.format
local insert = table.insert
local gsub = string.gsub
CreateThread(function()
  TriggerEvent('vac_initalize_server', 'all')
end)

local function fetchBans()
  local bans = {}
  local handle = StartFindKvp('vac_ban_')
  local key = FindKvp(handle)
  -- inplement a caching feature?
  while true do
    Wait(0)
    if key ~= nil then
      insert(bans, key)
    else
      break
    end
  end
  EndFindKvp(handle)
  return bans
end

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
  local _source = source

  deferrals.defer()

  Wait(0)

  deferrals.update(format('Hello %s. Please wait while your identifiers are being checked.', name))

  local bans = fetchBans()

  if next(bans) == nil then
    deferrals.done()
  else
    local identifiers = exports.Valkyrie:getAllPlayerIdentifiers(true, _source)
    for _, banId in pairs(bans) do
      if GetResourceKvpString(bandId):find(identifiers) then
        local reason = gsub(banId, 'ban', 'reason')
        deferrals.done(GetResourceKvpString(reason))
      else
        deferrals.done()
      end
    end
  end
end)
