--[[
    Valkyrie Anticheat
]]
AddEventHandler('Valkyrie:ClientDetection', function(user, log, reason)
    TriggerServerEvent('Valkyrie:ClientDetection', user, log, reason)
end)
--List of blocked client events.
local _blockedClientEvents ={
    "ambulancier:selfRespawn",
    "bank:transfer",
    "esx_ambulancejob:revive",
    "esx-qalle-jail:openJailMenu",
    "esx_jailer:wysylandoo",
    "esx_society:openBossMenu",
    "esx:spawnVehicle",
    "esx_status:set",
    "HCheat:TempDisableDetection",
    "UnJP"
}
--Handler and iterator for the above blocked client events. 
local Triggered = false
for k, eventName in ipairs(_blockedClientEvents) do
    AddEventHandler(eventName, function()
        if Triggered == true then
            CancelEvent()
            return
        end
        TriggerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Was kicked for triggering a blocked client event ' ..eventName.. '', 'Blocked event: ' ..eventName.. '')
        Triggered = true
    end)
end
AddEventHandler('onClientResourceStop', function(resource)
    TriggerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Was kicked for stopping a resource on their client ' ..resource.. '', 'Stopped resource: ' ..resource.. '')
end)