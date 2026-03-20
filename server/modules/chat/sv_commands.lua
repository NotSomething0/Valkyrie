-- Copyright (C) 2019 - 2026  NotSomething

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

local CURRENT_RESOURCE_NAME <const> = GetCurrentResourceName()
local RELOAD_CONFIG <const> = string.format('exec @%s/config.cfg', CURRENT_RESOURCE_NAME)
local RELOAD_PERMISSION <const> = string.format('exec @%s/permission.cfg', CURRENT_RESOURCE_NAME)
local REQUEST_QUEUE <const> = CCache.new('number', 'string')
local RELOADABLE_MODULES <const> = {
  ['all'] = true,
  ['logger'] = true,
  ['entity'] = true,
  ['explosion'] = true,
  ['chat'] = true,
  ['ptfx'] = true,
  ['permission'] = true
}
local CLEAR_ACTIONS <const> = {
  chat = 'chat',
  objects = 'objects',
  peds = 'peds',
  vehicles = 'vehicles'
}

local function clearVehicles()
  local vehicles = GetAllVehicles()
  local players = GetPlayers()
  local playerVehicles = {}

  for i = 1, #players do
    local player = players[i]
    local playerPed = GetPlayerPed(player)
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)

    if playerVehicle ~= 0 then
      playerVehicles[playerVehicle] = true
    end
  end

  for i = 1, #vehicles do
    local vehicle = vehicles[i]

    if not playerVehicles[vehicle] then
      DeleteEntity(vehicle)
    end
  end
end

local function clearPeds()
  local peds = GetAllPeds()
  local vehicles = {}

  for i = 1, #peds do
    local ped = peds[i]
    local pedVehicle = GetVehiclePedIsIn(ped, false)

    if not IsPedAPlayer(ped) and pedVehicle ~= 0 and not vehicles[pedVehicle] then
      vehicles[pedVehicle] = true
    end

    DeleteEntity(ped)
  end

  for i = 1, #vehicles do
    local vehicle = vehicles[i]

    DeleteEntity(vehicle)
  end
end

local function clearObjects()
  local objects = GetAllObjects()

  for i = 1, #objects do
    local object = objects[i]

    DeleteEntity(object)
  end
end

---Check if the specified module exists
---@param module string
---@return boolean exists
local function doesModuleExist(module)
  return RELOADABLE_MODULES[module] == true
end

RegisterCommand('vac:sync', function(source, args)
  local MODULE <const> = args[1]

  if not doesModuleExist(MODULE) then
    Citizen.Trace(('Invalid module specified %s is not a reloadable module\n'):format(MODULE))
    return
  end

  if MODULE == 'permission' then
    ExecuteCommand(RELOAD_PERMISSION)
  end

  if MODULE ~= 'permission' then
    ExecuteCommand(RELOAD_CONFIG)
    TriggerEvent('vac:internal:sync', MODULE)
  end

  logger:info(('[COMMAND]: %s has just reloaded the %s module(s)'):format(GetSenderName(source), MODULE))
end, true)

RegisterCommand('vac:unban', function(source, args)
  local SENDER_NAME <const> = GetSenderName(source)
  local BAN_ID <const> = args[1]
  local REASON <const> = args[2]

  if not BAN_ID then
    Citizen.Trace(('Invalid argument at index #1 you must specifiy a banID to revoke.\n'))
    return
  end

  if not REASON then
    Citizen.Trace(('Invalid argument at index #2 you must specifiy a reason for revoking this ban.\n'))
    return
  end

  TriggerEvent('vac:internal:revokeBan', BAN_ID, ('Manually revoked by %s for %s'):format(SENDER_NAME, REASON))
end, true)

RegisterCommand('vac:clear', function(source, args)
  local SENDER_NAME <const> = GetSenderName(source)
  local CLEAR_ACTION <const> = CLEAR_ACTIONS[args[1]]

  if not CLEAR_ACTION then
    Citizen.Trace('Invalid argument at index #1 \'action\' must be \'chat\', \'objects\', \'peds\' or \'vehicles\'.\n')
    return
  end

  if CLEAR_ACTION == 'chat' then
    TriggerClientEvent('chat:clear', -1)
  end

  if CLEAR_ACTION == 'objects' then
    clearObjects()
  end

  if CLEAR_ACTION == 'peds' then
    clearPeds()
  end

  if CLEAR_ACTION == 'vehicles' then
    clearVehicles()
  end

  logger:info(('[COMMAND]: %s has just cleared %s'):format(SENDER_NAME, CLEAR_ACTION))
end, true)

