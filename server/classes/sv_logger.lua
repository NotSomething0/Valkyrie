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

local LOG_FORMAT <const> = '%s | %s | %s'
local LOG_LEVELS <const> = {
  OFF = 1,
  FATAL = 2,
  ERROR = 3,
  WARN = 4,
  INFO = 5,
  DEBUG = 6,
  TRACE = 7
}

---@class CLogger
---@field m_level number
---@field m_path string
---@field m_buffer table
CLogger = {
  m_level = LOG_LEVELS.OFF,
  m_path = '',
  m_buffer = {}
}
CLogger.__index = CLogger

---Create a new instance of CLogger
---@return CLogger logger 
function CLogger.new()
  local logger = setmetatable({}, CLogger)

  logger:sync()

  CreateThread(function()
    while true do
      Wait(1000)
      logger:flush()
    end
  end)

  return logger
end

---Sets the level of detail and log path for server logs
function CLogger:sync()
  local level = GetConvar('vac:logger:logLevel', 'OFF')

  if not LOG_LEVELS[level] then
    self.m_level = LOG_LEVELS.OFF
    warn('Logging has been disabled an invalid log level was specified for vac:logger:logLevel. Correct your configuration and execute vac:sync main.')
    return
  end

  self.m_level = LOG_LEVELS[level]

  local logPath = GetConvar('vac:logger:logPath', 'default')

  if logPath ~= 'default' then
    local logFile, errorMessage = io.open(logPath, 'a+')

    if not logFile then
      warn(('Unable to open log file at %s for reading/writiing: %s. Using default log path'):format(errorMessage))
      logPath = 'default'
    end
  end

  if logPath == 'default' then
    local resourceName = GetCurrentResourceName()
    local resourcePath = GetResourcePath(resourceName)

    logPath = resourcePath..'\\log.txt'
  end

  self.m_path = logPath
end

---Flushes buffered logs to the specified log file and writes the entry to stdout 
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
    error(('Unable to open log file for reading/writing: %s. Logging has been disabled correct your configuration and execute vac:sync.'):format(errorMessage))
  end

  for bufferIndex = 1, bufferLength do
    local bufferEntry = self.m_buffer[bufferIndex]
    local logEntry = LOG_FORMAT:format(bufferEntry.level, bufferEntry.time, bufferEntry.message)

    if bufferEntry.level == 'ERROR' then
      error(logEntry, 2)
    elseif bufferEntry.level == 'WARN' then
      warn(logEntry)
    else
      print(logEntry)
    end

    logFile:write(logEntry..'\n')
    self.m_buffer[bufferIndex] = nil
  end

  logFile:close()
end

---Adds the log message to the log buffer\
-- Note: This function should not be called directly; it serves as a backing function for the actual "log" functions, such as CLogger:info, CLogger:error, etc.
---@param level any
---@param logMessage any
function CLogger:log(level, logMessage)
  local numericLevel = LOG_LEVELS[level]

  if self.m_level < numericLevel then
    return
  end

  local bufferLength = #self.m_buffer
  local bufferEntry = {
    level = level,
    time = os.time(),
    message = logMessage
  }

  self.m_buffer[bufferLength + 1] = bufferEntry
end

-- Logs a message with the level 'FATAL'.
-- @param logMessage The message to be logged.
function CLogger:fatal(logMessage)
  self:log('FATAL', logMessage)
end

-- Logs a message with the level 'ERROR'.
-- @param logMessage The message to be logged.
function CLogger:error(logMessage)
  self:log('ERROR', logMessage)
end

-- Logs a message with the level 'WARN'.
-- @param logMessage The message to be logged.
function CLogger:warn(logMessage)
  self:log('WARN', logMessage)
end

-- Logs a message with the level 'INFO'.
-- @param logMessage The message to be logged.
function CLogger:info(logMessage)
  self:log('INFO', logMessage)
end

-- Logs a message with the level 'DEBUG'.
-- @param logMessage The message to be logged.
function CLogger:debug(logMessage)
  self:log('DEBUG', logMessage)
end

-- Logs a message with the level 'TRACE'.
-- @param logMessage The message to be logged.
function CLogger:trace(logMessage)
  self:log('TRACE', logMessage)
end