
local Triggered = false
for _, eventName in ipairs(Config.BlockedClientEvent) do
    AddEventHandler(eventName, function()
        if Triggered == true then
            CancelEvent()
            return
        end
        TriggerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Blocked event: ' ..eventName.. '', 'Blocked event')
        Triggered = true
    end)
end
AddEventHandler('onClientResourceStop', function(resource)
    TriggerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Stopped resource: `' ..resource.. '`', 'Invalid resource list')
end)

AddEventHandler('onClientMapStart', function()
TriggerEvent('chat:addSuggestion', '/kick', 'Kick specified player with optional reason', {
    { name = 'Player ID', help = 'Player Server ID' },
    { name = 'reason', help = 'Reason for kick'}
})
TriggerEvent('chat:addSuggestion', '/freeze', 'Freeze specified player', {
    { name = 'Player ID', help = 'Player Server ID'}
})
end)
