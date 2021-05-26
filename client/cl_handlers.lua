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

RegisterNetEvent('vac_clear_objects')
AddEventHandler('vac_clear_objects', function()
    local cObject = GetGamePool('CObject')
    for _, obj in pairs(cObject) do
        NetworkRequestControlOfEntity(obj)

        while not NetworkHasControlOfEntity(obj) do
            Wait(500)
        end
        DetachEntity(obj, 0, false)

        SetEntityCollision(object, false, false)
        SetEntityAlpha(obj, 0.0, true)
        SetEntityAsMissionEntity(obj, true, true)
        SetEntityAsNoLongerNeeded(obj)
        DeleteEntity(obj)
    end
end)

function notification(message)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(message)
	EndTextCommandThefeedPostTicker(true, false)
end

RegisterNetEvent('vac_notify_client')
AddEventHandler('vac_notify_client', function(message)
    notification(message)
end)
