-- Micro optimizations https://www.lua.org/gems/sample.pdf
local GetNumPlayerIndices = GetNumPlayerIndices
local GetPlayers = GetPlayers
local GetPlayerPed = GetPlayerPed
local GetEntityMaxHealth = GetEntityMaxHealth
local GetPlayerInvincible = GetPlayerInvincible
local IsPlayerAceAllowed = IsPlayerAceAllowed

local tracker = {}

RegisterNetEvent('vac_player_activated', function()
  tracker[source] = {strikes = 0, allowed = false}
  if IsPlayerAceAllowed(source, 'vac.bypass') then
    tracker[source].allowed = true
    TriggerClientEvent('vac_receive_permission', source, true)
  else
    TriggerClientEvent('vac_receive_permission', source, false)
  end
end)

CreateThread(function()
  while true do
    local players = GetPlayers()
    if next(players) ~= nil then
      for _, netId in pairs(players) do
        local source = tonumber(netId)
        if tracker[source] then
          local playerPed = GetPlayerPed(source)
          local allowed = tracker[source].allowed

          if GetPlayerInvincible(netId) and not allowed then
            tracker[netId].strikes = tracker[netId].strikes + 1
          end

          if GetEntityMaxHealth(playerPed) >= 201 then
            tracker[netId].strikes = tracker[netId].strikes + 1
          end

          if tracker[netId].strikes >= 5 then
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
