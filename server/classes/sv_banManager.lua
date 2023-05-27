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

local BAN_KEY <const> = 'vac_ban_%s'
local MINIMUM_BAN_TIME <const> = 86400

---@class BanManager: VCache
---@field ready boolean Is the BanManager ready to use
BanManager = VCache:new('string', 'table')

---Prevents the creation of another instance of the BanManager
function BanManager:new()
    error('Cannot create another instance of BanManager')
end

---Checks if the BanManager is ready.
---@return boolean ready Returns true if the BanManager is ready; otherwise, false.
function BanManager:isReady()
    return self.ready
end

---Initializes the BanManager by retrieving bans from the database and storing them in memory
function BanManager:initialize()
    local kvpHandle = StartFindKvp(BAN_KEY)

    self.ready = false

    if kvpHandle == -1 then
        self.ready = true
        return
    end

    local kvpKey

    repeat
        kvpKey = FindKvp(kvpHandle)

        if kvpKey then
            self:set(kvpKey, {
                reason = GetResourceKvpString(kvpKey),
                expires = GetResourceKvpString(kvpKey..'_expires'),
                identifiers = json.decode(GetResourceKvpString(kvpKey..'_identifiers')),
                tokens = json.decode(GetResourceKvpString(kvpKey..'_tokens'))
            })
        end
    until not kvpKey

    EndFindKvp(kvpHandle)
    self.ready = true
end

---Generates a random UUIDv4 string.
---@return string uuid The generated UUID string.
---@nodiscard
local function uuid()
---@diagnostic disable-next-line: redundant-return-value
    return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

---@param reason string The reason for this ban
---@param expires number? The expiration timestamp of the ban in seconds since the epoch
---@param identifiers table A list of player identifiers associated with this ban.
---@param tokens table A list of player tokens associated with this ban.
function BanManager:addBan(reason, expires, identifiers, tokens)
    expires = ((expires >= MINIMUM_BAN_TIME and expires) or MINIMUM_BAN_TIME) + os.time()

    if not identifiers or type(identifiers) ~= 'table' or not next(identifiers) then
        error('Invalid argument at index #3: \'identifiers\' must be a non-empty table')
    end


    if not tokens or type(tokens) ~= 'table' or not next(tokens) then
        error('Invalid argument at index #4: \'tokens\' must be a non-empty table')
    end

    local banId

    repeat banId = BAN_KEY:format(uuid()) until not self.data[banId]

    SetResourceKvp(banId, reason)
    SetResourceKvpInt(banId..'_expires', expires)
    SetResourceKvp(banId..'_identifiers', json.encode(identifiers))
    SetResourceKvp(banId..'_tokens', json.encode(tokens))

    return banId, expires
end

function BanManager:removeBan(banId, reason)
    reason = reason or 'No reason specified'

    if not self.data[banId] then
        return false
    end

    DeleteResourceKvp(banId)
    DeleteResourceKvp(banId..'_expires')
    DeleteResourceKvp(banId..'_identifiers')
    DeleteResourceKvp(banId..'_tokens')

    return true
end

--- Edits the identifier value of a ban.
---@param banId string The formatted ban ID (vac_ban_xxxx).
---@param identifierType string The suffix of the identifier token to edit.
---@param identifierValue string The new value of the identifier token.
---@return boolean success True if the identifier was successfully edited; otherwise, false.
function BanManager:editBanIdentifier(banId, identifierType, identifierValue)
    if not self.data[banId] then
        return false
    end

    self.data[banId].tokens[identifierType] = identifierValue
    SetResourceKvp(banId..'_identifiers', json.ecode(self.data[banId].identifiers))

    return true
end

---@param banId string Formatted banId vac_ban_xxxx
---@param tokenNum string Suffix of the token you want to edit
---@param tokenValue string New value of the token you want to edit
function BanManager:editBanToken(banId, tokenNum, tokenValue)
    if not self.data[banId] then
        return false
    end

    self.data[banId].tokens[tokenNum] = tokenValue
    SetResourceKvp(banId..'_tokens', json.ecode(self.data[banId].tokens))

    return true
end

function BanManager:editBanReason(banId, reason)
    if not self.data[banId] then
        return false
    end

    self.data[banId].reason = reason
    SetResourceKvp(banId..'_tokens', json.ecode(self.data[banId].tokens))

    return true
end

---Checks if a player is banned
---@param player VPlayer The player to check for a ban
---@return boolean banned True if the player is banned; otherwise, false
---@return table? banData The ban data associated with the player, or nil if not banned
function BanManager:isPlayerBanned(player)
    local playerIdentifiers
    local playerTokens

    if getmetatable(player) ~= VPlayer then
        error('Invalid argument at index #1 not a valid VPlayer instance')
    end

    playerIdentifiers = player.identifiers
    playerTokens = player.tokens

    for _, banData in pairs(self.data) do
        local bannedIdentifiers = banData.identifiers
        local bannedTokens = banData.tokens

        for identifierPrefix, identifierValue in pairs(bannedIdentifiers) do
            if playerIdentifiers[identifierPrefix] == identifierValue then
                return true, banData
            end
        end

        for tokenNum, tokenValue in pairs(bannedTokens) do
            if playerTokens[tokenNum] == tokenValue then
                return true, banData
            end
        end
    end

    return false
end