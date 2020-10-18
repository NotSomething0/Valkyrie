AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    -- Id of the player connecting
    local player = source
    -- License of the player connecting
    local license = ValkyrieIdentifiers(player).license
    -- defer connection right away.
    deferrals.defer()
    -- Mandatory wait
    Wait(0)
    -- Let the player know what is going on.
    deferrals.update(string.format("Hello %s. Your license ID is being checked.", name))
    -- If no license is found prevent them from connecting.
    if not license then
        return deferrals.done('No license id found is sv_lan set?')
    end
    -- If a banned license is found prevent the player from connecting and let them know what's happening
    if GetResourceKvpString(license) then
        deferrals.done(GetResourceKvpString(license))
    else
        deferrals.done() -- If there license isn't banned let them in.
    end
end)