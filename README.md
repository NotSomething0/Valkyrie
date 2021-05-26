# Valkyrie Anticheat

## Description

Valkyrie is yet another FiveM anticheat but, unlike other services you see online and around GitHub, this one is free and open source. The intent of this project was to stop server owners from paying absurd amounts of money on paid services that are obfuscated to hell and made by "*former*" cheat developers.

## Installation

Before we start installing Valkyrie, there are a few prerequisites first. Make sure your [server-data](https://github.com/citizenfx/cfx-server-data) folder is up to date with the latest resources as of 14/1/2021 or later. Second, update your server [artifacts](https://runtime.fivem.net/artifacts/fivem/) to the latest recommended version to ensure compatibility. Optionally if you're using the [screenshot-basic](https://github.com/citizenfx/screenshot-basic) functionality, make sure that it is updated as of 13/1/2021 or later.

If you've checked the prerequisite above and are sure everything is up to date, we can finally start-installing Valkyrie! Since Valkyrie is written in Lua and doesn't need to be, compiled there are two ways to install it. The first and recommended way to install Valkyrie is by using git. To install Valkyrie using git, navigate to "resources/[local]" in your server-data folder and run the following command `git clone https://github.com/NotSomething0/Valkyrie.git`.
The second way to install Valkyrie is by downloading the zip file from the release section on GitHub; once you've downloaded the zip archive, extract the folder into "resources/[local]."

Now that you've downloaded the resource go, to your server.cfg and add the following to it:
```
add_ace resource.Valkyrie command.exec allow
exec resources/[local]/Valkyrie/valkyrie.cfg
ensure Valkyrie
```
Note these can be added anywhere in the server config so long as `ensure Valkyrie` is below the other two additions.

## Configuration

There are quite a few settings in the [configuration](valkyrie.cfg) file, which are defined below. These settings can be updated during runtime or when the server restarts.

| Server Settings     | What it changes                                                                                         |
|---------------------|---------------------------------------------------------------------------------------------------------|
| pathToConfig        | Where the config file is located this is used to allow reloading during runtime.                        |
| contactLink         | What (usually a link) is displayed at the end of a users ban/kick message.                              |
| discordWebhook      | What discord webhook url to send information to when action is taken on a user.                         |
| variableDetection   | Whether blacklisted variable detection is enabled.                                                      |
| blockedExplosions   | Which explosions aren't allowed to be networked, a list of all explosions can be found [here](https://github.com/citizenfx/fivem/blob/b58143c81337a41ff0427fe4fe46697edcab6d46/code/client/clrcore/External/World.cs#L242).           |
| maximumExplosions   | The maximum number of blocked explosions allowed to be created before the creator is kicked.            |
| blockedPhrases      | The phrases or words that aren't allowed to be said in the server.                                      |
| filterMessages      | Enables or disables message filtration if this is enabled blocked messages will be replaced by a #.     |
| whitelistedEntities | A table of all entities that are allowed to be spawned on the server.                                   |
| useBlacklist        | Enables or disables the built in server side blacklist.                                                 |
| blacklistedPeds     | A table of peds that players aren't allowed to spawn as.                                                |
| blacklistedWeapons  | A table of weapons players aren't allowed to have.                                                      |
| blacklistedVehicles | A table of vehicles players aren't allowed to be in.                                                    |

| Client Settings     | What it changes                          |
|---------------------|------------------------------------------|
| spectatorCheck      | . |
| maxCameraCoords     | . |
| maxSpectatorStrikes | . |
| GodModeCheck        | . |
| GodModeThreadDelay  | . |
| MaxGodModeStrikes   | . |
| SpeedModifierCheck  | . |
| maxSpeedModifier    | . |

## Logging

Valkyrie has built-in logging functionally to discord using webhooks, in addition to this actions are also printed to the server console. In order to use the built in logging to discord you'll need to create a [webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks'). Once you've created your webhook replace it with the empty string inside the [configuration](valkyrie.cfg) file.

### TODO

Add client side reload functionally\
Add screenshot-basic functionality
