-- Function for getting a users identifier.
function ValkyrieIdentifiers(player)
  local identifiers = {}
  for i = 0, GetNumPlayerIdentifiers(player) - 1 do
      local raw = GetPlayerIdentifier(player, i)
      local source, value = raw:match("^([^:]+):(.+)$")
      if source and value then
          identifiers[source] = value
      end
  end
  return identifiers
end
-- Function for generating a banid (taken from https://gist.github.com/skeeto/c61167ff0ee1d0581ad60d75076de62f)
local random = math.random
local function uuid()
  -- Template for the banId
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  -- Replace template only x and y with random letters/numbers from the function.
  return string.gsub(template, '[xy]', function (c)
    -- Generate random letters/numbers
    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
    -- Return the banId as a formated string.
    return string.format('%x', v)
  end)
end
-- Function for logging actions to discord.
function ValkyrieLog(title, message)
  local banId = uuid()
  if title == 'Player Banned' then message = message..'\n**BanId:** ' ..banId end
  local embed = {
    {
      ['title'] = 'Valkyrie: ' ..title,
      ['type'] = 'rich',
      ['description'] = message,
      ['color'] = 732633,
      ['author'] = {['name'] = 'Valkyrie Anticheat', ['url'] = 'https://github.com/NotSomething0', ['icon_url'] = 'https://i.imgur.com/jmYn66H.png'},
      ['footer'] = {['text'] = 'Created by NotSomething#6200 | ' ..os.date("%x (%X %p)"), ['icon_url'] = 'https://i.imgur.com/jmYn66H.png'},
    }
  }
  PerformHttpRequest(Config.discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
-- Function for kicking users from the server.
function ValkyrieKickPlayer(player, dropReason, discordReason)
  -- Check if a playerId was given
  if player == nil then
    -- If none was given then exit with a fatal error because we can't kick without a playerId.
    return print('^8[Valkyrie] Fatal Error: ^3No PlayerId (source) passed for kicking function.^7')
  end
  -- Name of the user being kicked.
  local playerName = GetPlayerName(player)
  -- License of the player being kicked.
  local license = ValkyrieIdentifiers(player).license
  -- If no license is found then exit.
  if license == nil then return end
  -- If no reason was given then set the reason to unspecified.
  if dropReason == nil then dropReason = 'No reason provided' end
  -- Disconnect the user with their kick reason.
  DropPlayer(player, 'Kicked \n You have been kicked for the following reason: ' ..dropReason..'. \n If you think this was a mistake contact us at ' ..Config.contactLink)
  ValkyrieLog('Kicked', '**Player:** ' ..playerName.. '\n**Reason:** ' ..discordReason.. '\n**license:** ' ..license)
end
-- Function for banning users from the server.
function ValkyrieBanPlayer(playerId, dropReason, discordReason)
  -- Check if a playerId was given
  if playerId == nil then
    -- If none was given then exit with a fatal error because we can't ban without a playerId.
    return print('^8[FATAL] [Valkyrie]^7 No PlayerId passed for banning function.')
  end
  -- Name of the user being banned.
  local playerName = GetPlayerName(playerId)
  -- Check if the player name exists
  if playerName == nil then
    -- Exit because the name doesn't exist (the player was dropped from the server already.)
    return
  end
  local banId = uuid()
  -- If no reason was given then set the reason to unspecified.
  if dropReason == nil then dropReason = 'No Reason specified' end
  -- Prefix of every ban placed by Valkyrie
  local banPrefix = 'valkyrie_ban_'
  -- Prefix of every ban reason
  local reasonPrefix = 'valkyrie_reason_'
  -- The reason for the ban
  local banReason = 'Banned \n You have been banned for the following reason: ' ..dropReason.. ' \n If you think this was a mistake contact us at ' ..Config.contactLink.. ' \n Ban Id ' ..banId
  -- Store indetifiers in the database
  SetResourceKvp(banPrefix..banId, json.encode(GetPlayerIdentifiers(playerId)))
  -- Store the reason in the database
  SetResourceKvp(reasonPrefix..banId, banReason)
  -- Disconnect the user with thier ban reason.
  DropPlayer(playerId, banReason)
  ValkyrieLog('Banned', '**Player:** ' ..playerName.. '\n**Reason:** ' ..discordReason.. '\n**BanId:** ' ..banId)
end




local ban_prefix = 'vac_ban_'
local reason_prefix = 'vac_reason_'
local contactlink = GetConvar('ContactLink', '')

function vacBan(playerId, reason)
  local banId = uuid()
  if playerId ~= nil then
    SetResourceKvp(string.format('%s%s', ban_prefix, banId), json.encode(GetPlayerIdentifiers(playerId)))
    SetResourceKvp(string.format('%s%s', reason_prefix, banId), reason)
    DropPlayer(playerId, reason)
  else
    return print('^1[WARN] [VALKYRIE]^7 No PlayerId passed for banning function.')
  end
end