-- Copyright (C) 2019 - 2022  NotSomething

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

local RESOURCE_NAME <const> = GetCurrentResourceName()

local chatFilterEnabled = false
local chatFilterData = {
  prohibited_text = {},
  censored_text = {}
}

local function initializeFilterData()
  local filterData, _, errMsg = json.decode(GetConvar('vac:chat:filter_data', '{}'))

  local censoredText = filterData['censored_text']
  local prohibitedText = filterData['prohibited_text']

  table.clear(chatFilterData.prohibited_text)
  table.clear(chatFilterData.censored_text)

  for i = 1, #censoredText do
    local text = censoredText[i]

    chatFilterData.censored_text[i] = text:lower()
  end

  for i = 1, #prohibitedText do
    local text = prohibitedText[i]

    chatFilterData.prohibited_text[i] = text:lower()
  end
end

local function doesMessageContainProhibitedText(message)
  message = message:lower()

  local prohibitedText = chatFilterData['prohibited_text']

  for i = 1, #prohibitedText do
    local text = prohibitedText[i]

    if message:find(text) then
      return true
    end
  end

  return false
end

local function doesMessageContainCensoredText(message)
  message = message:lower()

  local censoredText = chatFilterData['censored_text']

  for i = 1, #censoredText do
    local text = censoredText[i]

    if message:find(text) then
      return true
    end
  end

  return false
end

exports.chat:registerMessageHook(function(source, out, hook)
  if not chatFilterEnabled then
    return
  end

  if tonumber(source) < 1 or IsPlayerAceAllowed(source, 'vac:chat') then
    return
  end

  local authorName = out.args[1]
  local pendingMessage = out.args[2]

  if doesMessageContainProhibitedText(pendingMessage) then
    hook.cancel()
    return
  end

  if doesMessageContainCensoredText(pendingMessage) then
    local _pendingMessage = pendingMessage:lower()

    for i = 1, #chatFilterData['censored_text'] do
      local text = chatFilterData['censored_text'][i]:lower()
      local textCensored = ("#"):rep(text:len())
      local idx, sfx

      repeat
        idx, sfx = _pendingMessage:find(text)

        if idx and sfx then
          pendingMessage = pendingMessage:sub(1, idx - 1)..textCensored..pendingMessage:sub(sfx + 1)
          -- Update the compare string
          _pendingMessage = _pendingMessage:sub(1, idx - 1)..textCensored.._pendingMessage:sub(sfx + 1)
        end

      until not _pendingMessage:find(text)
    end

    hook.updateMessage({args = {
      authorName,
      pendingMessage
    }})
  end
end)

AddEventHandler('__vac_internel:initialize', function(module)
  if GetInvokingResource() ~= RESOURCE_NAME or module ~= 'all' and module ~= 'chat' then
    return
  end

  chatFilterEnabled = GetConvarBool('vac:chat:enable_filter', false)

  if chatFilterEnabled then
    initializeFilterData()
  end

  log.info(('[CHAT]: Data synced | Chat filter: %s'):format(chatFilterEnabled == true and 'Enabled' or 'Disabled'))
end)