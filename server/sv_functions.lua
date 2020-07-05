--Discord webhook
local webhook = GetConvar('webhooklink', '')
--Contact link
local contactlink = GetConvar('contact', '')
--Identifiers
function ValkyrieIdentifiers(player)
  for k, v in ipairs(GetPlayerIdentifiers(player)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif discord == nil or discord == '' then
      discord = 'Discord identifier not found'
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif steam == nil or steam == '' then
      steam = 'Steam identifier not found'
    end
  end
end
--logging function
function ValkyrieLog(title, message)
  local embed = {
    {
      ['title'] = 'Valkyrie: ' ..title.. '',
      ['type'] = 'rich',
      ['description'] = message,
      ['color'] = 732633,
      ['thumbnail'] = {['url'] = 'https://i.imgur.com/jmYn66H.png'},
      ['author'] = {['name'] = 'Valkyrie Anticheat', ['icon_url'] = 'https://i.imgur.com/jmYn66H.png'},
      ['footer'] = {['text'] = os.date("%x (%X %p)")},
    }
  }
  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
--Kicking function
function ValkyrieKickPlayer(player, reason)
  if player == nil then
    return 'No source was set for kicking function this is a fatal error, players will not be kicked!'
  end
  if reason == nil or reason == '' then
    return 'No reason was set for kicking function this is a fatal error, players will not be kicked!'
  end
  DropPlayer(player, 'Kicked \n You have been kicked for the following reason: ' ..reason..'. \n If you think this was a mistake contact us at ' ..contactlink.. '.')
end