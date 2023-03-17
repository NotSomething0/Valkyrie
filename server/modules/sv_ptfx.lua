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

local RESOURCE_NAME <const> = GetCurrentResourceName()

local prohibitParticles = false
local prohibitedParticles = {}

AddEventHandler('ptFxEvent', function(sender, data)
  if not prohibitParticles or IsPlayerAceAllowed(sender, 'vac:ptfx') then
    return
  end

  print(json.encode(data, {indent = true}))

  if prohibitedParticles[data.effectHash] then
    CancelEvent()
  end
end)

AddEventHandler('__vac_internel:initialize', function(module)
  if RESOURCE_NAME ~= GetInvokingResource() or module ~= 'all' and module ~= 'ptfx' then
    return
  end

  prohibitParticles = GetConvar('vac:ptfx:filter', 'false') == true and true or false

  if prohibitParticles then
    local particles = GetConvar('vac:ptfx:prohibited_particles', '[]')

    if not particles:find(']') then
      error('Unable to parse \'vac:ptfx:prohibited_particles\' check for proper syntax')
    end

    particles = json.decode(particles)

    table.clear(prohibitedParticles)

    for i = 1, #particles do
      local particle = GetHashKey(particles[i])

      prohibitedParticles[particle] = true
    end
  end

  log.info(('[PTFX]: Data synced | Prohibit Particles: %s'):format(prohibitParticles))
end)