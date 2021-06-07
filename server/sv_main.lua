-- Micro optimizations https://www.lua.org/gems/sample.pdf
local GetNumPlayerIndices = GetNumPlayerIndices
local GetPlayers = GetPlayers
local GetPlayerPed = GetPlayerPed
local GetEntityMaxHealth = GetEntityMaxHealth
local GetPlayerInvincible = GetPlayerInvincible
local IsPlayerAceAllowed = IsPlayerAceAllowed

local tracker = {}
local function setUpPlayer(playerId)
  local netId = tonumber(playerId)
  if netId then
    tracker[netId] = {strikes = 0, allowed = false}

    if IsPlayerAceAllowed(netId, 'vac.bypass') then
      tracker[netId].allowed = true
      TriggerClientEvent('vac_receive_permission', netId, true)
    else
      TriggerClientEvent('vac_receive_permission', netId, false)
    end
  end
end
RegisterNetEvent('vac_player_activated', function()
  setUpPlayer(source)
end)

CreateThread(function()
  while true do
    if next(GetPlayers()) ~= nil then
      for _, netId in pairs(GetPlayers()) do
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

          if tracker[source].strikes >= 5 then
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

CreateThread(function()
  ExecuteCommand('exec resources\\[local]\\Valkyrie\\valkyrie.cfg')
  TriggerEvent('vac_initalize_server', 'all')

  if next (GetPlayers()) then
    for _, playerId in pairs(GetPlayers()) do
      setUpPlayer(playerId)
    end
  end
end)

AddEventHandler('playerDropped', function()
  tracker[source] = nil
end)
