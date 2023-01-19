# Valkyrie Anti-cheat
An open source [FiveM](https://fivem.net) Anti-cheat, helping keep your server free of cheaters. No sketchy obfuscated files and runtime reloadable modules that keep you in control, Valkyrie aims to be your solution in preventing cheaters from wreaking havoc on your server.

# Disclaimer
- No Anti-cheat is a silver bullet, especially not the paid versions, notice how most claim 99% protection against cheaters 😕. You as the server owner/developer should be taking an active role in preventing the exploitation of resources on your server because nothing is a substitute for good programming practices.

- The `main` branch is pushed to regularly and may include breaking changes! Only code downloaded from the [releases](https://github.com/NotSomething0/Valkyrie/releases) section is considered to be stable.

## Getting started

0. Ensure you have a non modified and up-to-date version of the [cfx-server-data chat resource](https://github.com/citizenfx/cfx-server-data/tree/master/resources/%5Bgameplay%5D/chat), Valkyrie uses the `registerMessageHook` export for message filtering, which is not available in older or some modified versions of the resource.

1. Download the most recent version from the [releases](https://github.com/NotSomething0/Valkyrie/releases) section on GitHub ("Valkyrie-version.zip")

2. Extract the contents from the zip file into `resources/Valkyrie`

3. Open your `server.cfg` file, and add the following, making sure `ensure Valkyrie` is added after the config file execution.
  * `exec @Valkyrie/config.cfg`
  * `exec @Valkyrie/permission.cfg`
  * `ensure Valkyrie`

4. Save the server.cfg file then start your server

5. You're done, you've installed Valkyrie! Now move on to the configuration portion of this README

## Resource Configuration:
Note 🗒️: These settings can be updated during runtime using the `vac:sync` command or by restarting the resource 

### General (main/internal) settings
```
LOG_LEVEL {
  1 = info
  2 = trace
  3 = warn
}
```
|      ConVar     | Default | Description | Parameter |
| --------------- | ------- | ----------- | --------- |
| vac:internal:contact_link | "" | Set the contact link or string for banned players to appeal or contact administration | string |
| vac:internal:log_level | 1 | Sets the level of detail for server logs | `LOG_LEVEL` number |
| vac:main:super_jump | false | Checks all players uisng IS_PLAYER_USING_SUPER_JUMP unless the "vac:superjump" permission has been granted | bool |
| vac:main:god_mode | false | Checks all players using GET_PLAYER_INVINCIBLE unless the "vac:invincibility" permission has been granted | bool |

### Connection settings
|      ConVar     | Default | Description | Parameter |
| --------------- | ------- | ----------- | --------- |
| vac:connect:contact_link | "" | A  

### Entity Creation settings
Best Practice 📈: It is recommed to use entity lockdown (sv_entityLockdown) and your own server side creation logic for better protection. A future implementation of Valkyrie may include a rudimentary example that can be used as a guide for server owners/developers.

|      ConVar     | Default | Description | Parameter |
| --------------- | ------- | ----------- | --------- |
| vac:entity:validate_entities | false | Perform entity validation via the entityCreating event | bool |
| vac:entity:blocked_models | [] | List of model names to parse through | array |



|      ConVar     | Default | Description | Parameter(s) |
| --------------- | ------- | ----------- | ---------- |
| vac:connect:filterUsername | false | Whether to check for blocked text on connecting players username | bool |
| vac:connect:filterUsernameText | [] | Text to check for on connecting players username | list |
| vac:chat:filterMessages | false | Wether to filter incoming chat messages via a list of blocked text | bool |
| vac:chat:rlimitChat | true | Wether to rate limit incoming chat messages (spam prevention) | bool |
| vac:chat:rlReset | 30 | Time in seconds to prevent the same message from being sent | int |
| vac:cmd:requestPermission | true | Allow players to request permission for specific | bool |
| vac::ptfx:allowedFx| [] | Particle effects allowed to be used on the server | list |

## Permissions
Notes: 
  - These settings can be updated during runtime using the `vac:sync` command or by restarting the resource.
  - Valkyrie will attempt to remove as many permissions as possible however currently only those with Ace's assigned directly to their identifier can be removed.

## Access Control Entries

| Object | Description |
|--------|-------------|
| vac:ultraviolet | Bypass **everything**! Users **will not** be added to the PlayerCache registery and are seen as "invisible" to the resource |
| vac:explosion | Bypass explosion checks |


## FAQ

### Q. Why is feature x, y, z not implemented, but it is in other Anti-cheats?

TL;DR: Certain popular detection methods rely solely on the client having accurate data basic software security practices teach us to never rely on the client and is why certain features are missing. If you believe a feature is missing and could be built into the Anti-cheat without relying on the client, don't hesitate to open an issue on GitHub describing implementation details!

<b>"Injection detection" (Prohibited variable detection)</b>

Injected code on the client, usually written in a Lua source file utilizes the FiveM Lua ScRT, to gain access to GTA5 and FiveM native functions. Since the Lua runtime not specific to FiveM has a [global environment table](https://www.lua.org/pil/14.html) where all variables and their values are stored, this allows for checks on prohibited variables to be ran as shown below.

```lua
local PROHIBITED_VARIABLES <const> = {'Dopamine', 'LynxEvo', 'WarMenu'}

function checkVariables()
  for i = 1, #PROHIBITED_VARIABLES do
    local variable = PROHIBITED_VARIABLES[i]

    if (_G[variable] ~= nil) then
      TriggerServerEvent('anticheat:banMe')
    end
  end
end
```

This however can be easily bypassed, simply by setting the variable we want to *hide* to nil in the global envrionment table. This process could be easily automated as shown below.

```lua
local MY_VARIABLES <const> = {'Dopamine', 'Dopamine.openMenu'}

function hideVariables()
  for i = 1, #MY_VARIABLES do
    _G[MY_VARIABLES[i]] = nil
  end
end
```

This also commonly accompanied with modification to all resource manifest files to include a reference to the variable check file (`client_script @anticheat/check.lua`). Although small an addition like this has potentional to prevent a resource from working properly, by adding/over-writing/removing an entry from the manifest file!

<b>Detect/Prevent connections with a VPN/Proxy</b>

Valkyrie already purposefully skips over the IP addres of any player when saving identifiers. Why? IP's are generally not static and have the chance of changing at any point making them unreliable for long term identification. Certain circumstances may also require a user to use a proxy just to join the server! Lastly VPN's are massively promoted by online influencers and privacy advocates 

<b>Blocking CEF Dev Tools.</b>

FiveM uses CEF [(Chromium Embedded Framework)](https://bitbucket.org/chromiumembedded/cef/src/master/) an embedded version of Chrome allowing rendering of full-scale web pages in game. CEF like Chrome includes DevTools or 


For one reason or another users have wanted access to these tools 
For a while users have been wanting to block access to the Chrome developer tools commonly found by pressing F12 in your browser. 

CEF like most modern browsers comes with access to developer tools giving information about loaded content in the "browser". For a while now users have been wanting to block access to these tools for one reason or another and while these reasons might be valid, bypassing this check is rather easy as is outlined in this [post](https://forum.cfx.re/t/stop-blocking-devtools-on-your-server-and-how-to-bypass-the-block/1979857/). Since this feature can be easily bypassed and I belive it goes against the nature of open source work it will not be added to this resource.

<b>Abnormal Key Detection</b>
other programs like geforce now to record game use these keybinds
the keybinds can simply be changed
fivem chat can be moved with pg up/dwn 
this is j dumb


<b>OCR</b>
You can just delete the element lol 

### Q. What is Entity Lockdown

One of the many features offered by FiveM through state awareness mode aka OneSync, entity lockdown allows for the creation of objects, vehicles and peds solely by the server. This complete prevents events like mass spawning of entities however, you'll need to update all of your resources to support server side entity creation.

### Q. Dynamic Permission

Resource creators may have legitimate use cases for wanting to make a player invinciple temporarily or permanetly, thankfully the FiveM permission system is dynamic so we can add these permissions to players during runtime. Valkyrie makes this very easy to implement using the addPermission and removePermission exports respectfully, an example implementation can be seen below.

```lua
RegisterNetEvent('server:hospital:inpatient', function(data)
  if (exports["Valkyrie"]:addPermission(source, 'vac:godmode')) then
    SetPlayerInvincible(source, true)
  end

  -- event code
end)

RegisterNetEvent('server:hospital:outpatient', function(data)
  if (exports["Valkyrie"]:removePermission(source, 'vac:godmode')) then
    SetPlayerInvincible(source, false)
  end

  -- event code
end)
```
## Road Map 
[]: Removal of client side code\
[]: Switch to a more robust logging system\
[]: Vulnerability scanner


# Support
Note: To maintain compatibility support will only be provided to those using the latest recommend or above [server artifacts]('https://runtime.fivem.net/artifacts/fivem/').

Please open an issue on GitHub if you need help securing your server, want to report a critical security concern, or you're facing an issue with the resource.

![GPL v3](https://www.gnu.org/graphics/gplv3-127x51.png "GPLv3")