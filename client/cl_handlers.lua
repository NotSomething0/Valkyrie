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
        TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Blocked client event: `' ..eventName.. '`', 'Blocked event')
        Triggered = true
    end)
end

RegisterNetEvent('setPed')
AddEventHandler('setPed', function()
    local defaultPed = 'a_m_y_skater_01'
    RequestModel(defaultPed)
    while not HasModelLoaded(defaultPed) do
        Wait(500)
    end
    SetPlayerModel(PlayerId(), defaultPed)
    SetModelAsNoLongerNeeded(defaultPed)
    notification('Blacklisted Player Model')
end)

function notification(message)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(message)
	EndTextCommandThefeedPostTicker(true, false)
end

RegisterNetEvent('notify')
AddEventHandler('notify', function(message)
    notification(message)
end)

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