RegisterCommand('vac:request', function(source, args)
  if source == 0 then
    Citizen.Trace('You\'re the console you already have all permissions!\n')
    return
  end

  if not GetConvarBool('vac:command:allowPermissionRequests', false) then
    exports.chat:addMessage(source, {
      color = {255, 0, 0},
      args = {'Valkyrie', 'Permission requests are disabled, ask your administrators to enable them.'}
    })
    return
  end

  local PERMISSION <const> = args[1]

  ---@TODO: We should inform of the list of available permissions
  if not exports.Valkyrie:doesPermissionExist(PERMISSION) then
    exports.chat:addMessage(source, {
      color = {255, 0, 0},
      args = {'Valkyrie', ('Permission %s is not a requestable permission.'):format(PERMISSION)},
      multiline = false
    })
    return
  end

  REQUEST_QUEUE:set(source, PERMISSION)

  local players = GetPlayers()

  for index = 1, #players do
    local playerIndex = players[index]

    if IsPlayerAceAllowed(playerIndex, 'vac:admin') then
      exports.chat:addMessage(source, {
        color = {255, 0, 0},
        args = {'Valkyrie', ('%s(%s) has just requested permission for %s, please approve or deny this request.'):format(GetPlayerName(source), source, PERMISSION)}
      })
    end
  end

  exports.chat:addMessage(source, {
    color = {255, 0, 0},
    args = {'Valkyrie', 'Request submitted! If any staff members are online they can approve or deny your request.'}
  })
end, true)

local PERMISSION_ACTIONS <const> = {
  ['grant'] = true,
  ['approve'] = true,
  ['revoke'] = true,
  ['deny'] = true
}

---commen
---@param action string
---@return boolean exists
local function doesPermissionActionExist(action)
  return PERMISSION_ACTIONS[action]
end

RegisterCommand('vac:permission', function(source, args)
  if not GetConvarBool('vac:command:allowPermissionRequests', false) then
    Citizen.Trace('Permission requests are disabled, ask your administrators to enable them.\n')
    return
  end

  local ACTION <const> = args[1]
  local TARGET <const> = args[2]

  if not doesPermissionActionExist(ACTION) then
    Citizen.Trace('Invalid argument specified at index #1 \'action\' must be \'grant\', \'approve\', \'revoke\' or \'deny\'.')
    return
  end

  if not DoesPlayerExist(TARGET) then
    Citizen.Trace(('Invalid argument specified at index #2 \'target\' %s must be an online player.'):format(TARGET))
    return
  end

  if TARGET == source then
    exports.chat:addMessage(source, {
      color = {255, 0, 0},
      args = {'Valkyrie', ('You cannot change your own permission'):format(PERMISSION)},
    })
    return
  end

  if ACTION == 'grant' then
    local PERMISSION <const> = args[3]

    if not exports.Valkyrie:doesPermissionExist(PERMISSION) then
      exports.chat:addMessage(source, {
        color = {255, 0, 0},
        args = {'Valkyrie', ('Cannot grant permission %s as it does not exist.'):format(PERMISSION)},
      })

      return
    end

    if IsPlayerAceAllowed(TARGET, PERMISSION) then
      exports.chat:addMessage(source, {
        color = {255, 0, 0},
        args = {'Valkyrie', ('%s already has permission for %s'):format(PERMISSION)},
      })

      return
    end

    if exports.Valkyrie:addPermission(TARGET, PERMISSION) then
      return
    end


  end

  if ACTION == 'approve' then
  end

  if ACTION == 'revoke' then
    local PERMISSION <const> = args[3]


  end

  if ACTION == 'deny' then
  end



  if not target or not DoesPlayerExist(target) then
    AddMessage(source, ('Invalid player index specified %s does not exist'):format(target))
    return
  end

  --if target == source then
    --AddMessage('You cannot change your own permission')
    --return
  --end

  if action ~= 'approve' and action ~= 'deny' then
    AddMessage(source, 'Invalid action specified, available actions are \'approve\' or \'deny\'.')
    return
  end

  if action == 'approve' then
    local targetName = GetPlayerName(target)
    local requestedPermission = RequestQueue(target)

    if not requestedPermission then
      AddMessage(source, ('%s(%s) does not have any pending permission requests'):format(targetName, target))
      return
    end

    local targetIdentifier = GetPlayerIdentifierByType(target, 'license')

    ExecuteCommand(ADD_PERMISSION_COMMAND:format(targetIdentifier, requestedPermission))
  end

  if action == 'remove' then
    local targetName = GetPlayerName(target)
    local targetPermission = RequestQueue(target)

    if not targetPermission then
      AddMessage(source, ('%s(%s) does not have any pending permission requests'):format(targetName, target))
      return
    end

    local targetIdentifier = GetPlayerIdentifierByType(target, 'license')

    ExecuteCommand(REMOVE_PERMISSION_COMMAND:format(targetIdentifier, targetPermission))
  end
end, true)


AddEventHandler('vac:internal:sync', function(module)
  if GetInvokingResource() ~= CURRENT_RESOURCE_NAME then
    return
  end

  if module ~= 'all' and module ~= 'commands' then
    return
  end
end)