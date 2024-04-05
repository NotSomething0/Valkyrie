-- Copyright (C) 2019 - 2024  NotSomething

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
local BAN_PREFIX <const> = 'vac_ban_%s'
local BAN_EXPIRES_PREFIX <const> = 'vac_ban_%s_expires'
local BAN_IDENTIFIER_PREFIX <const> = 'vac_ban_%s_identifier_%'
local BAN_TOKEN_PREFIX <const> = 'vac_ban_%s_token_%'
local MINIMUM_BAN_TIME <const> = 86400

---@class CBanManager
---@field m_logger CLogger
---@field m_bans CCache
CBanManager = {}
CBanManager.__index = CBanManager

---Generates a random UUIDv4 string.
---@return string uuid The generated UUID string.
local function uuid()
    ---@diagnostic disable-next-line: redundant-return-value
    return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

---Create a new instance of CBanManager
---@param logger CLogger
---@return CBanManager banManager
function CBanManager.new(logger)
    local banManager = setmetatable({
        m_logger = logger,
        m_bans = CCache.new('string', 'table'),
    }, CBanManager)

    AddEventHandler('vac:internal:revokeBan', function(banId, reason)
        if GetInvokingResource() ~= CURRENT_RESOURCE_NAME then
            return
        end

        banManager:revokeBan(banId, reason)
    end)

    banManager:cacheBanList()

    return banManager
end

---Caches the ban list in memory for faster iteration
function CBanManager:cacheBanList()
    local kvpHandle = StartFindKvp(BAN_PREFIX:format(''))
    local kvpKey

    repeat
        kvpKey = FindKvp(kvpHandle)

        if kvpKey and not kvpKey:find('_expires') and not kvpKey:find('_identifier') and not kvpKey:find('_token')  then
            local banId = kvpKey:gsub(BAN_PREFIX, '')

            self.m_bans:set(banId, {
                reason = GetResourceKvpString(BAN_PREFIX:format(banId)),
                expires = GetResourceKvpInt(BAN_EXPIRES_PREFIX:format(banId)),
                identifiers = self:getStoredBannedIdentifiers(BAN_IDENTIFIER_PREFIX:format(banId, '')),
                tokens = self:getStoredBannedTokens(BAN_TOKEN_PREFIX:format(banId, ''))
            })
        end
    until not kvpKey

    EndFindKvp(kvpHandle)
end

---Adds a new ban to the cache and database
---@param banId string
---@param data table
function CBanManager:addBan(banId, data)
    if self.m_bans:get(banId) then
        self.m_logger:error(('CBanManager:addBan: BanId %s already exists cannot add new ban.'):format(banId))
        return
    end

    SetResourceKvp(banId, data.reason)
    SetResourceKvpInt(banId..'_expires', data.expires)

    for identifierType, identifier in pairs(data.identifiers) do
        SetResourceKvp(BAN_IDENTIFIER_PREFIX:format(banId)..identifierType, identifier)
    end

    for tokenType, token in pairs(data.tokens) do
        SetResourceKvp(BAN_TOKEN_PREFIX:format(banId)..tokenType, token)
    end

    self.m_bans:set(banId, data)
end

---Revokes the specified banId with an optional reason
---@param banId string
---@param reason string?
function CBanManager:revokeBan(banId, reason)
    if type(banId) ~= 'string' or not self.m_bans:get(banId) then
        self.m_logger:warn(('CBanManager:revokeBan: Invalid banId specified \'%s\' does not exist.'):format(banId))
        return
    end

    if type(reason) ~= 'string' then
        reason = 'No reason specified'
    end

    DeleteResourceKvp(banId)
    DeleteResourceKvp(banId..'_expires')
    DeleteResourceKvp(banId..'_identifiers')
    DeleteResourceKvp(banId..'_tokens')
    self.m_bans:delete(banId)

    self.m_logger:info(('CBanManager:revokeBan: Revoked banId %s. Reason %s'):format(banId, reason))
end

---Gets stored banned identifiers for the specified banId
---@param identifiersPrefix string
---@return table?
function CBanManager:getStoredBannedIdentifiers(identifiersPrefix)
    local bannedIdentifiers = {}

    if not GetResourceKvpString(identifiersPrefix) then
        self.m_logger:warn(('CBanManager:getStoredBannedIdentifiers: Unable to get stored identifiers for banId %s as it does not exist.'):format(identifiersPrefix))
        return
    end

    local kvpHandlePrefix = identifiersPrefix
    local kvpHandle = StartFindKvp(kvpHandlePrefix)
    local kvpKey
    repeat
        kvpKey = FindKvp(kvpHandle)

        if kvpKey then
            local identifierType = kvpKey:gsub(kvpHandlePrefix, '')

            bannedIdentifiers[identifierType] = GetResourceKvpString(kvpKey)
        end

    until not kvpKey

    return bannedIdentifiers
end

