--Thanks Puntherline for the whitelist portion of this code. 
Config = {}
Config.Whitelist = false                    --want to use whitelist?
Config.Users = {                            --any identifier will work but I recommend license
}

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)

  local player = source
  local identifiers = GetPlayerIdentifiers(source)
  local licenseIdentifier
  local allowed = false
  local newInfo = ""
  local oldInfo = ""
  --prevent connection right away
  deferrals.defer()
  deferrals.update(string.format('Hello %s please wait while your license ID is checked', name))
  
  --Mandatory wait
  Wait(0)

  if Config.Whitelist then
    for k1, v in pairs(identifiers) do
        for k2, i in ipairs(Config.Users) do
            if string.match(v, i) then
                allowed = true
                break
            end
        end
    end
  
    if allowed then
        deferrals.done()
    else
        for k1, v in pairs(identifiers) do
            oldInfo = newInfo
            newInfo = string.format("%s\n%s", oldInfo, v)
        end
        deferrals.done('You\'re not whitelisted join our discord for more information discord.gg/yeet')
    end
  end

  if not Config.Whitelist then 
    for k1, v in pairs(identifiers) do
      if string.find(v, 'license') then 
        licenseIdentifier = v
        break
      end
    end

    if not licenseIdentifier then
      deferrals.done('You\'re not connected to the rockstar services this is indicative of a fatal error.')
    else
      deferrals.done()
    end
  end
end)