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

local RESOURCE_NAME <const> = GetCurrentResourceName()

local chatFilterData = {
  enabled = false,
  censoredText = {},
  prohibitedText = {},
}

local function censorMessage(message)
  local censoredText = chatFilterData['censoredText']

  for index = 1, #censoredText do
    local text = censoredText[index]
    local textLength = text:len()
    local textCensored = ("#"):rep(textLength)

    if message:find(text) then
      message = message:gsub(text, textCensored)
    end
  end

  return message
end

local function doesMessageContainProhibitedText(message)
  local prohibitedText = chatFilterData['prohibitedText']

  message = message:lower()

  for i = 1, #prohibitedText do
    local text = prohibitedText[i]:lower()

    if message:find(text) then
      return true
    end
  end

  return false
end

exports.chat:registerMessageHook(function(source, out, hook)
  if not chatFilterData.enabled then
    return
  end

  local author = out.args[1]
  local message = out.args[2]

  if IsPlayerAceAllowed(source, 'vac.chat') then
    return
  end

  local censoredMessage = censorMessage(message)

  if message ~= censoredMessage then
    message = censoredMessage

    hook.updateMessage({
      args = {
        author,
        message
      }
    })
  end

  if doesMessageContainProhibitedText(message) then
    hook.cancel()
    return
  end
end)

AddEventHandler('vac:internal:sync', function(module)
  if GetInvokingResource() ~= RESOURCE_NAME or module ~= 'all' and module ~= 'chat' then
    return
  end

  chatFilterData.enabled = GetConvarBool('vac:chat:filter', false)

  if not chatFilterData.enabled then
    logger:info('[CHAT]: Data synced | Filter: Disabled')
    return
  end

  local filterData = json.decode(GetConvar('vac:chat:filterData', '{}'))

  if not filterData then
    logger:error('Unable to parse vac:chat:filterData, please check your configuration and execute vac:sync.')
  end

  if #chatFilterData.censoredText >= 1 or #chatFilterData.prohibitedText >= 1 then
    ---@diagnostic disable-next-line: undefined-field
    table.clear(chatFilterData.censoredText)
    ---@diagnostic disable-next-line: undefined-field
    table.clear(chatFilterData.prohibitedText)
  end

  chatFilterData.censoredText = filterData.censoredText
  chatFilterData.prohibitedText = filterData.prohibitedText

  logger:info(('[CHAT]: Data synced | Filter: Enabled, %d Censored pattern(s), %d Prohibited pattern(s)'):format(#chatFilterData.censoredText, #chatFilterData.prohibitedText))
end)