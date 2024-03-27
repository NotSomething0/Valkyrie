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

---@return integer logLevel
local function getLogLevel()
  local logLevel = LOG_LEVELS[GetConvar('vac:logger:logLevel', 'OFF')]

  if not logLevel then
    warn('Logging has been disabled invalid log level specified, please check vac:logger:logLevel to resolve this warning.')
    logLevel = LOG_LEVELS.OFF
  end

  return logLevel
end

---@return string
local function getLogPath()
  local resourceName = GetCurrentResourceName()
  local resourcePath = GetResourcePath(resourceName)
  local defaultLogPath = resourcePath..'/log.txt'
  local logPath = GetConvar('vac:logger:logPath', defaultLogPath)

  local file, errorMessage = io.open(logPath, 'a+')

  if not file then
    warn(('Unable to open log file at %s for reading/writing: %s. Using default log path %s'):format(logPath, errorMessage, defaultLogPath))
  end

  if not logPath or logPath == '' then
    local resourceName = GetCurrentResourceName()
    local resourcePath = GetResourcePath(resourceName)

    logPath = resourcePath .. '\\log.txt'
  end

  return logPath
end

---Create a new instance of CLogger
---@return CLogger logger 
function CLogger.new()
  local logger = setmetatable({}, CLogger)

  logger.m_path = getLogPath()
  logger.m_level = getLogLevel()

  CreateThread(function()
    while true do
      Wait(1000)
      logger:flush()
    end
  end)

  logger:debug('Instantiated instance of CLogger')

  return logger
end

---comment
function CLogger:flush()
  if self.m_level == LOG_LEVELS.OFF then
    self:debug('CLogger:flush exited early, log level set to OFF')
    return
  end

  local bufferLength = #self.m_buffer

  if bufferLength < 1 then
    --self:debug('CLogger:flush exited early, no buffered logs to flush')
    return
  end

  local logFile, errorMessage = io.open(self.m_path, 'a+')

  if not logFile then
    self.m_level = LOG_LEVELS.OFF
    error(('Unable to open log file for reading/writing: %s'):format(errorMessage))
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

    logFile:write(logEntry)
    self.m_buffer[bufferIndex] = nil
  end

  logFile:close()
end

---comment
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

---comment
---@param logMessage any
function CLogger:fatal(logMessage)
  self:log('FATAL', logMessage)
end

---comment
---@param logMessage any
function CLogger:error(logMessage)
  self:log('ERROR', logMessage)
end

---comment
---@param logMessage any
function CLogger:warn(logMessage)
  self:log('WARN', logMessage)
end

---comment
---@param logMessage any
function CLogger:info(logMessage)
  self:log('INFO', logMessage)
end

---comment
---@param logMessage any
function CLogger:debug(logMessage)
  self:log('DEBUG', logMessage)
end

---comment
---@param logMessage any
function CLogger:trace(logMessage)
  self:log('TRACE', logMessage)
end