# Valkyrie Anticheat
Valkyrie is yet another FiveM anticheat but, unlike other services you see online and around GitHub, this one is free and open source. The intent of this project was to stop server owners from paying absurd amounts of money on paid services that are obfuscated to hell and made by "former" cheat developers the same developers that sell bypasses to their resource.

## Logging
Valkyrie has built-in logging functionally to discord using webhooks, in addition to this Valkyrie also logs every action taken to the server console. In order to use the built in logging to discord you'll need to create a [webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks'). Once you've created your webhook replace it with the empty string inside the server [config](https://github.com/NotSomething0/Valkyrie/blob/master/server/sv_config.lua#L5).

## Configuration
There are quite a few settings in both the [client](client/cl_config.lua) and [server](server/sv_config.lua) configuration files.


| Server Settings     | What it changes                                                                                    |
|---------------------|----------------------------------------------------------------------------------------------------|
| contactLink         | What is displayed at the end of a users ban/kick message |
| discordWebhook      | Where information created by the anticheat gets sent, leaving this empty will disable the feature. |
| variableDetection   | |
| blockedExplosions   | What explosions |
| blockedMessages     | . |
| whitelistedEntities | A table of all entities that are allowed to be spawned on the server. |
| useBlacklist        | Enable or disable the built in server side blacklist. |
| blacklistedPeds     | . |
| blacklistedWeapons  | . |
| blacklistedVehicles | . |
| whitelistedEntities | . |

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

Valkyrie has built-in logging functionality to Discord using webhooks. To use this, you'll need to specify a webhook inside your sv_config file. Simply replace the empty string with your Discord webhook or leave it blank to disabled the feature.
```lua
Config.DiscWebhook = ''
```

### Configuration
TODO

### TODO
Banning functionality\
More server/client side detection\
Use of screenshot-basic to weed out people that claim they 'didn't cheat'\
More staff commands\
Better and more in depth documentation  

