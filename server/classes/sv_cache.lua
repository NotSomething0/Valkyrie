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

---Tables with type checking!
---@class CCache
---@field private m__keyLock string|table Lua type or metatable to lock the key in the cache to
---@field private m__valueLock string|table Lua type or metatable to lock the key in the cache to
---@field private m__className string Name of the class only used for internal purposes
---@field m_data table Isolated cache storage to prevent method scope poisoning
CCache = {
    m__keyLock = '',
    m__valueLock = '',
    m__className = 'CCache',
    m_data = {}
}
CCache.__index = CCache
CCache.__call = function(self, key)
    if not key then
        return self.m_data
    end

    return self:get(key)
end

---Creates a new instance of CCache
---@param keyLock string
---@param valueLock string|table
---@return CCache
function CCache.new(keyLock, valueLock)
    local cache = setmetatable({}, CCache)

    cache.m__keyLock = keyLock or 'any'
    cache.m__valueLock = valueLock or 'any'

    return cache
end

---Get the currently set keyLock
---@return string|table
function CCache:getKeyLock()
    return self.m__keyLock
end

---Get the currently set valueLock
---@return string|table
function CCache:getValueLock()
    return self.m__valueLock
end

function CCache:checkKey(key)
    local keyLock = self:getKeyLock()

    if keyLock == 'any' then
        return
    end

    if type(keyLock) == 'table' then
        local keyMetaTable = getmetatable(key)

        if not keyMetaTable or keyMetaTable ~= keyLock then
            error(('Invalid type for key, expected instance of %s got %s'):format(keyLock.getClassName(), keyMetaTable.getClassName()))
        end
    end

    local keyType = type(key)

    if keyType ~= keyLock then
        error(('Invalid type for key, expected %s got %s'):format(keyLock, keyType))
    end
end

function CCache:checkValue(value)
    local valueLock = self:getValueLock()

    if valueLock == 'any' then
        return
    end

    if type(valueLock) == 'table' then
        local valueMetaTable = getmetatable(value)

        if not valueMetaTable or valueMetaTable ~= valueLock then
            error(('Invalid type for key, expected instance of %s got %s'):format(valueLock.getClassName(), valueMetaTable.getClassName()))
        end
    end

    local valueType = type(value)

    if valueType ~= valueLock then
        error(('Invalid type for key, expected %s got %s'):format(valueLock, valueType))
    end
end

---Sets a key value in the data store
---@param key any key to set data for
---@param value any value for the key
function CCache:set(key, value)
    self:checkKey(key)
    self:checkValue(value)

    rawset(self.m_data, key, value)
end

---Get the value of a key in the data store
---@param key any key to get the value of
---@return any value of the key
function CCache:get(key)
    self:checkKey(key)

    return rawget(self.m_data, key)
end

---Set the value of the key in the data store to nil
---@param key any the key to remove from the cache
function CCache:delete(key)
    self:checkKey(key)

    rawset(self.m_data, key, nil)
end