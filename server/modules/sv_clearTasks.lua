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

-- Note: This module is considered finalized and will receive no further updates unless compatibility changes require it

-- Prevents syncing of CLEAR_PED_TASKS / CLEAR_PED_TASKS_IMMEDIATELY calls on remote player peds
-- These were commonly used by abusive players to kick others out of their vehicle while driving
-- Since the server should ultimately decide if a remote player can clear another player's tasks, we'll block any attempts at canceling a remote player's tasks

AddEventHandler('clearPedTasksEvent', function(sender, data)
    local immediately = data.immediately
    local pedHandle = NetworkGetEntityFromNetworkId(data.pedId)
    local pedOwner = NetworkGetEntityOwner(pedHandle)

    if IsPedAPlayer(pedHandle) then
        log.info(('%s attempted to clear tasks on %s, preventing sync. Immediate: %s'):format(GetPlayerName(sender), GetPlayerName(pedOwner), immediately))
        CancelEvent()
    end
end)