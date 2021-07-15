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

local function clearObjects()
  local objects = GetGamePool('CObject')
  for i = 1, #objects do

    local handle = objects[i]

    repeat
      NetworkRequestControlOfEntity(handle)
    until NetworkHasControlOfEntity(handle)

    if IsEntityAttached(handle) then
      DetachEntity(handle, false, false)
    end

    DeleteEntity(handle)
  end
end

RegisterNetEvent('vac_clear_objects', clearObjects)
