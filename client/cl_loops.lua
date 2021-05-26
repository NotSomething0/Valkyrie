local PlayerPedId = PlayerPedId
local PlayerId = PlayerId
local GetPlayerName = GetPlayerName
local GetPlayerInvincible_2 = GetPlayerInvincible_2
local SetEntityHealth = SetEntityHealth
local GetEntityHealth = GetEntityHealth
local NetworkIsInSpectatorMode = NetworkIsInSpectatorMode
local GetEntityCoords = GetEntityCoords
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetVehicleTopSpeedModifier = GetVehicleTopSpeedModifier
local GetVehicleCheatPowerIncrease = GetVehicleCheatPowerIncrease

AddEventHandler('playerSpawned', function()
  TriggerServerEvent('vac_player_activated')
end)

permissions = nil
RegisterNetEvent('vac_receive_permission')
AddEventHandler('vac_receive_permission', function(hasPermission)
  if hasPermission then
    permissions = true
  else
    permissions = false
  end
end)

CreateThread(function()
  local strikes = 0
  local maxStrikes = GetConvarInt('valkyrie_maximum_godmode_strikes', 5)

  while permissions == nil do
    Wait(500)
  end

  if not permissions then

    while true do
      Wait(2500)
      local playerPed = PlayerPedId()

      if GetPlayerInvincible_2(playerPed) then
        TriggerServerEvent('vac_detection', 'GodMode', 'GodMode `GetPlayerInvincible_2()`', true)
      end

      local health = GetEntityHealth(playerPed)
      SetEntityHealth(playerPed, health - 2)
      Wait(math.random(0, 1000))

      if not IsPlayerDead(PlayerId()) then
        if GetEntityHealth(playerPed) == health and health ~= 0 then
          strikes = strikes + 1
        end
      end
      SetEntityHealth(playerPed, health + 2)

      if strikes >= maxStrikes then
        TriggerServerEvent('vac_detection', 'GodMode', 'GodMode `GetEntityHealth()`', true)
      end
    end
  end
  return print('^6[INFO] [VALKYRIE]^7 Terminated GodMode thread user ' ..GetPlayerName(PlayerId()).. ' has elevated permission.')
end)

CreateThread(function()
  local strikes = 0
  local maxStrikes = GetConvarInt('valkyrie_maximum_spectator_strikes', 5)
  local camDistance = GetConvarInt('valkyrie_maximum_cam_distance', 200)

  while permissions == nil do
    Wait(500)
  end

  if not permissions then
    while true do
      Wait(2500)

      local playerPed = PlayerPedId()

      if NetworkIsInSpectatorMode() then
        strikes = strikes + 1
      end

      local cam = #(GetEntityCoords(playerPed) - GetFinalRenderedCamCoord())

      if cam >= camDistance then
        strikes = strikes + 1
      end

      if strikes >= maxStrikes then
        TriggerServerEvent('vac_detection', 'Spectating', 'Spectating', true)
      end
    end
  end
  return print('^6[INFO] [VALKYRIE]^7 Terminated Spectator thread user ' ..GetPlayerName(PlayerId()).. ' has elevated permission.')
end)


CreateThread(function()
  local maxModifier = GetConvarInt('valkyrie_maximum_modifier', 2)

  while permissions == nil do
    Wait(500)
  end

  if not permissions then

    if maxModifier >= 2 then

      while true do
        Wait(2500)

        local playerPed = PlayerPedId()
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)

        if playerVehicle ~= 0 then
          if GetVehicleTopSpeedModifier(playerVehicle) > maxModifier then
            TriggerServerEvent('vac_detection', 'Speed Modifier', 'Exceeded maximum speed modifier', true)
          end

          if GetVehicleCheatPowerIncrease(playerVehicle) > maxModifier then
            TriggerServerEvent('vac_detection', 'Speed Modifier', 'Exceeded maximum speed modifier', true)
          end
        end
      end
      return print('^6[INFO] [VALKYRIE]^7 Terminated Speed Modifier Thread improper configuration, MaximumSpeedModifier cannot be less than or equal to one.')
    end
  end
  return print('^6[INFO] [VALKYRIE]^7 Terminated Speed Modifier thread user ' ..GetPlayerName(PlayerId()).. ' has elevated permission.')
end)
