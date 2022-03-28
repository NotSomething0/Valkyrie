local allowedFx = {}

AddEventHandler('ptFxEvent', function(sender, data)
    if (not allowedFx[data.effectHash]) then
        CancelEvent()
    end
end)


AddEventHandler('__vac_internel:intalizeServer', function(module)
    if (module == 'ptfx' or 'all') then
        allowedFx = json.decode(GetConvar('vac:blockedFx', '[]'))
    end
end)