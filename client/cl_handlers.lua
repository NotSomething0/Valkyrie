--[[
    Valkyrie Anticheat
]]
AddEventHandler('Valkyrie:ClientDetection', function(reason)
    TriggerServerEvent('Valkyrie:ClientDetection', reason)
end)

--Name of resource to parse through
local resourceList = {
    'mapmanager',
    'chat',
    'spawnmanager',
    'sessionmanager',
    'fivem',
    'hardcap',
    'rconlog',
    'vMenu'
}
--Handler and iterator for the above 
for k, listNames in ipairs(resourceList) do
    AddEventHandler('onClientResourceStop', function(resourceName)
        if resourceName == GetCurrentResourceName() or resourceName == resourceList then
            --TriggerServerEvent('Valkyrie: Detection', 'Stopped Resource')
        end
    end)
end
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
        TriggerEvent('Valkyrie:ClientDetection')
        Triggered = true
    end)
end