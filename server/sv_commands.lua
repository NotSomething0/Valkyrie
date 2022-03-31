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

local format = string.format
local webhook = GetConvar("valkyrie_discord_webhook", "")
local modules = {
  ['entities'] = 'entities',
  ['explosion'] = 'explosion',
  ['filter'] = 'filter'
}

RegisterCommand('unban', function(source, args)
  if source ~= 0 then
    print('^1[ERROR] [Valkyrie]^7 This command can only be run from the console.')
    return
  end

  local banId = args[1]
  local reason = 'No reason specified'

  if banId and GetResourceKvpString(format('vac_ban_%s', banId)) then
    DeleteResourceKvp(format('vac_ban_%s', banId))
    print('^6[INFO] [VALKYRIE]^7 BanId: %s successfully unbanned', banId)
  else
    print('^1[WARN] [Valkyrie]^7 Invalid banId, please try again.')
    return
  end

  if args[2] then
    table.remove(args, 1)
    reason = table.concat(args, " ")
  end

  local log = format('**Valkyrie: Unbanned**\n BanId:%s\n Reason:%s', banId, reason)

  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, content = log}), { ['Content-Type'] = 'application/json' })
end, true)


RegisterCommand('reload', function(source, args)
  if source ~= 0 then
    print('^1[ERROR] [Valkyrie]^7 This command can only be run from the console.')
    return
  end

  local module = modules[args[1]] or 'all'

  ExecuteCommand('exec valkyrie.cfg')

  print(format('[Valkyrie] Reloaded: %s', module))

  TriggerEvent('vac_initalize_server', module)
end, true)