---Gets stored banned tokens for the specified banId
---@param tokensPrefix string
---@return table?
function CBanManager:getStoredBannedTokens(tokensPrefix)
    local bannedTokens = {}

    if not GetResourceKvpString(tokensPrefix) then
        self.m_logger:warn(('CBanManager:getStoredBannedTokens: Unable to get stored tokens for banId %s as it does not exist.'):format(tokensPrefix))
        return
    end

    local kvpHandlePrefix = tokensPrefix
    local kvpHandle = StartFindKvp(kvpHandlePrefix)
    local kvpKey
    repeat
        kvpKey = FindKvp(kvpHandle)

        if kvpKey then
            local tokenType = kvpKey:gsub(kvpHandlePrefix, '')

            bannedTokens[tokenType] = GetResourceKvpString(kvpKey)
        end

    until not kvpKey

    return bannedTokens
end

---Sets the reason for an already existing ban
---@param banId string
---@param reason string
function CBanManager:setBanReason(banId, reason)
    if not self.m_bans:get(banId) then
        self.m_logger:warn('CBanManager:updateBanReason: Could not set ban reason for banId %s as it does not exist, try adding a ban instead.')
        return
    end

    self.m_bans:get(banId).reason = reason
    SetResourceKvp(BAN_PREFIX:format(banId), reason)
end

---comment
---@param banId string
---@param expiration number
function CBanManager:setBanExpiration(banId, expiration)
    if not self.m_bans:get(banId) then
        self.m_logger:warn('CBanManager:updateBannedIdentifiers: Cannot set ban expiration for banId %s as it does not exist, try adding a ban instead.')
        return
    end

    self.m_bans[banId].expires = expiration
    SetResourceKvpInt(BAN_EXPIRES_PREFIX:format(banId), expiration)
end

---Sets the specified identifier on an already existing ban
---@param banId string
---@param identifierType string
---@param identifierValue string
function CBanManager:setBanIdentifierType(banId, identifierType, identifierValue)
    if not self.m_bans:get(banId) then
        self.m_logger:warn(('CBanManager:updateBannedIdentifiers: Cannot set banned identifierType %s for banId %s as it does not exist, try adding a ban instead.'):format(identifierType, banId))
    end

    self.m_bans[banId].identifiers[identifierType] = identifierValue
    SetResourceKvp(BAN_IDENTIFIER_PREFIX:format(banId, identifierType), identifierValue)
end

---comment
---@param banId any
---@param tokenType any
---@param tokenValue any
function CBanManager:setBanTokenType(banId, tokenType, tokenValue)
    if not self.m_bans:get(banId) then
        self.m_logger:warn(('CBanManager:updateBannedIdentifiers: Cannot set banned tokenType %s for banId %s as it does not exist.'):format(tokenType, banId))
    end

    self.m_bans[banId].identifiers[tokenType] = tokenValue
    SetResourceKvp(BAN_IDENTIFIER_PREFIX:format(banId, tokenType), tokenValue)
end

---Check if the specified player is banned
---@param player VPlayer
---@return boolean banned
---@return string? banId
function CBanManager:isPlayerBanned(player)
    if getmetatable(player) ~= VPlayer then
        self.m_logger:error('CBanManager:isPlayerBanned: Invalid argument at index #1 \'player\' must be an instance of VPlayer.')
        return false
    end

    for banId, data in pairs(self.m_bans) do
        local expired = data.expires - os.time() <= 0

        if expired then
            self:revokeBan(banId, 'automatically revoked ban has expired')
        end

        if not expired then
            for identifierType, identifierValue in pairs(data.identifiers) do
                if player.m_identifiers[identifierType] == identifierValue then
                    return true, banId
                end
            end

            for tokenPrefix, tokenValue in pairs(data.tokens) do
                if player.m_tokens[tokenPrefix] == tokenValue then
                    return true, banId
                end
            end
        end
    end

    return false
end

---Bans the specified player for an optional reason and time
---If no time is specified the expiration will default to one day 
---@param player VPlayer
---@param banReason string?
---@param banExpiration number?
---@TODO implement
function CBanManager:banPlayer(player, banReason, banExpiration)
    if getmetatable(player) ~= VPlayer then
        self.m_logger:error('CBanManager:banPlayer: Invalid argument at index #1 \'player\' must be an instance of VPlayer.')
        return
    end

    if not banReason or banReason == '' then
        banReason = 'No reason specified'
    end

    if type(banExpiration) ~= 'number' or banExpiration < MINIMUM_BAN_TIME then
        banExpiration = MINIMUM_BAN_TIME
    end

    banExpiration = banExpiration + os.time()

    local banId

    repeat
        banId = BAN_PREFIX..uuid()
    until not self.m_bans[banId]

    self:addBan(banId, {
        reason = banReason,
        expires = banExpiration,
        identifiers = player.m_identifiers,
        tokens = player.m_tokens
    })

    self.m_logger:info(('%s has just been banned from this the server for %s. Their ban will expire on %s'):format(GetPlayerName(player.m_source), banReason, os.date('%c', banExpiration)))
    DropPlayer(player.m_source, ('You have been banned from this server!\nBanId: %s\nExpires: %s\nReason: %s'):format(banId, os.date('%c', banExpiration), banReason))
end