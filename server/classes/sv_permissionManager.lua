local ADD_ACE_COMMAND <const> = 'add_ace identifier.%s %s allow'
local REMOVE_ACE_COMMAND <const> = 'remove_ace identifier.%s %s allow'

---@class CPermissionManager
---@field m_instance CPermissionManager
---@field m_logger CLogger
CPermissionManager = {
  m_permissions = {}
}
CPermissionManager.__index = CPermissionManager

---Create a new instance of CPermissionManager
function CPermissionManager.new()
  if CPermissionManager.m_instance then
    return CPermissionManager.m_instance
  end

  local permissionManager = setmetatable({
    m_logger = CLogger:getInstance(),
    m_permissions = {
      ['vac:admin'] = true,
      ['vac:explosion'] = true,
    }
  }, CPermissionManager)

  CPermissionManager.m_instance = permissionManager

  exports('addPermission', function(playerIndex, permission)
    return permissionManager:addPermission(playerIndex, permission)
  end)

  exports('removePermission', function(playerIndex, permission)
    return permissionManager:removePermission(playerIndex, permission)
  end)

  return permissionManager
end

---Check if a specific permission exists
---@param permission string
---@return boolean
function CPermissionManager:doesPermissionExist(permission)
  return self.m_permissions[permission]
end

---Attempt to add a permission to the specified player
---@param playerIndex string
---@param permission string
---@return boolean success
function CPermissionManager:addPermission(playerIndex, permission)
  if not DoesPlayerExist(playerIndex) then
    self.m_logger:warn(('CPermissionManager:addPermission unable to add permission for player %s as they do not exist.'):format(playerIndex))
    return false
  end

  if not self:doesPermissionExist(permission) then
    self.m_logger:warn(('CPermissionManager:addPermission unable to add permission %s to player %s as the permission does not exist'):format(permission, playerIndex))
    return false
  end

  -- Check if the specified player already has the specified permission otherwise will get duplicate entries in the ACL map.
  if IsPlayerAceAllowed(playerIndex, permission) then
    self.m_logger:trace(('CPermissionManager:addPermission player %s already has permission %s returing true'):format(playerIndex, permission))
    return true
  end

  ExecuteCommand(ADD_ACE_COMMAND:format(GetPlayerIdentifierByType(playerIndex, 'license'), permission))

  return true
end

---Attempt to remove permission from the specified player
---@param playerIndex string
---@param permission string
---@return boolean success
function CPermissionManager:removePermission(playerIndex, permission)
  if not DoesPlayerExist(playerIndex) then
    self.m_logger:warn(('CPermissionManager:removePermission unable to remove permission for player %s as they do not exist.'):format(playerIndex))
    return false
  end

  if not self:doesPermissionExist(permission) then
    self.m_logger:warn(('CPermissionManager:removePermission unable to remove permission %s from player %s as the permission does not exist.'):format(permission, playerIndex))
    return false
  end

  if not IsPlayerAceAllowed(playerIndex, permission) then
    self.m_logger:trace(('CPermissionManager:removePermission player %s doesn\'t have permission %s was it already removed?'):format(playerIndex, permission))
    return true
  end

  ExecuteCommand(REMOVE_ACE_COMMAND:format(GetPlayerIdentifierByType(playerIndex, 'license'), permission))

  return true
end

---Remove a list of permissions from a player usually used during playerDropped
---@param playerIndex string
---@param permissions table
function CPermissionManager:removePermissions(playerIndex, permissions)
  for permissionIndex = 1, #permissions do
    local permission = permissions[permissionIndex]

    self:removePermission(playerIndex, permission)
  end
end
