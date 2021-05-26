# Valkyrie Anti-cheat

## Description

Valkyrie is another FiveM Anti-cheat but, unlike other projects you see online, this one is free and open source. The intent of this project was to stop server owners from paying absurd amounts of money on paid services that are obfuscated to hell and made by "*former*" cheat developers.

## Installation

Before we start installing Valkyrie, there are a few prerequisites first. Make sure your [server-data](https://github.com/citizenfx/cfx-server-data) folder is up to date with the latest resources as of 14/1/2021 or later. Second, update your server [artifacts](https://runtime.fivem.net/artifacts/fivem/) to the latest recommended version to ensure compatibility.

If you've checked the prerequisite above and are sure everything is up to date, we can finally start-installing Valkyrie! Since Valkyrie is written in Lua and doesn't need to be, compiled there are two ways to install it. The first and recommended way to install Valkyrie is by using git. To install Valkyrie using git, navigate to "resources/[local]" in your server-data folder and run the following command `git clone https://github.com/NotSomething0/Valkyrie.git`.
The second way to install Valkyrie is by downloading the zip file from the release section on GitHub; once you've downloaded the zip archive, extract the folder into "resources/[local]."

Now that you've downloaded Valkyrie open your server.cfg and add the following:
```
add_ace resource.Valkyrie command.exec allow
exec resources/[local]/Valkyrie/valkyrie.cfg
ensure Valkyrie
```

Note: `ensure Valkyrie` should be added below the nested config.

# Configuration

There are quite a few settings in the [configuration](valkyrie.cfg) file, which are defined below. These settings can be updated during runtime using the 'reload' command or when the server restarts.


## Server ConVars

| ConVar | Default | Description | Parameters |
|--------|---------|-------------|------------|
| _discord_webhook | none | Discord [webhook](https://bit.ly/2QN4q1N) | string |
| _blocked_expressions | none | Sets text you don't want clients to send in chat | array |
| _filter_messages | 0 | Enables message filtering, with this option enabled blocked expressions will be replaced by '#' | array |
| _blocked_explosions | none | Sets [explosion(s)](https://bit.ly/3fiJdpX) that shouldn't be networked | array |
| _maximum_allowed_explosions | 5 | Sets the maximum blocked explosion(s) a client can create before being dropped | int |
| _allowed_entities | none | Entities that can be spawned in your server | array |

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
| handlePlayer | Punishment function can be used to ban and kick someone based on last parameter | int, string, string, bool|

## Logging

Valkyrie has built-in logging functionally to discord using webhooks, in addition to this actions are also printed to the server console. In order to use the built in logging to discord you'll need to create a [webhook](https://bit.ly/2QN4q1N). Once you've created your webhook replace it with the empty string inside the [configuration](valkyrie.cfg) file.

### TODO

Add screenshot-basic functionality
