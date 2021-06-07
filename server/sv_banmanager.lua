--Micro optimization
--http://lua-users.org/wiki/OptimisingUsingLocalVariables
local seed, gsub, random, format = math.randomseed, string.gsub, math.random, string.format
local GetNumPlayerIdentifiers, GetPlayerIdentifier, GetNumPlayerTokens, GetPlayerToken = GetNumPlayerIdentifiers, GetPlayerIdentifier, GetNumPlayerTokens, GetPlayerToken
local encode, decode = json.encode, json.decode
local webhook = GetConvar('valkyrie_discord_webhook', '')
local contactLink = GetConvar('valkyrie_contact_link', '')
local templates = {
  ban = 'Banned\nYou have been banned from this server for %s.\nYour ban will expire on %s\nBanId %s\nThink this was a mistake? Contact us here '..contactLink,
  kick = 'Kicked\nYou have been kicked from this server for %s.\nThink this was a mistake? Contact us here '..contactLink,
  log = '**Valkyrie: %s**\nPlayer: %s\nReason: %s'
}

CreateThread(function()
  TriggerEvent('vac_initalize_server', 'all')
end)

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

local bansHaveChanged = true
local cachedBans = {}

-- @return table of all current bans
local function fetchBans()
  if bansHaveChanged then
    local handle = StartFindKvp('vac_ban_')
    local banIds = {}
    local key
    repeat
      key = FindKvp(handle)

      if key then
        banIds[key] = decode(GetResourceKvpString(key))
      end
    until not key
    EndFindKvp(handle)

    cachedBans = banIds
    return banIds
  else
    return cachedBans
  end
  bansHaveChanged = false
end

--@param netId number the player to ban
--@param reason string the reason for the players ban
--@param duration number the amount of time in epoch to be added to os.time()
local function ban(netId, reason, duration, discord)
    local log
    if type(netId) == 'number' and netId ~= 0 then
        local playerName = GetPlayerName(netId)
        if playerName then
            local uuid = uuid()
            -- 12/31/3000 23:59:59 PM
            local expires = 32535237599

            if type(duration) == 'number' and duration ~= 0 then
                expires = os.time() + duration
            end

            local ban = {
                id = uuid,
                expires = expires,
                identifiers = getAllPlayerIdentifiers(false, netId),
                reason = reason
            }

            SetResourceKvp(format('vac_ban_%s', uuid), encode(ban))
            DropPlayer(netId, format(templates.ban, reason, os.date('%c %p', expires), uuid))
            log = format(templates.log..'\nBanId: `%s`\nExpires at: `%s`', 'Banned', playerName, discord, uuid, os.date('%c %p', expires))
        else
            return
        end
    else
      return print('^1[ERROR] [Valkyrie]^7 Invalid netId passed in function \'ban\'')
    end
    bansHaveChanged = true
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', encode({username = name, content = log}), { ['Content-Type'] = 'application/json' })
end
exports('banPlayer', ban)

--@param netId number the player to ban
--@param reason string the reason kicking the player
local function kick(netId, reason, discord)
    local log
    if type(netId) == 'number' and netId ~= 0 then
        local playerName = GetPlayerName(netId)
        if playerName then
            log = format(templates.log, 'Kicked', playerName, discord)
            DropPlayer(netId, format(templates.kick, reason))
        else
            return
        end
      else
        return print('^1[ERROR] [Valkyrie]^7 Invalid netId passed in function \'kick\'')
    end
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', encode({username = name, content = log}), { ['Content-Type'] = 'application/json' })
end
exports('kickPlayer', kick)

AddEventHandler('playerConnecting', function(name, _, deferrals)
  local blockedNames = decode((GetConvar('valkyrie_blocked_names', '[]')))
  local _source = source

  deferrals.defer()

  Wait(0)

  deferrals.update(format('Hello %s, please wait while we check some information', name))

  for _, v in pairs(blockedNames) do
    if name:lower():find(v) then
      deferrals.done(format('Abuse Prevention\nYour username contains prohibited items(s)\nItem: %s\n Please remove the prohibited item then rejoin', v))
    end
  end

  local banList = fetchBans()

  local playerIdentifiers = getAllPlayerIdentifiers(true, _source)

  for banId, record in pairs(banList) do

    if record.expires - os.time() <= 0 then
      goto unban
    end

    for _, identifier in pairs(decode(record.identifiers)) do
      if playerIdentifiers:find(identifier) then
        local reason = record.reason
        return deferrals.done(format(templates.ban, reason, os.date('%c %p', record.expires), record.id))
      end
    end

    ::unban::
    DeleteResourceKvp(banId)
  end
  deferrals.done()
end)
