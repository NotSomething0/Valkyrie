local Whitelist = false
local Whitelisted = {
  ''
}

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
  local license = ValkyrieIdentifiers(source).license

  deferrals.defer()
  deferrals.update('Hello ' ..playerName.. ' please wait while your identifiers are checked')

  Wait(0)

  if not license then
    return deferrals.done('Unable to find license identifier, is sv_lan set?')
  end
  
  if Whitelist then
    for _, id in pairs(Whitelisted) do
      if string.match(license, id) then
        deferrals.done()
      else
        deferrals.done('You\'re not whitelisted')
      end
    end
  else 
    deferrals.done()
  end
end)
