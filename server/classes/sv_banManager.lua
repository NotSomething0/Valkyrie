-- Copyright (C) 2019 - Present, NotSomething

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

local BAN_KEY <const> = 'ban:%s'
local BAN_EXPIRES_KEY <const> = 'record:%s:expires'
local BAN_IDENTIFIER_KEY <const> = 'record:%s:identifier:%s'
local BAN_TOKEN_KEY <const> = 'record:%s:token:%s'
local MINIMUM_BAN_TIME <const> = 86400

---@class CBanManager
---@field m_logger CLogger
---@field m_totalBans number
---@field m_identifierLookup table
---@field m_tokenLookup table
---@field m_bans CCache
CBanManager = {}
CBanManager.__index = CBanManager

---Create a new instance of CBanManager
---@return CBanManager banManager
function CBanManager.new()
    local banManager = setmetatable({
        m_logger = CLogger.new(),
        m_bans = CCache.new('string', CBanRecord),
        m_identifierLookup = {},
        m_tokenLookup = {}
    }, CBanManager)

    CreateThread(function()
        banManager:initialize()
    end)

    return banManager
end

---Caches the ban list in memory for faster iteration
function CBanManager:initialize()
    local kvpKey
    local kvpHandle = StartFindKvp(BAN_KEY:format(''))

    repeat
        kvpKey = FindKvp(kvpHandle)

        if kvpKey then
            local banId = kvpKey:gsub(BAN_KEY:format(''), '')
            local record = CBanRecord.new(
                banId,
                GetResourceKvpString(BAN_KEY:format(banId)),
                GetResourceKvpInt(BAN_EXPIRES_KEY:format(banId)),
                self:getStoredBannedIdentifiers(banId),
                self:getStoredBannedTokens(banId)
            )

            self.m_bans:set(banId, record)
        end
    until not kvpKey

    EndFindKvp(kvpHandle)

    for _, banRecord in pairs(self.m_bans.m_data) do
        for _, identifierValue in pairs(banRecord.m_identifiers) do
            self.m_identifierLookup[identifierValue] = banRecord
        end

        for _, tokenValue in pairs(banRecord.m_tokens) do
            self.m_tokenLookup[tokenValue] = banRecord
        end
    end
end

---Adds a new ban to the cache and database
---@param expiration number
---@param identifiers table
---@param tokens table
---@return CBanRecord? banRecord
function CBanManager:addBan(reason, expiration, identifiers, tokens)
    local success, record = pcall(CBanRecord.new, nil, reason, expiration, identifiers, tokens)

    if not success then
        error('Failed to create ban')
    end

    SetResourceKvp(BAN_KEY:format(record.m_id), record.m_reason)
    SetResourceKvpInt(BAN_EXPIRES_KEY:format(record.m_id), record.m_expires)

    for identifierType, identifierValue in pairs(record.m_identifiers) do
        self.m_identifierLookup[identifierValue] = record
        SetResourceKvp(BAN_IDENTIFIER_KEY:format(record.m_id, identifierType), identifierValue)
    end

    for tokenType, tokenValue in pairs(record.m_tokens) do
        self.m_tokenLookup[tokenValue] = record
        SetResourceKvp(BAN_TOKEN_KEY:format(record.m_id, tokenType), tokenValue)
    end

    self.m_bans:set(record.m_id, record)

    return record
end

---Revokes the specified banId with an optional reason
---@param ban CBanRecord
---@param reason string?
function CBanManager:revokeBan(ban, reason)
    if not ban then
        self.m_logger:warn(('CBanManager:revokeBan: Invalid banId specified \'%s\' does not exist.'):format(ban.m_id))
        return
    end

    if type(reason) ~= 'string' or reason == '' then
        reason = 'No reason specified'
    end

    for identifierType, identifierValue in pairs(ban.m_identifiers) do
        self.m_identifierLookup[identifierValue] = nil
        DeleteResourceKvp(BAN_IDENTIFIER_KEY:format(ban.m_id, identifierType))
    end

    for tokenType, tokenValue in pairs(ban.m_tokens) do
        self.m_tokenLookup[tokenValue] = nil
        DeleteResourceKvp(BAN_TOKEN_KEY:format(ban.m_id, tokenType))
    end

    DeleteResourceKvp(BAN_KEY:format(ban.m_id))
    DeleteResourceKvp(BAN_EXPIRES_KEY:format(ban.m_id))

    self.m_bans:delete(ban.m_id)

    self.m_logger:info(('CBanManager:revokeBan: Revoked banId %s. Reason: %s'):format(ban.m_id, reason))
end

