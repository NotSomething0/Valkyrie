VCache = {}

-- Create a new virtual cache object
-- @param cacheName | string | name of the cache object not required but useful for debugging 
-- @param keyLock | string | a type to do internal type checking on or any to skip type checking
-- @param valueLock | string | a type to do internal type checking on or any to skip type checking
function VCache:new(cacheName, keyLock, valueLock)
    local cache = {
        name = cacheName or 'undefined',
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

    assert(keyLock ~= 'any' and type(key) ~= keyLock, ('Invalid type for key, expected %s got %s'):format(keyLock, type(key)))
    assert(valueLock ~= 'any' and type(value) ~= valueLock, ('Invalid type for value, expected %s got %s'):format(valueLock, type(value)))

    self.data[key] = value
end

-- Get the value of a key in the cache data store
-- @param key | any | key to get the value of
-- @return any | value of the key
function VCache:get(key)
    local keyLock = self.keyLock
    local cacheName = self.name

    assert(keyLock ~= 'any' and type(key) ~= keyLock, ('Invalid type for key, expected %s got %s'):format(keyLock, type(key)))
    assert(self.data[key], ('No such key %s in cache %s'):format(key, cacheName))

    return self.data[key]
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