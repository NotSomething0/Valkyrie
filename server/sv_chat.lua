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

local filterIsActive = true
local filterShouldCancel = false
local filterText = {}

local throttleIsOpen = false
local throttleReset = 30
-- hahaha car go vroom
local throttleBody = {}

exports.chat:registerMessageHook(function(source, out, hook)
  local source = source

  if (filterIsActive) then
    local old = out.args[2]:lower()
    local new = out.args[2]
  
    if (#filterText == 0) then
      log.error('The chat filter is enabled but no entries could be loaded, check vac:chat:filterText for proper formatting.')
      return
    end

    for _, v in pairs(filterText) do
      local b, e = old:find(v:lower())
      local s = b ~= nil and old:sub(b, e)

      if (s and filterShouldCancel) then
        hook.cancel()
        break
      end

      if (s) then
        new = new:sub(1, b - 1) ..('#'):rep(s:len()) .. new:sub(e + 1)
      end
    end

    if (old ~= new:lower()) then
      hook.updateMessage({args = {out.args[1], new}})
    end
  end

  if (throttleIsOpen) then
    local shouldSend = true

    if (throttleBody[source]) then
      local wasSent = true
      local content = out.args[2]

      for _, v in pairs(throttleBody[source].msgs) do
        if (v.content == content and v.time > os.time()) then
          wasSent = false
          hook.cancel()
          break
        end
      end

      table.insert(throttleBody[source].msgs, 1, {content = content, time = os.time() + throttleReset * 1000})

      if wasSent == false then
        TriggerClientEvent('chat:addMessage', source, {args = {'Server', 'You\'ve sent the same message too many times, please wait sometime before sending it again.'}})
      end

      if (#throttleBody[source].msgs > 5) then
        table.remove(thorttleBody[source].msgs)
    end
  end
end)

AddEventHandler('__vac_internel:intalizeServer', function(module)
  if (module ~= 'chat' and module ~= 'all') then
    return
  end

  filterIsActive = GetConvar('vac:chat:filterMessages', "false") == "true" and true or false

  if (filterIsActive) then
    local text = json.decode(GetConvar('vac:chat:filterText', '[]'))
    local count = #text

    table.wipe(filterText)

    if (text ~= '[]') then
      for i = 1, #count do
        filterText[i] = text[i]
      end
    end
  end

  throttleIsOpen = GetConvar('vac:chat:rlChat', 'false') == 'false' and true or false

  if (throttleIsOpen) then
    throttleReset = GetConvarInt('vac:chat:rlReset', 30)

    table.wipe(throttleBody)

    for _, v in pairs(throttleBody) do
      throttleBody[v].msgs = {}
    end
  end
end)

AddEventHandler('playerJoining', function()
  throttleBody[source].msgs = {}
end)

AddEventHandler('playerDropped', function()
  throttleBody[source] = nil
end)