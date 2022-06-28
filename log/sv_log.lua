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

local RESOURCE_PATH <const> = GetResourcePath(RESOURCE_NAME)

log = {
  webhook = GetConvar('vac:log:webhook', '')
  out = RESOURCE_PATH..'/log/log.txt'
  level = GetConvarInt('vac:log:level', 1)
  discordEnabled = GetConvarBool('vac:log:discordLogs', false)
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
    local f = io.open(log.out, 'r+')

    if (f) then
      print(msg)

      f:write(msg..'\n')
      f:close()
    else
      f = io.open(log.out, 'w')

      if (not f) then
        error('Unable to create log file, check that FXServer has the proper permissions set')
        return
      end

      f:write(msg..'\n')
      f:close()
    end
  end
end

log.discord = function(msg)
  if (log.discordEnabled and not log.webhook) then
    log.warn('Discord logs are enabled but an invalid webhook was provided, please check your config or disable discord logs.')

    return
  end


  PerformHttpRequest(log.webhook, function(code)
    if (code == '403') then
      error('Invalid webhook token provided, unable to send log to discord')
    end

    if (code == '429') then
      error('Unable to send log information to discord')
    end

    if (code == '200') then
      log.trace('sent log to discord')
    end
  end, 'POST', json.encode({username = 'Valkyrie Anti-cheat', content = msg}))
end

AddEventHandler('__vac_internal:initalizeServer', function(module)
  if (module ~= 'all' and module ~='log') then
    return
  end

  log.webhook = GetConvar('vac:log:webhook', '')
  log.level = GetConvarInt('vac:log:level', 1)
  log.discordEnabled = GetConvarBool('vac:log:discordLogs', false)
end)