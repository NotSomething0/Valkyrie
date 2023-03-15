-- Copyright (C) 2019 - 2023  NotSomething

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
local RELOAD_CONFIG_COMMAND <const> = string.format('exec @%s/config.cfg', RESOURCE_NAME)
local RELOAD_PERMISSION_COMMAND <const> = string.format('exec @%s/permission.cfg', RESOURCE_NAME)
local RELOADABLE_MODULES <const> = {
  ['all'] = true,
  ['entity'] = true,
  ['explosion'] = true,
  ['chat'] = true,
  ['ptfx'] = true,
  ['permission'] = true
}
local REQUESTABLE_PERMISSION <const> = {
  ['explosion'] = 'vac:explosion',
  ['particle'] = 'vac:particle',
}

-- Reload the specified module and appropriate config file
-- @param module | string | module to reload
local function reloadModule(module)
  if module == 'permission' then
    ExecuteCommand(RELOAD_PERMISSION_COMMAND)
    return
  end

  ExecuteCommand(RELOAD_CONFIG_COMMAND)
  TriggerEvent('__vac_internel:initialize', module)
end

RegisterCommand('vac:sync', function(source, args)
  local module = args[1]

  if not RELOADABLE_MODULES[module] then
    AddMessage(source, ('Invalid argument specified, %s is not a valid module'):format(module))
    return
  end

  reloadModule(module)
  log.info(('[COMMAND]: %s has just reloaded module %s'):format(source == 0 and 'console' or GetPlayerName(source), module))
end, true)

RegisterCommand('vac:unban', function(source, args)
  local key = ('vac_ban_%s'):format(args[1])
  local reason = args[2] or 'No reason specified'

  if not GetResourceKvpString(key) then
    AddMessage(('Cannot find entry for ban ID %s, are you sure this is a valid ban?'):format(key))
    return
  end

  DeleteResourceKvp(key)
  AddMessage(source, 'Success revoked ban ID %s ' .. args[1])


  log.info(('[CMD]: Ban ID %s revoked by %s'):format(key, source == 0 and 'console' or GetPlayerName(source)))
  --TriggerEvent('__vac_internel:banRevoked', key:find(key, '.*', 9), reason)
end, true)

local function clearVehicles()
  local vehicles = GetAllVehicles()
  local players = GetPlayers()
  local playerVehicles = {}

  for _, netId in pairs(players) do
    local playerPed = GetPlayerPed(netId)
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    if (playerVehicle ~= 0) then
      playerVehicles[playerVehicle] = true
    end
  end

  for _, vehicle in pairs (vehicles) do
    if (not playerVehicles[vehicle]) then
      DeleteEntity(vehicle)
    end
  end
end

local function clearPeds()
  local peds = GetAllPeds()
  local vehicles = {}

  for _, ped in pairs(peds) do
    local pedVehicle = GetVehiclePedIsIn(ped, false)

    if (not IsPedAPlayer(ped) and pedVehicle ~= 0 and not vehicles[pedVehicle]) then
      vehicles[pedVehicle] = true
    end

    DeleteEntity(ped)
  end

  for vehicle in pairs(vehicles) do
    DeleteEntity(vehicle)
  end
end

local function clearObjects()
  local objects = GetAllObjects()

  for i = 1, #objects do
    local object = objects[i]

    DeleteEntity(object)
  end

  log.info(('[COMMAND]: %s has just cleared %s'):format(name, action))
end

RegisterCommand('vac:clear', function(source, args)
  local name = source == 0 and 'console' or GetPlayerName(source)
  local action = args[1]:sub(1, 1):lower()

  if action == 'c' then
    TriggerClientEvent('chat:clear', -1)
    return
  end

  if action == 'o' then
    clearObjects()
    return
  end

  if action == 'p' then
    clearPeds()
    return
  end

  if action == 'v' then
    clearVehicles()
    return
  end

  AddMessage(('%s is not a valid action please try again'):format(action))
  log.info(('[COMMAND]: %s has just cleared %s'):format(name, action))
end, true)

local RequestQueue = VCache:new('any', 'any')

RegisterCommand('vac:request', function(source, args)
  if source == 0 then
    AddMessage(source, 'You\'re the console you already have all permissions!')
    return
  end

  if not GetConvarBool('vac:cmd:request_permission', false) then
    AddMessage(source, 'Permission requests are disabled, ask your administrators to enable them.')
    return
  end

  local requestedPermission = REQUESTABLE_PERMISSION[args[1]]

  if not requestedPermission then
    AddMessage(source, ('%s is not a requestable permission, please try again.'):format(args[1]))
    return
  end

  RequestQueue:set(source, requestedPermission)

  for netId in pairs(PlayerCache()) do
    if IsPlayerAceAllowed(netId, 'vac:admin') then
      -- TODO: Tell admins they have a new permission request
      -- %s(%s) has requested the permission %s, please approve or deny this request.
      AddMessage(netId, ('%s(%s) has just requested permission for %s, please approve or deny this request.'):format(GetPlayerName(source), source))
    end
  end

  AddMessage(source, 'Request submitted! If any staff members are online they can approve or deny your request.')
end, true)

RegisterCommand('vac:permission', function(source, args)
  if not GetConvarBool('vac:cmd:request_permission', false) then
    AddMessage(source, 'Permission requests are disabled, ask your administrators to enable them.')
    return
  end

  local target = args[1]
  local action = args[2]

  if not target or tonumber(target) < 1 or not GetPlayerEndpoint(target) then
    -- TODO: Inform admin this is an invalid user
    -- Target invalid please specify an online player
  end

  if action ~= 'approve' and action ~= 'deny' then
    return
  end

  --if action == 'approve' and PlayerCache(target):addPermission() then
  --end

  --if action == 'remove' and PlayerCache(target):removePermission() then
  --end
end, true)