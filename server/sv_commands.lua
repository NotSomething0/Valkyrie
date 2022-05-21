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
local modules = {
  ['entities'] = 'entities',
  ['explosion'] = 'explosion',
  ['chat'] = 'chat',
  ['ptfx'] = 'ptfx'
} 

RegisterCommand('reload', function(source, args)
  if (tonumber(source) ~= 0) then
    TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {'Valkyrie', 'Unable to use command, console access required'}})
    return
  end

  local module = modules[args[1]] or 'all'
  local conf = string.format('exec @%s/valkyrie.cfg', RESOURCE_NAME)
  local perm = string.format('exec @%s/vac_permissions.cfg', RESOURCE_NAME)
 
  ExecuteCommand(perm)
  ExecuteCommand(conf)
  
  TriggerEvent('__vac_internel:intalizeServer', module)

  log.info(string.format('Successfully reloaded module %s and permissions', module))
end, true)


RegisterCommand('unban', function(source, args)
  if (source ~= 0) then
    TriggerClientEvent('chat:addMessage', source, {color = {255, 0, 0}, args = {'Valkyrie', 'Unable to use command, console access required'}})
    return
  end

  local data = GetResourceKvpString(string.format('vac_ban_%s', args[1]))
  local reason = 'No reason specified'

  if (data) then
    -- check if a reason was provided
    if (args[2]) then
      table.remove(args, 1)
      reason = table.concat(args, " ")
    end

    DeleteResourceKvp(string.format('vac_ban_%s', args[1]))
    
    log.info(string.format('Sucsesfully deleted Ban Id: %s with Reason: %s', args[1], reason))
  else
    log.warn(string.format('Unable to find Ban Id: %s are you sure this is a valid ban?', args[1]))
  end

  TriggerEvent('__vac_internal:playerUnbanned')
end, true)