CreateThread(function()
    TriggerEvent('__valkyrie__internal', 'default')
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    -- PlayerId of the user connecting to the server.
    local playerId = source
    -- Prevent and defer connection right away.
    deferrals.defer()
    -- Mandatory wait
    Wait(0)
    --Info the user why their connection is being prevented.
    deferrals.update(string.format('Hello %s. Please wait while your identifiers are being checked.', name))
    -- Prefix of every ban placed by Valkyrie
    local banPrefix = 'valkyrie_ban_'
    local handle = StartFindKvp(banPrefix)
    local bans = {}
    -- Create infinite loop to get all banId's
    while true do
        -- Mandatory Wait
        Wait(0)
        -- BanId
        local key = FindKvp(handle)
        -- Check to see if there are more banId's to get.
        if key == nil then
            -- Break the loop because there are no more banId's.
            break
        else
            -- If there are still some then add them to the bans table.
            table.insert(bans, key)
        end
    end
    -- Stop looking for banId's
    EndFindKvp(handle)
    -- Check if the table is empty (will only happen if no one has ever been banned.)
    if next(bans) == nil then
        -- If the table is empty then let the user in because there are no bans
        deferrals.done()
    else
        -- Otherwise loop through all the banId's in the table
        for _, banId in ipairs(bans) do
            -- Check if the user connecting has any identifiers that match
            if GetResourceKvpString(banId):find(json.encode(GetPlayerIdentifiers(playerId))) then
                -- If they do then get their reason
                local reason = string.gsub(banId, 'ban', "reason")
                -- Don't let the user in with and provide the reason for blocking their connection.
                deferrals.done(GetResourceKvpString(reason))
            else
                -- Otherwise let the user in because they aren't banned.
                deferrals.done()
            end
        end
    end
end)