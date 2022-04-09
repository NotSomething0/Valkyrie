# Valkyrie Anti-cheat
An open source [FiveM]('https://fivem.net') Anti-cheat. Using the most modern technologies currently available on FiveM, Valkyrie aims to be your solution to preventing modders from wreaking havoc on your server. No sketchy obfuscated files and runtime reloadable modules that keep you in control.

## Disclaimer
No Anti-cheat is a silver bullet, especially not the paid versions, notice how mpst claim 99% protection against cheaters 😕. You as the server owner/developer should be taking an active role in preventing the exploitation of resources on your server because nothing is a substitute for good programming practices.

## Installation
Note: Before installation, ensure that your [server-data](https://github.com/citizenfx/cfx-server-data) resources are up-to-date. Valkyrie uses the registerMessageHook export provided by the default chat resource for message filtering, which is not available in older versions of the chat resource.

1. Download the most recent version from the 'Releases' section on GitHub ("Valkyrie-version.zip")

2. Extract the contents from the zip file into `resources/Valkyrie`

3. Once you've extracted the files, move the `valkyrie.cfg` file to the same folder where your `server.cfg` is located

4. Open your `server.cfg` file, and add both `exec valkyrie.cfg` & `ensure Valkyrie`

5. Save the server.cfg file then start your server

6. You're done, you've installed Valkyrie! Now move on to the configuration portion of this README

# Configuration
Note: These settings can be updated during runtime using the `reload` command or by restarting the resource 

## Server Settings

|      ConVar     | Default | Description | Parameters |
| --------------- | ------- | ----------- | ---------- |
| vac_setWebhook  | false   | Discord [webhook](https://bit.ly/2QN4q1N) | string |
| vac_blockedText | {}      | Text 


| ConVar | Default | Description | Parameters |
|--------|---------|-------------|------------|
| _discord_webhook | none | Discord [webhook](https://bit.ly/2QN4q1N) | string |
| _blocked_expressions | none | Sets text to be filtered out of chat messages if _filter_messages is set to one. If _filter_messages is set to zero, chat message(s) containing any blocked text will be prevented from populating. | array |
| _filter_messages | 0 | Enable message [filtering](https://imgur.com/a/20B68iS) | array |
| _blocked_explosions | none | Sets [explosion(s)](https://bit.ly/3fiJdpX) to cancel. Note: Canceling an explosion only prevents it from being routed the owner; of the explosion(s) will still see it but, other clients won't. | array |
| _maximum_allowed_explosions | 5 | Sets the maximum amount of blocked explosion(s) a client can create before being dropped | int |
| _allowed_entities | none | Set entities that can be spawned in the server. Note: entity lockdown is a much better solution to prevent modders from spawning props. | array |

## Client ConVars

| ConVar | Default | Description | Parameters |
|--------|---------|-------------|------------|
| _maximum_godmode_strikes | 5 | Sets the maximum strikes a client can recieve from the GodMode thread | int |
| _maximum_spectator_strikes | 5 | Sets the maximum strikes a client can recieve from the spectator thread | int |
| _maximum_cam_distance | 200 | Sets the maximum distance a clients camera is allowed to be from their ped | int |
| _maximum_modifier | 2 | Sets the maximum amount of speed modification that can be added to a vehicle | int |

## Exports

| Export | Description | Parameters |
|--------|-------------|------------|
| getAllPlayerIdentifiers | Returns a json string with a clients identifier(s) and token(s) | bool, int |
| banPlayer | Used to ban clients, parameter usage can be found [here](https://bit.ly/2TQvVc1)  | int, string, int, string |
| kickPlayer | Used to kick clients, parameter usage can be found [here](https://bit.ly/3gcNEle) | int, string |

## Logging

Valkyrie has built-in logging functionally to discord using webhooks. In order to use the built in logging you'll need to create a [webhook](https://bit.ly/2QN4q1N). Once you've created your webhook replace it with the empty string inside the [configuration](valkyrie.cfg) file.

## FAQ

### Q. Why is feature x, y, z not implemented, but it is in other Anti-cheats?

TL;DR: Certain popular detection methods seen in other Anti-cheats rely solely on the client sending reliable data to the server; basic software security practices teach us to never do this, and thus is why certain detection methods are missing. If you believe a feature is missing and could be built into the Anti-cheat without relying on the client, don't hesitate to open an issue on GitHub describing implementation details along with a valid use case for the feature.

<b>Blocked variable detection: A very popular yet poor way of checking for malicious clients.</b>

  Attacker code ran in game is usually written in Lua in order to utilize the FiveM Lua Scripting Runtime. This allows developers access to the Lua global environment ([_G](https://www.lua.org/pil/14.html)) a central storage spot for all global variables currently initialized in the runtime. Which leads to developers looking for certain blocked variables, however this can be easily bypassed and leads to a lot of file manipulation of system resources, which is heavily discouraged.

  Checking for blocked variables:
  ```lua
  local ProhibitedVariables = {
    'WarMenu',
    'Plane',
    'LynxEvo',
    'AlphaV',
    'Dopamine'
  }

  function CheckVariables()
      for _, varName in pairs(ProhibitedVariables) do
          if _G[varName] ~= nil then
              print('Prohibited variable found ' .. _G[varName])
          end
      end
  end
  ```
  It may seem like at least on the surface like a good idea however this would require us and moreover yourself to maintain a curated list of variables considred to be "bad" or "malicious" and isn't realistically an option. Moreover the value of each variable can easily be changed to nil bypassing the entire check.
  
  Bypassing blocked variable detection:
  ```lua
  _G['WarMenu'] = nil
  ```

<b>Blocking NUI Developer Tools: A naive way to block access to client side files.</b>

  FiveM uses CEF (Chromium Embed Framework) an embedded "browser" allowing for full scale web pages to be created in game. Being that CEF is in simple terms a browser it also includes access to the Chrome developer tools you usually access by pressing F12, users have been trying to block access to these tools because of either a fear of code being stolen or their code being exploited for malicious purposes. A check will not be put in place for this because it only harms those who are curious and goes against this projects core values.

### Q. What is Entity Lockdown

One of the many features offered by FiveM through state awareness mode aka OneSync, entity lockdown allows for the creation of objects, vehicles and peds solely by the server. This complete prevents events like mass spawning of entities however, you'll need to update all of your resources to support server side entity creation.

### Q. Temporary Permission

Certain resources including your own may want to set a player as temporarily or permanently invincible, Valkyrie makes this quick and easy only adding a few additional steps into your programming logic. Properly setting a player invincible with Valkyrie can only be done server-side, and therefore requires OneSync to be set to on. The following example provides basic syntax for setting up temporary invincibility.  

```lua
RegisterNetEvent('myEvent', function()
  -- Temporary don't need a reliable identifier
  local playerIdentifier = GetAllPlayerIdentifiers(source)[1]
  local playerPed = GetPlayerPed(source)
  local playerCoords = GetEntityCoords(playerPed)
  local locationCoords = vector3(0, 0, 0)

  -- Check that we're allowed invincibllity 
  if (#(playerCoords - locationCoords) <= 100) then
    ExecuteCommand(('add_principal identifier.%s vac.godMode'):format(playerIdentifier))

    SetPlayerInvincible(source, true)
    --other code
  end

  SetPlayerInvincible(source, false)
  ExecuteCommand(('remove_principal identifier.%s vac.godMode'))
end)
```
## Road Map 
[]: A simple API for easy resource integration\
[]: Removal of client side code\
[]: Switch to a more robust logging system\
[]: Vulnerability scanner


# Support
Note: To maintain compatibility support will only be provided to those using the latest recommend or above [server artifacts]('https://runtime.fivem.net/artifacts/fivem/').

Please open an issue on GitHub if you need help securing your server, want to report a critical security concern, or you're facing an issue with the resource.

![GPL v3](https://www.gnu.org/graphics/gplv3-127x51.png "GPL v3")