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
local RESOURCE_PATH <const> = GetResourcePath(RESOURCE_NAME)

log = {}

log.level = 1
log.webhook = GetConvar('vac:internel:discoWebhook', '')
log.out = RESOURCE_PATH..'/log/log.txt'

log.discord = function(msg)
  PerformHttpRequest(log.webhook, function(code)
    if (code == 200) then
      log.trace('successfully sent message to discord')
    elseif (code == 403) then
      log.error('invalid webhook token provided')
    elseif (code == 429) then
      log.error('failed to send message to discord, too many requests (rate limited)')
    end
  end, 'POST', json.encode({username = name, content = msg}))
end

local levels = {
  'INFO',
  'TRACE',
  'WARN',
  'ERROR'
}

for idx, lvl in pairs(levels) do
  log[lvl:lower()] = function(...)
    -- exit early because we're above the current log level
    if (idx > log.level) then
      return
    end

    local msg = string.format('%s | %s | %s', lvl, os.date('%c'), ...)

    if (log.webhook) then
      log.discord(msg)
    end

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

AddEventHandler('__vac_internel:initalizeServer', function(module)
  if (module ~= 'log' and module ~= 'all') then
    return
  end

  local new_log_level = GetConvarInt('vac:internal:logLevel', 1)

  if (new_log_level < 1) then
    log.level = new_log_level

    log.info('vac:internal:logLevel is set lower than allowed, defaulting Log Level to one')
    return
  end

  log.level = new_log_level
end)