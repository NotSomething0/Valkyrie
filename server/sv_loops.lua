CreateThread(function()
    while true do
        ProcessAces()
        Wait(60000) --Check every minute
    end
end)
