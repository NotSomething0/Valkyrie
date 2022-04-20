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

log = {}

log.level = GetConvarInt('vac:internel:logLevel', 0)
log.webhook = GetConvar('vac:internel:discoWebhook', '')
log.out = 'log.txt'

log.discord = function(msg)
  if (log.webhook ~= '') then
    PerformHttpRequest(log.webhook, function(code)
      if (code == 200) then
        log.trace('message successfully sent to discord')
      elseif (code == 403) then
        log.error('failed to send message to discord, invalid token provided')
      elseif (code == 429) then
        log.error('failed to send message to discord, too many requests (rate limited)')
      end
    end, 'POST', json.encode({username = name, content = msg}))
  else
    log.trace('attempted to send message to discord but no webhook was provided')
  end
end

local levels = {
  'trace',
  'info',
  'warn',
  'error'
}

for idx, lvl in pairs(levels) do
  log[lvl] = function(...)
    -- exit early because we're above the current log level
    if (idx > log.level) then
      return
    end

    local msg = string.format('%s | %s | %s', lvl, os.date('%c'), ...)

    if (io.open(log.out, 'r')) then
      local f = io.open(log.out, 'a')

      f:write(msg..'\n')
      f:close()

      if (lvl == 'info') then
        print(msg)
      elseif (lvl == 'error') then
        error(msg)
      end
    else
      local f = io.open(log.out, 'w')

      if (f) then
        f:write(msg..'\n')
        f:close()
      else
        error('unable to create log file)
      end
    end
  end
end