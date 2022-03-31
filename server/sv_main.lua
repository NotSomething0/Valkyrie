-- Copyright (C) 2019 - 2022  NotSomething

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Micro optimizations https://www.lua.org/gems/sample.pdf
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

AddEventHandler('onResourceStart', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  local players = GetPlayers()

  if next(players) then
    for i = 1, #players do
      setUpPlayer(tonumber(players[i]))
    end
  end

  TriggerEvent('__vac_internel:intalizeServer', 'all')
end)

AddEventHandler('playerDropped', function()
  tracker[source] = nil
end)