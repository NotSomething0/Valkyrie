-- Copyright (C) 2019 - 2026  NotSomething

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

---Gets the name for the sender of a command "console" if playerIndex is zero
---@param playerIndex string
---@return string senderName
function GetSenderName(playerIndex)
  -- Supress IntelliSense wanting a string
  playerIndex = tostring(playerIndex)

  if playerIndex == '0' then
    return 'console'
  end

  if not DoesPlayerExist(playerIndex) then
    error(('Invalid argument at index #1 player %s does not exist.'):format(playerIndex))
  end

  return GetPlayerName(playerIndex)
end

---Utility function instead of checking if the message needs to be sent to the console or client
---@param target string who the message should be sent to
---@param message string
function AddMessage(target, message)
  if target == 0 or target == '0' then
    Citizen.Trace(message..'\n')
    return
  end

  exports.chat:addMessage(target, {
    color = {89, 0, 152},
    args = {'Valkyrie', message}
  })
end