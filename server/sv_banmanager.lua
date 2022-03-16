local KVP_BAN_PREFIX <const> = 'vac_ban_%s'
local _CACHE = {
  identifiers = {},
  bans = {}
}
local is_cacheUpdated = false

-- Get a list of all current bans on the server
-- @return table
local function fetchBans()
  if (not is_cacheUpdated) then
    local handle = StartFindKvp(KVP_BAN_PREFIX)
    local bans = {}
    local key

    repeat
      key = FindKvp(handle)

      if (key) then
        bans[key] = json.decode(GetResourceKvpString(key))
      end
    until not key
    EndFindKvp(handle)

    _CACHE.bans = bans
    is_cacheUpdated = true
  end
  return _CACHE.bans
end

-- https://gist.github.com/jrus/3197011
local function uuid()
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

-- @param netId | string | player source
-- @param temp | bool | is player fully connected
-- @return table | player identifiers 
local function getIdentifiers(netId, temp)
  local t = {}

  if (tonumber(netId) >= 1 and not _CACHE.identifiers[netId]) then
    for _, v in pairs(GetPlayerIdentifiers(netId)) do
      local idx, value = v:match("^([^:]+):(.+)$")

      -- high variance/unreliable
      -- also prevents abuse by bad actors
      if (idx ~= 'ip') then
        t[idx] = value
      end
    end

    for _, v in pairs(GetPlayerTokens(netId)) do
      local idx, value = v:match("^([^:]+):(.+)$")

      -- unreliable multiple users can have the same first and second token
      if (idx ~= '0' and idx ~= '1') then
        t[#t + 1] = value
      end
    end

    -- if the player doesn't have a permanent netId
    -- don't populate the cache table as they might be dropped in connection
    if (not temp) then
      _CACHE.identifiers[netId] = msgpack.pack(t)
    else
      return t
    end
  end

  -- ensure the player is in our cache table before returning data
  -- otherwise return an empty table
  return (_CACHE.identifiers[netId] and msgpack.unpack(_CACHE.identifiers) or {})
end


-- @param netId | string | player source
-- @param duration | number | epoch
-- @param reason | string | reason  
function BanPlayer(netId, duration, reason)
  if (GetPlayerEndpoint(netId)) then
    local uuid = uuid()
    local ban = {
      id = uuid,
      -- if no time is passed default to one year 
      duration = (duration and duration + os.time() or 31536000 + os.time()),
      identifiers = getIdentifiers(netId, false),
      reason = reason or 'No reason specified'
    }

    SetResourceKvp(BAN_PREFIX:format(uuid), json.encode(ban))
    DropPlayer(netId, i18n.getTranslation('DROP_BANNED'):format(uuid, ban.duration, ban.reason))

    is_cacheUpdated = false
  end
end

local checkName = 0
local filterText = {}

local function onPlayerConnecting(name, skr)
  if (checkName == 1 and #filterText ~= 0) then
    local name = name:lower()
    local hits = {}

    for i = 1, #filterText do
      if (name:find(filterText[i]:lower())) then
        hits[i] = filterText[i]
      end
    end

    if (#hits ~= 0) then
      skr(('Your username contains blocked text ' ..json.encode(hits).. '\nremove these items then reconnect'))
    end
  else
    logger.verbose('Username filter disabled')
  end

  -- maybe use deferrals here?
  local banlist = fetchBans()
  local identifiers = getIdentifiers()

  for banId, data in pairs(banlist) do

    -- clean up expired bans
    if (data.duration - os.time() <= 0) then
      DeleteResourceKvp(banId)
      goto continue
    end

    for _, id in pairs(json.decode(data.identifiers)) do

      if (identifiers:find(id)) then
        local reason = data.reason
        skr(i18n.translate(i18n.lang, 'balh'))
        break
      end

    end

    ::continue::
  end
end
AddEventHandler('playerConnecting', onPlayerConnecting)