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
local BAN_PREFIX <const> = 'vac_ban_%s'
local modules = {
  ['entities'] = true,
  ['explosion'] = true,
  ['chat'] = true,
  ['ptfx'] = true
} 

RegisterCommand('reload', function(source, args)
  if (tonumber(source) ~= 0) then
    log.warn('unable to use reload command, console access is required', false)
    return
  end

  local module = args[1] and modules[args[1]] or 'all'
  local cmd = string.format('exec @%s/valkyrie.cfg', RESOURCE_NAME)

  ExecuteCommand(cmd)
  TriggerEvent('__vac_internel:intalizeServer', module)
end, true)

local webhook = GetConvar("vac:internel:discoWebhook", "")


RegisterCommand('unban', function(source, args)
  if (source ~= 0) then
    log.warn('unable to preform action, console access is required!')
    return
  end

  local banId = args[1] and GetResourceKvpString(BAN_PREFIX:format(args[1]))
  local reason = 'No reason specified'

  if (banId) then
    -- check if a reason was provided
    if (args[2]) then
      table.remove(args, 1)
      reason = table.concat(args, " ")
    end

    DeleteResourceKvp(BAN_PREFIX:format(banId))
    
    log.trace('Sucsesfully deleted banId: %s', true)  
  else
    log.error('unable to find banId: are you sure this is a valid ban?', false)
  end
end, true)