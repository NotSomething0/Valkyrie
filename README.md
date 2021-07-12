# Valkyrie Anti-cheat

## Description

Valkyrie is an open source [FiveM](https://fivem.net) Anti-cheat. The intent of this project is to prevent server owners from being exploited by "*former*" cheat developers, who are asking for absurd amounts of money on their obfuscated products.

## Installation

Note: Before installation, ensure that both your [server artifacts](https://runtime.fivem.net/artifacts/fivem/) and [server-data](https://github.com/citizenfx/cfx-server-data) resources are up-to-date.

1. Download the most recent version from the 'Releases' section on GitHub ("Valkyrie-version.zip")

2. Extract the contents from the zip file into `resources/Valkyrie`

3. Once you've extracted the files, move the `valkyrie.cfg` file to the same folder where your `server.cfg` is located

4. Open your `server.cfg` file, and add both `exec valkyrie.cfg` & `ensure Valkyrie`

5. Save the server.cfg file then start your server

6. You're done, you've installed Valkyrie! Now move on to the configuration portion of this README

# Configuration

There are quite a few settings in the [configuration](valkyrie.cfg) file, which are defined below. These settings can be updated during runtime using the 'reload' command or by restarting the resource.

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

Valkyrie has built-in logging functionally to discord using webhooks. In order to use the built in logging you'll need to create a [webhook](https://bit.ly/2QN4q1N). Once you've created your webhook replace it with the empty string inside the [configuration](valkyrie.cfg) file.
