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

local RESOURCE_PATH <const> = GetResourcePath(CurrentResourceName)

log = {
  webhook = '',
  out = RESOURCE_PATH..'/log/log.txt',
  level = 0,
  discordEnabled = false
}

setmetatable(log, {
  __call = function(self, level, msg)
    log[level](msg)
  end
})

local levels = {
  'INFO',
  'TRACE',
  'WARN',
  'ERROR'
}

for idx, lvl in pairs(levels) do
  log[lvl:lower()] = function(...)
    local msg = string.format('%s | %s | %s', lvl, os.date('%c'), ...)

    if (log.discordEnabled) then
      log('discord', msg)
    end

    local f = io.open(log.out, 'r+')

    if (f) then
      print(msg)

      f:write(msg..'\n')
      f:close()
    else
      f = io.open(log.out, 'w')

      if (not f) then
        error('Unable to create log file, check that the FXServer process has proper read and write permissions.')
        return
      end

      f:write(msg..'\n')
      f:close()
    end
  end
end

log.discord = function(msg)
  if (not log.webhook) then
    log('warn', 'Discord logs are enabled but an invalid webhook was provided, please check your config or disable discord logs.')
    return
  end

  PerformHttpRequest(log.webhook, function(code)
    code = tostring(code)

    if (code == '403') then
      error('Invalid webhook token provided, unable to send log to discord')
    end

    if (code == '429') then
      error('Unable to send log information to discord')
    end

    if (code:find('2')) then
      log('trace', 'Log message successfully sent to discord.\nContent: ' ..msg)
    end
  end, 'POST', json.encode({content = msg, username = "Valkyrie Anti-cheat"}), {['Content-Type'] = 'application/json'})
end

AddEventHandler('__vac_internel:intalizeServer', function(module)
  if (module ~= 'all' and module ~='log') then
    return
  end

  log.webhook = GetConvar('vac:log:webhook', '')
  log.level = GetConvarInt('vac:log:level', 1)
  log.discordEnabled = GetConvar('vac:log:discordEnabled', false) == 'true' and true or false
end)