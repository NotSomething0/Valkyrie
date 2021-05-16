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
local banTemplate = GetConvar("valkyrie_ban_message", "Automatically banned")
local kickTemplate = GetConvar("valkyrie_kick_message", "Automatically kicked")

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

local logTemplate = '**Valkyrie: %s**\nPlayer: %s\nReason: %s'
local handlePlayer = function(netId, dropReason, logReason, shouldBan)
  local banId = uuid()
  if not netId or netId == 0 or type(netId) ~= 'number' then
    return print('^1[ERROR] [Valkyrie]^7 Invalid NetId passed in function \'handlePlayer\'')
  else
    local playerName = GetPlayerName(netId)
    if playerName and shouldBan then
      log = format('**Valkyrie: %s**\nPlayer: %s\nReason: %s', 'Banned', playerName, logReason)
      dropMessage = format(banTemplate, dropReason, banId)

      SetResourceKvp(format('vac_ban_%s', banId), getAllPlayerIdentifiers(false, netId))
      SetResourceKvp(format('vac_reason_%s', banId), dropMessage)
      DropPlayer(netId, dropMessage)
    else
      if playerName and not shouldBan then
        log = format('**Valkyrie: %s**\nPlayer: %s\nReason: %s', 'Kicked', playerName, logReason)
        DropPlayer(netId, format(kickTemplate, dropReason))
      end
    end
  end
  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, content = log}), { ['Content-Type'] = 'application/json' })
end
exports('handlePlayer', handlePlayer)
