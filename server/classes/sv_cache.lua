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

VCache = {}

-- Create a new virtual cache object
-- @param keyLock | string | a type to do internal type checking on or any to skip type checking
-- @param valueLock | string | a type to do internal type checking on or any to skip type checking
function VCache:new(keyLock, valueLock)
    local cache = {
        keyLock = keyLock or 'any',
        valueLock = valueLock or 'any',
        data = {}
    }

    setmetatable(cache, self)
    self.__index = self

    return cache
end

-- Set a new or existing key value in the cache data store
-- @param key | any | key to set data for
-- @param vcalue | any | value for the key
function VCache:set(key, value)
    local keyLock = self.keyLock
    local valueLock = self.valueLock

    if keyLock ~= 'any' and type(key) ~= keyLock then
        error('Invalid type for key, expected %s got %s'):format(keyLock, type(key))
    end

    if valueLock ~= 'any' and type(value) ~= valueLock then
        error(('Invalid type for value, expected %s got %s'):format(valueLock, type(value)))
    end

    self.data[key] = value
end

-- Get the value of a key in the cache data store
-- @param key | any | key to get the value of
-- @return any | value of the key
function VCache:get(key)
    local keyLock = self.keyLock

    if (keyLock ~= 'any' and type(key) ~= keyLock) then
        error(('Invalid type for key, expected %s got %s'):format(keyLock, type(key)))
    end

    if (not self.data[key]) then
        return false
    end

    return self.data[key]
end

-- Set the value of the passed key to nil avoding the valueLock type check
-- @param key | any | the key to remove from the cache
function VCache:remove(key)
    self.data[key] = nil
end

-- Get the entire data store
-- @return table | cache data store
function VCache:getData()
    return self.data
end

-- Clear's the cache data store
function VCache:clear()
    -- CfxLua/LuaGLM implements the table.clear function
    ---@diagnostic disable-next-line: undefined-field
    table.clear(self.data)
end