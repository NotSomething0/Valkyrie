# Valkyrie Anticheat
Valkyrie is yet another FiveM anticheat but, unlike other services you see online and around GitHub, this one is free and open source. The intent of this project was to stop server owners from paying absurd amounts of money on paid services that are obfuscated to hell and made by "former" cheat developers the same developers that sell bypasses to their resource.

## Logging
Valkyrie has built-in logging functionally to discord using webhooks, in addition to this Valkyrie also logs every action taken to the server console. In order to use the built in logging to discord you'll need to create a [webhook]('https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks'). Once you've created your webhook replace it with the empty string inside the server [config]('https://github.com/NotSomething0/Valkyrie/blob/master/server/sv_config.lua#L5').

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

