--Discord webhook
local webhook = GetConvar('webhooklink', '')
--Contact link
local contactlink = GetConvar('contact', '')
--Error Logging
function ValkyrieError(message)
  local source = source
  local embed = {
    {
      ['color'] = 15007744,
      ['title'] = 'Valkyrie Error',
      ['description'] = message,
      ['footer'] = {
        ['text'] = 'Valkyrie Anticheat',
      },
    }
  }
  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
--Identifiers
function ValkyrieIdentifiers(player)
  for k, v in ipairs(GetPlayerIdentifiers(player)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif discord == nil or discord == '' then
      discord = 'Discord identifier not found.'
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif steam == nil or steam == '' then
      steam = 'Steam identifier not found.'
    end
  end
end
--Kick logging
function ValkyrieLog(message)
  local source = source
  local embed = {
    {
      ['color'] = 1,
      ['title'] = 'Valkyrie',
      ['description'] = message,
      ['footer'] = {
        ['text'] = 'Valkyrie Anticheat',
      },
    }
  }
  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
--Kicking function
function ValkyrieKickPlayer(player, reason)
  if player == nil then
    return
    ValkyrieError('No source was set for kicking function this is a fatal error, players will not be kicked!')
  end
  if reason == nil or reason == '' then
    return
    ValkyrieError('No reason was set for kicking function this is a fatal error, players will not be kicked!')
  end
  DropPlayer(player, 'Kicked \n You have been kicked for the following reason: ' ..reason..'. \n If you think this was a mistake contact us at ' ..contactlink.. '.')
end