---Gets stored banned identifiers for the specified banId
---@param banId string
---@return table
function CBanManager:getStoredBannedIdentifiers(banId)
    local bannedIdentifiers = {}
    local kvpHandle = StartFindKvp(BAN_IDENTIFIER_KEY:format(banId, ''))
    local kvpKey

    repeat
        kvpKey = FindKvp(kvpHandle)
        if kvpKey then
            local identifierType = kvpKey:match('identifier:(.*)')

            bannedIdentifiers[identifierType] = GetResourceKvpString(kvpKey)
        end

    until not kvpKey

    EndFindKvp(kvpHandle)

    return bannedIdentifiers
end

---Gets stored banned tokens for the specified banId
---@param banId string
---@return table
function CBanManager:getStoredBannedTokens(banId)
    local bannedTokens = {}
    local kvpHandle = StartFindKvp(BAN_TOKEN_KEY:format(banId, ''))
    local kvpKey
    repeat
        kvpKey = FindKvp(kvpHandle)

        if kvpKey then
            local tokenType = kvpKey:match('token:(.*)')

            print(tokenType)

            bannedTokens[tokenType] = GetResourceKvpString(kvpKey)
        end

    until not kvpKey

    EndFindKvp(kvpHandle)

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
    SetResourceKvp(BAN_KEY:format(banId), reason)
end

---Sets the expiration time for an already existing ban
---@param banId string
---@param expiration number
function CBanManager:setBanExpiration(banId, expiration)
    if not self.m_bans:get(banId) then
        self.m_logger:warn('CBanManager:updateBannedIdentifiers: Cannot set ban expiration for banId %s as it does not exist, try adding a ban instead.')
        return
    end

    self.m_bans[banId].expires = expiration
    SetResourceKvpInt(BAN_EXPIRES_KEY:format(banId), expiration)
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
    SetResourceKvp(BAN_IDENTIFIER_KEY:format(banId, identifierType), identifierValue)
end

---Sets the specified token on an already existing ban
---@param banId string
---@param tokenType string
---@param tokenValue string
function CBanManager:setBanTokenType(banId, tokenType, tokenValue)
    if not self.m_bans:get(banId) then
        self.m_logger:warn(('CBanManager:updateBannedIdentifiers: Cannot set banned tokenType %s for banId %s as it does not exist.'):format(tokenType, banId))
    end

    self.m_bans[banId].identifiers[tokenType] = tokenValue
    SetResourceKvp(BAN_IDENTIFIER_KEY:format(banId, tokenType), tokenValue)
end

---Check if the specified player is banned
---@param player CPlayer
---@return boolean banned
---@return CBanRecord? ban
function CBanManager:isPlayerBanned(player)
    if getmetatable(player) ~= CPlayer then
        self.m_logger:warn('CBanManager:isPlayerBanned: Invalid argument at index #1 \'player\' must be an instance of CPlayer.')
        return false
    end

    for _, record in pairs(self.m_bans.m_data) do
        local expired = record.m_expires - os.time() <= 0

        if expired then
            self:revokeBan(record, 'automatically revoked ban has expired')
        end
    end

    for _, identifierValue in pairs(player.m_identifiers) do
        local banRecord = self.m_identifierLookup[identifierValue]

        if banRecord then
            return true, banRecord
        end
    end

    for _, tokenValue in pairs(player.m_tokens) do
        local banRecord = self.m_tokenLookup[tokenValue]

        if banRecord then
            return true, banRecord
        end
    end

    return false
end

---Ban a specified player for an optional reason and time
---@param player CPlayer The player being banned
---@param reason string? The reason for players ban defaults to "No reason specified"
---@param expiration number? The duration of the players ban defaults to one day
function CBanManager:banPlayer(player, reason, expiration)
    assert(getmetatable(player) == CPlayer, 'CBanManager:banPlayer: \'player\' must be a instance CPlayer')

    if type(reason) ~= 'string' or reason == '' then
        reason = 'No reason specified'
    end

    if type(expiration) ~= 'number' or expiration < MINIMUM_BAN_TIME then
        expiration = MINIMUM_BAN_TIME
    end

    expiration = expiration + os.time()

    local record = self:addBan(reason, expiration, player.m_identifiers, player.m_tokens)

    if not record then
        return
    end

    self.m_logger:info(('%s has just been banned for %s. Their ban will expire on %s'):format(GetPlayerName(player.m_source), reason, os.date('%c', expiration)))
    DropPlayer(player.m_source, ('You have been banned from this server!\nBanId: %s\nExpires: %s\nReason: %s'):format(record.m_id, os.date('%c', expiration), reason))
end
