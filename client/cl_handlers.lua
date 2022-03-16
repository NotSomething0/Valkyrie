local format = string.format

local _blockedClientEvents = {
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

local Triggered = false

for _, eventName in pairs(_blockedClientEvents) do
    AddEventHandler(eventName, function()
        if Triggered == true then
            CancelEvent()
            return
        end
        TriggerServerEvent('vac_detection', 'Blocked Event', format('Blocked Event `%s`', eventName), true)
        Triggered = true
    end)
end
