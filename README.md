# Valkyrie

### ⚠️Warning⚠️
This project is in beta and should not be used unless you know what you're doing!

### Description
Valkyrie is a FiveM anticheat created for the community with the intent to stop server owners from paying absurd amounts of money using other paid anticheat services. 

### Logging
Valkyrie has built-in logging functionality to Discord using webhooks. To use this, you'll need to specify a webhook in sv_functions.lua. Replace YOURWEBHOOKHERE with well your webhook feel, free to also change the color of the embed.
```lua
function ValkyrieLog(title, message)
  local embed = {
    {
      ['title'] = 'Valkyrie: ' ..title.. '',
      ['type'] = 'rich',
      ['description'] = message,
      ['color'] = 732633,
      ['author'] = {['name'] = 'Valkyrie Anticheat', ['url'] = 'https://github.com/NotSomething0', ['icon_url'] = 'https://i.imgur.com/jmYn66H.png'},
      ['footer'] = {['text'] = 'Created by NotSomething#6200 | ' ..os.date("%x (%X %p)"), ['icon_url'] = 'https://i.imgur.com/jmYn66H.png'},
    }
  }
  PerformHttpRequest('YOURWEBHOOKHERE', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
```

### Configuration
TODO

### Disclaimer
This resource does not as other services claim 'detect lua executors' as this is impossible to do server side. All these other services are doing is using the lua *environment* as it's called to detect global variables from cheat menus.

### TODO
Banning functionality
More server/client side detection
More staff commands
Better and more in depth documentation  

