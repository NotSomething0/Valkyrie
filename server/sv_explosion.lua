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

local format = string.format
local explosionLimit = 5
local explosionIndex = {}
local tracker = {}

AddEventHandler('explosionEvent', function(sender, ev)
  local sender = tonumber(sender)

  if explosionIndex[ev.explosionType] and ev.damageScale ~= 0.0 then
    CancelEvent()

    if tracker[sender] then
      tracker[sender] = tracker[sender] + 1
    else
      tracker[sender] = 1
    end

    if tracker[sender] >= explosionLimit then
      exports.Valkyrie:kickPlayer(sender, 'Blocked Explosion', format('Blocked Explosion | Count: %s', tracker[sender]))
    end
  end
end)

AddEventHandler('__vac_internel:intalizeServer', function(module)
  if module == 'explosion' or 'all' then

    for index in pairs(explosionIndex) do
      explosionIndex[index] = nil
    end

    for _, idx in pairs(json.decode(GetConvar('vac:explosion:allowedExp ', '[]'))) do
      explosionIndex[idx] = true
    end

    explosionLimit = GetConvarInt('vac:explosion:maxAllowedExp', 5)
  end
end)

AddEventHandler('playerDropped', function()
  tracker[source] = nil
end)
