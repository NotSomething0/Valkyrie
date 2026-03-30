-- Copyright (C) 2019 - Present,  NotSomething

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

local CURRENT_RESOURCE_NAME = GetCurrentResourceName()
local LOG_FORMAT <const> = '%s | %s | %s'

---@enum LogLevels
local LOG_LEVELS <const> = {
  OFF = 1,
  ERROR = 2,
  WARN = 3,
  INFO = 4,
  DEBUG = 5,
  TRACE = 6
}

---@class CLogger
---@field m_instance CLogger
---@field m_level number
---@field m_path string
---@field m_buffer table
CLogger = {
  m_level = LOG_LEVELS.OFF,
  m_path = ('%s/log.txt'):format(GetResourcePath(CURRENT_RESOURCE_NAME)),
  m_buffer = {}
}
CLogger.__index = CLogger

---Create a new instance of CLogger
---@return CLogger logger 
function CLogger.new()
  if CLogger.m_instance then
    return CLogger.m_instance
  end

  local logger = setmetatable({}, CLogger)

  logger:setLogLevel()

  CreateThread(function()
    while true do
      Wait(1000)
      logger:flush()
    end
  end)

  CLogger.m_instance = logger

  return logger
end

---Get the current instance of CLogger
---@return CLogger logger
function CLogger:getInstance()
  if self.m_instance then
    return self.m_instance
  end

  return CLogger.new()
end

---Get the readable name of the current log level
---@return string logLevel
function CLogger:getLogLevel()
  for levelName, levelValue in pairs(LOG_LEVELS) do
    if self.m_level == levelValue then
      return levelName
    end
  end

  return 'OFF'
end

---Sets the level of detail for server logs
function CLogger:setLogLevel()
  local newLogLevel = GetConvar('vac:logger:logLevel', 'OFF')

  if not LOG_LEVELS[newLogLevel] then
    warn(('%s is not a valid log level using previous log level %s'):format(newLogLevel, self:getLogLevel()))
    return
  end

  self.m_level = LOG_LEVELS[newLogLevel]
end

---Flush buffered logs to the set log file and write the entries to stdout 
function CLogger:flush()
  if self.m_level == LOG_LEVELS.OFF then
    return
  end

  local bufferLength = #self.m_buffer

  if bufferLength < 1 then
    return
  end

  local logFile, errorMessage = io.open(self.m_path, 'a+')

  if not logFile then
    self.m_level = LOG_LEVELS.OFF
    warn(('Logging has been disabled unable to open log file %s. Correct your configuration and execute \'vac:sync logger\'.'):format(errorMessage))
    return
  end

  local output = table.concat(self.m_buffer, '\n')

  table.wipe(self.m_buffer)

  logFile:write(output)
  logFile:close()
end

---Adds a log message to the log buffer
---@param level string
---@param logMessage string
function CLogger:log(level, logMessage)
  local numericLevel = LOG_LEVELS[level]

  if self.m_level < numericLevel then
    return
  end

  local logEntry = LOG_FORMAT:format(level, os.time(), logMessage)

  if level == 'ERROR' then
    print(('^1%s^7'):format(logEntry))
  elseif level == 'WARN' then
    print(('^3%s^7'):format(logEntry))
  else
    print(logEntry)
  end

  table.insert(self.m_buffer, logEntry)
end

---Logs a message with the level 'ERROR'.
---@param logMessage string The message to be logged.
function CLogger:error(logMessage)
  self:log('ERROR', logMessage)
end

---Logs a message with the level 'WARN'.
---@param logMessage string The message to be logged.
function CLogger:warn(logMessage)
  self:log('WARN', logMessage)
end

-- Logs a message with the level 'INFO'.
---@param logMessage string The message to be logged.
function CLogger:info(logMessage)
  self:log('INFO', logMessage)
end

---Logs a message with the level 'DEBUG'.
---@param logMessage string The message to be logged.
function CLogger:debug(logMessage)
  self:log('DEBUG', logMessage)
end

---Logs a message with the level 'TRACE'.
---@param logMessage string The message to be logged.
function CLogger:trace(logMessage)
  self:log('TRACE', logMessage)
end

AddConvarChangeListener('vac:logger:*', function(convarName)
  local logger = CLogger:getInstance()

  if convarName == 'vac:logger:logLevel' then
    logger:setLogLevel()
  end
end)
