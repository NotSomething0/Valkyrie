--Optimization--
local seed = math.randomseed
local gsub = string.gsub
local random = math.random
local format = string.format
local GetNumPlayerIdentifiers = GetNumPlayerIdentifiers
local GetPlayerIdentifier = GetPlayerIdentifier
local GetNumPlayerTokens = GetNumPlayerTokens
local GetPlayerToken = GetPlayerToken
local encode = json.encode
local webhook = GetConvar("valkyrie_discord_webhook", "")
local templates = {
  ban = 'Banned\nYou have been banned from this server for %s.\nIf you think this was a mistake contact us here: example.com/forums\nBanId: %s',
  kick = 'Kicked\nYou have been kicked from this server for %s.\nIf you think this was a mistake contact us here: example.com/forums.',
  log = '**Valkyrie: %s**\nPlayer: %s\nReason: %s'
}

-- https://gist.github.com/skeeto/c61167ff0ee1d0581ad60d75076de62f
local function uuid()
  seed(os.time())
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return gsub(template, '[xy]', function (c)
    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
    return format('%x', v)
  end)
end

local _identifierCache = {}
local function getAllPlayerIdentifiers(isTemporary, player)
  local identifiers = {}
  if _identifierCache[player] == nil then
    for i = 0, GetNumPlayerIdentifiers(player) - 1 do
        local raw = GetPlayerIdentifier(player, i)
        local idx, value = raw:match("^([^:]+):(.+)$")
        if idx ~= 'ip' then
          identifiers[idx] = value
        end
    end
    for i = 0, GetNumPlayerTokens(player) do
      local token = GetPlayerToken(player, i)
      if token ~= nil then
        local idx, value = token:match("^([^:]+):(.+)$")
        -- Token zero and one aren't reliable
        if idx ~= '0' and idx ~= '1' then
          identifiers[#identifiers + 1] = value
        end
      end
    end
    if not isTemporary then
      _identifierCache[player] = encode(identifiers)
    else
      return encode(identifiers)
    end
  end
  return _identifierCache[player]
end
exports('getAllPlayerIdentifiers', getAllPlayerIdentifiers)

local handlePlayer = function(netId, reason1, reason2, shouldBan)
  local log
  if type(netId) == 'number' and netId ~= 0 then
    local playerName = GetPlayerName(netId)

    if shouldBan and playerName then
      log = format(templates.log, 'Banned', playerName, reason2)
      local banId = uuid()
      local drop = format(templates.ban, reason1, banId)

      SetResourceKvp(format('vac_ban_%s', banId), getAllPlayerIdentifiers(false, netId))
      SetResourceKvp(format('vac_reason_%s', banId), drop)
      DropPlayer(netId, drop)
    else
      log = format(templates.log, 'Kicked', playerName, reason2)
      local drop = format(templates.kick, reason1)

      DropPlayer(netId, drop)
    end
  else
    return print('^1[ERROR] [Valkyrie]^7 Invalid NetId passed in function \'handlePlayer\'')
  end
  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, content = log}), { ['Content-Type'] = 'application/json' })
end
exports('handlePlayer', handlePlayer)
