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

local allowedFx = {}

AddEventHandler('ptFxEvent', function(sender, data)
  if (not allowedFx[data.effectHash]) then
    CancelEvent()
  end
end)


AddEventHandler('__vac_internel:intalizeServer', function(module)
  if (module == 'ptfx' or 'all') then
    allowedFx = json.decode(GetConvar('set vac::ptfx:allowedFx', '[]'))
  end
end)