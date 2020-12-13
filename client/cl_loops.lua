local PlayerPedId = PlayerPedId
local PlayerId = PlayerId
local GetPlayerName = GetPlayerName
local Wait = Wait
local GetPlayerInvincible_2 = GetPlayerInvincible_2
local SetEntityHealth = SetEntityHealth
local GetEntityHealth = GetEntityHealth
local NetworkIsInSpectatorMode = NetworkIsInSpectatorMode
local GetEntityCoords = GetEntityCoords
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetVehicleTopSpeedModifier = GetVehicleTopSpeedModifier
local GetVehicleCheatPowerIncrease = GetVehicleCheatPowerIncrease
-- Does the user have elevated permissions
hasElevatedPermission = nil
-- Handler for receiving permission level of this user.
RegisterNetEvent('Valkyrie:RecieveClientPermission')
AddEventHandler('Valkyrie:RecieveClientPermission', function(state)
    hasElevatedPermission = state
end)
-- Handler for requesting user permission.
AddEventHandler('onClientMapStart', function()
    TriggerServerEvent('Valkyrie:GetPlayerAcePermission')
end)
-- Has the player spawned.
spawned = false
AddEventHandler('playerSpawned', function()
    -- Check if the player has spawned before.
    if not spawned then
        -- If they haven't then set spawned to true.
        spawned = not spawned
    end
end)
-- Thread for updating global user variables.
CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        playerId = PlayerId()
        playerName = GetPlayerName(playerId)
        Wait(2500)
    end
end)
-- Number of godmode strikes.
local totalGodmodeStrikes = 0
-- Thread for checking if a user is Invincible 
CreateThread(function()
    local maxStrikes = Config.MaxGodModeStrikes 
    -- Is the check enabled.
    if Config.GodModeCheck then
        -- If it is then wait to recive the users permission level.
        while hasElevatedPermission == nil do
            Wait(500)
        end
        -- Check if they have elevated permission.
        if hasElevatedPermission == false then
            -- If they do create a new loop.
            while true do
                -- How long to wait before checking.
                local delayTime = Config.GodModeThreadDelay 
                Wait(delayTime)
                -- Check if the player is Invincible  
                if GetPlayerInvincible_2(playerId) then
                    -- If they are ban them.
                    TriggerServerEvent('Valkyrie:ClientDetection', 'GodMode: SetEntity/PlayerInvincible native', 'Invincible', true)
                end
                -- The users current health.
                local currentHealth = GetEntityHealth(playerPed)
                -- Set the users health 
                SetEntityHealth(playerPed, currentHealth - 2)
                Wait(50)
                -- Check if the player is dead.
                if not IsPlayerDead(playerId) then
                    -- If they aren't then check to make sure their health is still equal to their currentHealth and make sure their health isn't zero.
                    if GetEntityHealth(playerPed) == currentHealth and GetEntityHealth(playerPed) ~= 0 then
                        -- If none of these check out add to GodMode strikes.
                        totalGodmodeStrikes = totalGodmodeStrikes + 1
                    end
                    -- Check if the user has exceeded the maximum allowed strikes.
                    if totalGodmodeStrikes >= maxStrikes then
                        -- If they did then ban them.
                        TriggerServerEvent('Valkyrie:ClientDetection', 'GodMode: (SetEntityHealth) native loop', 'Invincible', true)
                    -- Check if their health is less then their current health by 2
                    elseif GetEntityHealth(playerPed) == currentHealth - 2 then
                        -- If it is then add their health back.
                        SetEntityHealth(playerPed, GetEntityHealth(playerPed) + 2)
                    end
                end
            end
        else
            -- If they have elevated permission then print that to the console.
            print('^6[INFO] [VALKYRIE]^7 Terminated GodMode thread user ' ..playerName.. ' has elevated permission.')
        end
    end
    return
end)
-- Number of spectator strikes.
local totalSpectatorStrikes = 0
-- Thread for checking if a user is spectating.
CreateThread(function()
    -- The maximum distance a players camera can be from them.
    local maxCamDistance = Config.MaxCamCoords
    -- 
    local maxSpectatorStrikes = Config.MaxSpectatorStrikes
    -- Is the check enabled.
    if Config.SpectatorCheck then
        -- Wait until player has spwned and permissions have been received.
        while spawned == false and hasElevatedPermission == nil do
            Wait(500)
        end
        -- Check if the user is allowed to spectate.
        if hasElevatedPermission == false then
            while true do
                Wait(2000)
                -- Check if the user is in spectator mode.
                if NetworkIsInSpectatorMode() then
                    -- Add to the number of spectator strikes if they are.
                    totalSpectatorStrikes = totalSpectatorStrikes + 1
                end
                -- Users camera coordinates from their ped.
                local camCoords = #(GetEntityCoords(playerPed) - GetFinalRenderedCamCoord())
                -- Check if the camera coordinates are equal to or greater then the max distance.
                if camCoords >= maxCamDistance then
                    -- Add to the number of spectator strikes if they are.
                    totalSpectatorStrikes = totalSpectatorStrikes + 1
                end
                -- Check if the number of spectator strikes is greater then the maximum allowed strikes.
                if totalSpectatorStrikes >= maxSpectatorStrikes then
                    -- If they are then kick the user.
                    TriggerServerEvent('Valkyrie:ClientDetection', 'Spectating: Exceeded max spectator strikes.', 'Spectating', false)
                end
            end
        -- If they are allowed to spectate then exit and print to that users console.
        else
            print('^6[INFO] [VALKYRIE]^7 Terminated Spectator thread user ' ..playerName.. ' has elevated permission.')
        end
    end
    return
end)
-- Thread for checking if a user is using vehicle speed modifiers.
CreateThread(function()
    -- Maximum multiplier that can be applied to a vehicle.
    local maxModifier = Config.MaximumSpeedModifier
    -- Is the check enabled.
    if Config.SpeedModifierCheck then
        -- Check if the maximum modifier is equal to or greater than two.
        if maxModifier >= 2 then
            while true do
                Wait(2000)
                -- The players current vehicle
                local playerVehicle = GetVehiclePedIsIn(playerPed, false)
                -- Check if the players is in a vehicle.
                if playerVehicle ~= 0 then
                    -- Check if the users vehicle speed modifier is greater then the maximum allowed modifier.
                    if GetVehicleTopSpeedModifier(playerVehicle) > maxModifier then
                        -- If it is then kick the user.
                        TriggerServerEvent('Valkyrie:ClientDetection', 'Vehicle Top Speed Modifier: ModifyVehicleTopSpeed native.', 'Spectating', false)
                    end
                    -- Check if the users vehicle cheat power is greater then the maximum allowed modifier.
                    if GetVehicleCheatPowerIncrease(playerVehicle) > maxModifier then
                        -- If it is then kick the user.
                        TriggerServerEvent('Valkyrie:ClientDetection', 'Vehicle Top Speed Modifier: SetVehicleCheatPowerIncrease native.', 'Spectating', false)
                    end
                end
            end
        -- If it isn't enabled then exit and print to the users console.
        else
            print('^6[INFO] [VALKYRIE]^7 Terminated Speed Modifier Thread improper configuration, MaximumSpeedModifier cannot be less than or equal to one.')
        end
    end
    return
end)