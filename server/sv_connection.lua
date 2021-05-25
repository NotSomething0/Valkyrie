local format = string.format
local insert = table.insert
local gsub = string.gsub
local decode = json.decode
CreateThread(function()
  TriggerEvent('vac_initalize_server', 'all')
end)

local function fetchBans()
  local bans = {}
  local handle = StartFindKvp('vac_ban_')
  -- inplement a caching feature?
  while true do
    local key = FindKvp(handle)
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
      for _, v in pairs(decode(GetResourceKvpString(banId))) do
        if identifiers:find(v) then
          local reason = gsub(banId, 'ban', 'reason')
          return deferrals.done(GetResourceKvpString(reason))
        end
      end
      deferrals.done()
    end
  end
end)
