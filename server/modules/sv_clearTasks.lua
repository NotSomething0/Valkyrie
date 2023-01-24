AddEventHandler('clearPedTasksEvent', function(sender, data)
    local immediately = data.immediately
    local pedHandle = NetworkGetEntityFromNetworkId(data.pedId)
    local pedOwner = NetworkGetEntityOwner(pedHandle)

    if IsPedAPlayer(pedHandle) then
        log.info(('%s attempted to clear tasks on %s, preventing sync. Immediate: %s'):format(GetPlayerName(sender), GetPlayerName(pedOwner), immediately))
        CancelEvent()
    end
end)