local BAN_KEY <const> = 'ban:%s'
local BAN_EXPIRES_KEY <const> = 'record:%s:expires'
local BAN_IDENTIFIER_KEY <const> = 'record:%s:identifier:%s'
local BAN_TOKEN_KEY <const> = 'record:%s:token:%s'

---Generates a random UUIDv4 string.
---@return string UUID The generated UUID string.
local function UUID()
  ---@diagnostic disable-next-line: redundant-return-value
  return string.gsub('xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

---@class CBanRecord
---@field m_id string
---@field m_reason string
---@field m_expires number
---@field m_identifiers table
---@field m_tokens table 
CBanRecord = {}
CBanRecord__index = CBanRecord

---Creates a new ban record
---@param id string?
---@param reason string
---@param expires number
---@param identifiers table
---@param tokens table
function CBanRecord.new(id, reason, expires, identifiers, tokens)
  local ban = setmetatable({
    m_id = id or UUID(),
    m_reason = reason or 'No reason specified',
    m_expires = expires,
    m_identifiers = identifiers or {},
    m_tokens = tokens or {}
  }, CBanRecord)

  return ban
end

---Save ban record to the database
function CBanRecord:save()
  local banId = self.m_id

  SetResourceKvp(BAN_KEY:format(banId), self.m_reason)
  SetResourceKvpInt(BAN_EXPIRES_KEY:format(banId), self.m_expires)

  for identifierType, identifier in pairs(self.m_identifiers) do
    SetResourceKvp(BAN_IDENTIFIER_KEY:format(banId, identifierType), identifier)
  end

  for tokenType, token in pairs(self.m_tokens) do
    SetResourceKvp(BAN_TOKEN_KEY:format(banId, tokenType), token)
  end
end

---Delete ban record from the database
function CBanRecord:delete()
  local banId = self.m_id

  DeleteResourceKvp(BAN_KEY:format(banId))
  DeleteResourceKvp(BAN_EXPIRES_KEY:format(banId))

  for identifierType in pairs(self.m_identifiers) do
    DeleteResourceKvp(BAN_IDENTIFIER_KEY:format(banId, identifierType))
  end

  for tokenType in pairs(self.m_tokens) do
    DeleteResourceKvp(BAN_TOKEN_KEY:format(banId, tokenType))
  end
end