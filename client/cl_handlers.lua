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
        TriggerServerEvent('Valkyrie:ClientDetection', 'Blocked client event: `' ..eventName.. '`', 'Blocked event', true)
        Triggered = true
    end)
end

RegisterNetEvent('Valkyrie:ClearObjects')
AddEventHandler('Valkyrie:ClearObjects', function()
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


RegisterNetEvent('Valkyrie:Blacklist:SetPlayerModel')
AddEventHandler('Valkyrie:Blacklist:SetPlayerModel', function()
    local defaultPed = `a_m_y_skater_01`
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
    TriggerServerEvent('Valkyrie:ClientDetection', 'Stopped resource: `' ..resource.. '`', 'Invalid resource list', false)
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
