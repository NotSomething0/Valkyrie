# Valkyrie Anti-cheat
A free as in free beer open source [FiveM]('https://fivem.net') Anti-cheat. Using the most modern technologies currently available on FiveM. Valkyrie aims to be your one-stop solution to preventing modders from wreaking havoc on your server. Take peace and mind with peer reviewed code and runtime reloadable modules that keeps you in control!

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

Certain popular detection methods seen in other Anti-cheats rely solely on the client sending reliable data to the server; basic software security practices teach us to never do this, and thus is why certain detection methods are missing. If you believe a feature is missing and could easily be built into the Anti-cheat without relying on the client, don't hesitate to open an issue on GitHub describing implementation details along with a valid use case for the feature.

Blacklisted variable detection although very popular is very poor way of checking for malicious clients. Most malevolent individuals will use Lua as the programming language of choice for their runtime code; this allows us to check for global variables using the Lua global enviorment.
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
On the surface this may seem like a good idea, however you can simply set any of the global variable to nil for example `_G.WarMenu = nil` bypassing the check with one line of code. Another commonly used detection method is redefining native functions to instally ban if they're ever called. 
```lua
_G.SetEntityProofs = function(...)
  print(PlayerId().." just called this function")
end
```
Once again this may seem like a good idea, but just like we can redefine functions creators of malicious code can do the same thing
```lua
_G.SetEntityProofs = function()
	return {false, false, false, false, false, false, false, false}
end
```
easily bypassing this check in three lines of code.

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
#Road Map 
[]: Easy api to allow other resource to mainipulate certain conditions for individual players
[]: Ditch of client side code, it's useless anyway


# Support
Note: To maintain compatibility support will only be provided to those using the latest recommend or above [server artifacts]('https://runtime.fivem.net/artifacts/fivem/').

Please open an issue on GitHub if you need help securing your server, want to report a critical security concern, or you're facing an issue with the resource.

![GPL v3](https://www.gnu.org/graphics/gplv3-127x51.png "GPL v3")