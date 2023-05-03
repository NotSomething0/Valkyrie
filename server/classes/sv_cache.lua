-- Copyright (C) 2019 - 2023  NotSomething0

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

---@class VCache
---@field keyLock string 'any' or a type to prevent any keys not of that type from being created
---@field valueLock string 'any' or a type to prevent any values not of that type from being created
---@field data table cache storage
VCache = {
    keyLock = '',
    valueLock = '',
    data = {}
}

---Create a new cache object
---@param keyLock string|nil a type to do internal type checking on or any to skip type checking
---@param valueLock string|nil a type to do internal type checking on or any to skip type checking
function VCache:new(keyLock, valueLock)
    local cacheObject = {}

    self.keyLock = keyLock or 'any'
    self.valueLock = valueLock or 'any'

    self.__index = self
    self.__call = function(self, key)
        if not key then
            return self.data
        end

        return self:get(key)
    end

    return setmetatable(cacheObject, self)
end

---Sets a key value in the data store
---@param key any key to set data for
---@param value any value for the key
function VCache:set(key, value)
    local keyLock = self.keyLock
    local valueLock = self.valueLock

    if keyLock ~= 'any' and type(key) ~= keyLock then
        error(('Invalid type for key, expected %s got %s')):format(keyLock, type(key))
    end

    if valueLock ~= 'any' and type(value) ~= valueLock then
        error(('Invalid type for value, expected %s got %s'):format(valueLock, type(value)))
    end

    rawset(self.data, key, value)
end

---Get the value of a key in the data store
---@param key any key to get the value of
---@return any value of the key
function VCache:get(key)
    local keyLock = self.keyLock

    if keyLock ~= 'any' and type(key) ~= keyLock then
        error(('Invalid type for key, expected %s got %s'):format(keyLock, type(key)))
    end

    return rawget(self.data, key)
end

---Set the value of the key in the data store to nil
---@param key any the key to remove from the cache
function VCache:invalidate(key)
    local keyLock = self.keyLock

    if keyLock ~= 'any' and type(key) ~= keyLock then
        error(('Invalid type for key, expected %s got %s')):format(keyLock, type(key))
    end

    rawset(self.data, key, nil)
end