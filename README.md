# Valkyrie

### ⚠️Warning⚠️
This build is considered depreciated and will no longer recieve support 

### Description
Valkyrie is a FiveM anticheat created for the community with the intent to stop server owners from paying absurd amounts of money using other paid anticheat services.

### Logging
Valkyrie has built-in logging functionality to Discord using webhooks. To use this, you'll need to specify a webhook inside your sv_config file. Simply replace the empty string with your Discord webhook or leave it blank to disabled the feature.
```lua
Config.DiscWebhook = ''
```

### Configuration
TODO

### Disclaimer
This resource does not as other services claim 'detect lua executors' as this is impossible to do server side. All these other services are doing is using the lua *environment* as it's called to detect global variables from cheat menus.

### TODO
Banning functionality\
More server/client side detection\
Use of screenshot-basic to weed out people that claim they 'didn't cheat'\
More staff commands\
Better and more in depth documentation  
