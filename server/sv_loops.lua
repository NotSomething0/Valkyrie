-- Micro optimizations https://www.lua.org/gems/sample.pdf
local GetNumPlayerIndices = GetNumPlayerIndices
local GetPlayers = GetPlayers
local GetPlayerPed = GetPlayerPed
local GetEntityMaxHealth = GetEntityMaxHealth
local GetPlayerInvincible = GetPlayerInvincible
local IsPlayerAceAllowed = IsPlayerAceAllowed

local tracker = {}

AddEventHandler('playerJoining', function()
  tracker[source] = {strikes = 0, allowed = false, activated = false}
end)

RegisterNetEvent('vac_player_activated', function()
  if IsPlayerAceAllowed(source, 'vac.bypass') then
    tracker[source].allowed = true
    TriggerClientEvent('vac_receive_permission', source, true)
  else
    TriggerClientEvent('vac_receive_permission', source, false)
  end
  tracker[source].activated = true
end)

CreateThread(function()
  while true do
    if GetNumPlayerIndices() > 0 then
      for _, player in pairs(GetPlayers()) do
        local netId = tonumber(player)
        if tracker[netId] then
          local playerPed = GetPlayerPed(netId)
          local allowed = tracker[netId].allowed
          local activated = tracker[netId].activated

          if GetPlayerInvincible(netId) and not allowed and activated then
            tracker[netId].strikes = tracker[netId].strikes + 1
          end

          if GetEntityMaxHealth(playerPed) >= 201 and not allowed and activated then
            tracker[netId].strikes = tracker[netId].strikes + 1
          end

          if tracker[netId] and tracker[netId].strikes >= 5 then
            exports.Valkyrie:handlePlayer(netId, 'Maxium strikes', 'Exceeded maximum tracker strikes', true)
          end
        end
        Wait(750)
      end
    else
      Wait(5000)
    end
    Wait(0)
  end
end)

AddEventHandler('playerDropped', function()
  tracker[source] = nil
end)
