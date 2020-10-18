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

function ValkyrieLog(title, message)
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
  PerformHttpRequest(Config.DiscWebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function ValkyrieKickPlayer(player, reason)
  if not player then
    return print('No source was set for kicking function this is a fatal error, players will not be kicked!')
  end

  if not reason or reason == '' then
    reason = 'No reason specified'
  end
  
  DropPlayer(player, 'Kicked \n You have been kicked for the following reason: ' ..reason..'. \n If you think this was a mistake contact us at ' ..Config.Contactlink)
end

function ValkyrieBanPlayer(player, reason)
  if not player then
    return print('No source was set for banning function this is a fatal error, players will not be banned.')
  end

  local license = ValkyrieIdentifiers(player).license

  if not license then return end

  if not reason or reason == '' then
    reason = 'No reason specified'
  end

  SetResourceKvp(license, 'Banned \n You have been banned for the following reason: ' ..reason.. '. \n If you think this was a mistake contact us at ' ..Config.Contactlink.. '\n License: ' ..license)
  DropPlayer(player, 'Banned \n You have been banned for the following reason: ' ..reason.. '. \n If you think this was a mistake contact us at ' ..Config.Contactlink.. '\n License: ' ..license)
end

function ProcessAces()
  if GetNumPlayerIndices() > 0 then
      for i=0, GetNumPlayerIndices()-1 do
          player = tonumber(GetPlayerFromIndex(i))
          Citizen.Wait(0)
          if IsPlayerAceAllowed(player, 'command') then
              TriggerClientEvent("checkAce", player, true)
          end
      end
  end
end

AddEventHandler("onResourceStart", function(resource)
  if resource == GetCurrentResourceName() then
      ProcessAces()
  end
end)