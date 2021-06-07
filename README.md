# Valkyrie Anti-cheat

## Description

Valkyrie is another FiveM Anti-cheat but, unlike other projects you see online, this one is free and open source. The intent of this project was to stop server owners from paying absurd amounts of money on paid services that are obfuscated to hell and made by "*former*" cheat developers.

## Installation

Before we start installing Valkyrie, there are a few prerequisites first. Make sure your [server-data](https://github.com/citizenfx/cfx-server-data) folder is up to date with the latest resources as of 14/1/2021 or later. Second, update your server [artifacts](https://runtime.fivem.net/artifacts/fivem/) to the latest recommended version to ensure compatibility.

If you've checked the prerequisite above and are sure everything is up to date, we can finally start-installing Valkyrie! Since Valkyrie is written in Lua and doesn't need to be, compiled there are two ways to install it. The first and recommended way to install Valkyrie is by using git. To install Valkyrie using git, navigate to "resources/[local]" in your server-data folder and run the following command `git clone https://github.com/NotSomething0/Valkyrie.git`.
The second way to install Valkyrie is by downloading the zip file from the release section on GitHub; once you've downloaded the zip archive, extract the folder into "resources/[local]"

Now that you've downloaded Valkyrie open your server.cfg and add the following:
```
add_ace resource.Valkyrie command.exec allow
add_ace resource.Valkyrie command.set allow
add_ace resource.Valkyrie command.setr allow
exec resources/[local]/Valkyrie/valkyrie.cfg
ensure Valkyrie
```

Note: `ensure Valkyrie` should be added below the nested config and ace permissions

# Configuration

There are quite a few settings in the [configuration](valkyrie.cfg) file, which are defined below. These settings can be updated during runtime using the 'reload' command or when the server restarts.

## Server ConVars

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

Valkyrie has built-in logging functionally to discord using webhooks, in addition to this actions are also printed to the server console. In order to use the built in logging to discord you'll need to create a [webhook](https://bit.ly/2QN4q1N). Once you've created your webhook replace it with the empty string inside the [configuration](valkyrie.cfg) file.

### TODO

Add screenshot-basic functionality
