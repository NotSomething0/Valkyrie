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
--logging function
function ValkyrieLog(title, message)
  local embed = {
    {
      ['title'] = 'Valkyrie: ' ..title.. '',
      ['type'] = 'rich',
      ['description'] = message,
      ['color'] = 732633,
      ['author'] = {['name'] = 'Valkyrie Anticheat', ['url'] = 'https://github.com/Something-Debug', ['icon_url'] = 'https://i.imgur.com/jmYn66H.png'},
      ['footer'] = {['text'] = 'Created by Something#6200 | ' ..os.date("%x (%X %p)"), ['icon_url'] = 'https://i.imgur.com/jmYn66H.png'},
    }
  }
  PerformHttpRequest('', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
--Kicking function
function ValkyrieKickPlayer(player, reason)
  if not player then
    return print('No source was set for kicking function this is a fatal error, players will not be kicked!')
  end
  if reason == nil or reason == '' then
    reason = 'No reason specified'
  end
  DropPlayer(player, 'Kicked \n You have been kicked for the following reason: ' ..reason..'. \n If you think this was a mistake contact us at ' ..GetConvar('contact', '').. '.')
end
--Check Permissions
function ProcessAces()
  if GetNumPlayerIndices() > 0 then -- don't do it when there aren't any players
      for i=0, GetNumPlayerIndices()-1 do -- loop through all players
          player = tonumber(GetPlayerFromIndex(i))
          Citizen.Wait(0)
          if IsPlayerAceAllowed(player, 'command') then
              TriggerClientEvent("checkAce", player, true)
          end
      end
  end
end
--Check Permissions on resource (re)start
AddEventHandler("onResourceStart", function(resource)
  if resource == GetCurrentResourceName() then
      ProcessAces()
      print('Permissions checked')
  end
end)
