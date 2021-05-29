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
  local key

  repeat
    key = FindKvp(handle)
    if key then
      insert(bans, key)
    end
  until not key

  EndFindKvp(handle)

  return bans
end

local blockedNames = decode(GetConvar('valkyrie_blocked_names', '[]'))
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
  local _source = source

  deferrals.defer()

  Wait(0)

  deferrals.update(format('Hello %s. Please wait while your identifiers are being checked.', name))

  for _, v in pairs(blockedNames) do
    if name:lower():find(v) then
      deferrals.done(format('Abuse Prevention\nYour username contains prohibited items(s)\nItem: %s\n Please remove the prohibited item then rejoin', v))
    end
  end

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
