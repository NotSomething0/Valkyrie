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
local LOG_OUT_PATH <const> = RESOURCE_PATH..'/log/log.txt'
local LOG_OUT_SCHEME <const> = '%s | %s | %s'

local f, err = io.open(LOG_OUT_PATH, 'r+')

if (not f) then
  f, err = io.open(LOG_OUT_PATH, 'w+')

  if (not f) then
    error(('Unable to create log file: %s'):format(err))
  end

  f:write(LOG_OUT_SCHEME:format('[info]', os.date('%c'), ('[LOG]: Log file generated at %s\n'):format(LOG_OUT_PATH)))
  f:close()
else
  f:close()
end

log = {}
log.level = GetConvarInt('vac:internal:logLevel', 1)

-- @param level | string | log suffix formatted with color for stdout
-- @param txt | string | log message
-- @return string | formatted output to the log file
function log.write(level, txt)
  local f, err = io.open(LOG_OUT_PATH, 'a+')

  if (not f) then
    error(('Unable to open log file for reading/writing: %s'):format(err))
  end

  f:write(LOG_OUT_SCHEME:format(level:match('%[.+%]'), os.date('%c'), txt)..'\n')
  f:close()

  return LOG_OUT_SCHEME:format(level, os.date('%c'), txt)
end

-- @param err | string | error message
function log.error(err)
  error(log.write('^1[error]^7', err), 2)
end

-- @param txt | string | log message
function log.warn(txt)
  if (log.level < 3) then return end
  print(log.write('^3[warn]^7', txt))
end

-- @param txt | string | log message
function log.trace(txt)
  if (log.level < 2) then return end
  print(log.write('^5[trace]^7', txt))
end

-- @param txt | string | log message
function log.info(txt)
  if (log.level < 1) then return end
  print(log.write('[info]', txt))
end

AddEventHandler('__vac_internel:initialize', function(module)
  if (module ~= 'log' and module ~= 'all') then
    return
  end

  log.level = GetConvarInt('vac:internal:logLevel', 1)
end)