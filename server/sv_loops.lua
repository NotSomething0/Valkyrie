local GetNumPlayerIndices = GetNumPlayerIndices
local GetPlayers = GetPlayers
local GetPlayerPed = GetPlayerPed
local GetEntityMaxHealth = GetEntityMaxHealth
local IsPlayerUsingSuperJump = IsPlayerUsingSuperJump
local GetPlayerInvincible = GetPlayerInvincible
local ValkyrieBanPlayer = ValkyrieBanPlayer
local IsPlayerAceAllowed = IsPlayerAceAllowed
local pedHash = GetEntityModel
local weaponHash = GetSelectedPedWeapon
local vehicleHash = GetVehiclePedIsIn
local GetCurrentResourceName = GetCurrentResourceName
local GetNumResources = GetNumResources
local GetResourceByFindIndex = GetResourceByFindIndex
local LoadResourceFile = LoadResourceFile
local SaveResourceFile = SaveResourceFile
local useBlacklist = GetConvar('useBlacklist', 'no')
local useVariableDetection = GetConvar('variableDetection', 'no')
-- Super Jump, Max Health, Invinciple thread.
CreateThread(function()
    while true do
        Wait(2500)
        -- Check if there are any players on the server.
        if GetNumPlayerIndices() > 0 then
            -- Loop through all players on the server.
            for _, players in pairs(GetPlayers()) do
                -- Users ped
                local playerPed = GetPlayerPed(players)
                -- Check if the user set their max health to greater then or equal to 201.
                if GetEntityMaxHealth(playerPed) >= 201 then
                    ValkyrieBanPlayer(player, 'Max health', 'Set maximum health to ' ..GetEntityMaxHealth(playerPed))
                end
                --[[ 
                    Check if the user is allowed to use super jump.
                if not IsPlayerAceAllowed(players, 'valkyrie') then
                    -- Check if the user is using Super Jump.
                    if IsPlayerUsingSuperJump(players) then
                        ValkyrieBanPlayer(players, 'Super Jump', 'Super Jump')
                    end
                end
                --
                    Needs further testing.
                ]]
                -- Check if the user is allowed to bypass invincible check.
                if not IsPlayerAceAllowed(players, 'valkyrie') then
                    -- Check if the user is invincible.
                    if GetPlayerInvincible(players) then
                        ValkyrieBanPlayer(players, 'Invincible', 'GodMode: SetEntity/PlayerInvinciple native')
                    end
                end
            end
        end
    end
end)
-- Blacklist thread
local blacklistedPeds = {}
local blacklistedWeapons = {}
local blacklistedVehicles = {}

CreateThread(function()
    while true do
        if useBlacklist == 'yes' then
            -- Loop through all players on the server.
            for _, players in pairs(GetPlayers()) do
                -- Users ped
                local playerPed = GetPlayerPed(players)
                -- Check if the users player model is blacklisted.
                if blacklistedPeds[pedHash(playerPed)] then
                    -- If it is then change the ped and notify them.
                    TriggerClientEvent('Valkyrie:Blacklist:SetPlayerModel', players)
                end
                -- Check if the user is holding a blacklisted weapon.
                if blacklistedWeapons[weaponHash(playerPed)] then
                    Wait(500)
                    -- If they are remove it and send a notification.
                    RemoveWeaponFromPed(playerPed, weaponHash(playerPed))
                    TriggerClientEvent('notify', players, 'Blacklisted Weapon')
                end
                -- Check if the users vehicle is blacklisted.
                if blacklistedVehicles[GetEntityModel(vehicleHash(playerPed))] then
                    -- If it is then delete the vehicle and notifiy them.
                    DeleteEntity(vehicleHash(playerPed))
                    TriggerClientEvent('notify', players, 'Blacklisted Vehicle')
                end
            end
        else
            Wait(5000)
        end
        Wait(2000)
    end
end)
--[[
    Slightly modified version of the code in https://github.com/JaredScar/Badger-Anticheat/blob/master/server.lua
]]
-- Blacklisted variable addition/deletion thread.
local numResourcesModified = 0
local acName = GetCurrentResourceName()
CreateThread(function()
    if useVariableDetection == 'yes' then
        -- Check to make sure - isn't in the resource name.
        if not acName:find('-') then
            Wait(1000)
            -- Has the detection been added.
            local added = false
            -- Get a number for each resource.
            for i = 1, GetNumResources() do
                -- Remove last number
                local resource_id = i - 1
                -- Get the name of each resource.
                local resource_name = GetResourceByFindIndex(resource_id)
                -- Check to make sure the resource name is not equal to the anticheat name.
                if resource_name ~= acName then
                    -- Loop through each manifest.
                    for _, manifest in pairs({'fxmanifest.lua', '__resource.lua'}) do
                        -- Load manifest file for each resource.
                        local data = LoadResourceFile(resource_name, manifest)
                        -- Check to make sure the file was loaded, the content of the file is a string, and the detection hasn't already been added.
                        if data and type(data) == 'string' and string.find(data, 'client/cl_hook.lua') == nil then
                            -- Add reference to the detection.
                            data = data .. '\nclient_script "@' ..acName.. '/client/cl_hook.lua"'
                            -- Save the file.
                            SaveResourceFile(resource_name, manifest, data, -1)
                            -- Print which resource got modified to the console.
                            print('^6[INFO] [VALKYRIE]^7 Added blacklisted variable detection to: ' .. resource_name)
                            -- Add to the number of resources modified.
                            numResourcesModified = numResourcesModified + 1
                            -- Detection has been added.
                            added = true
                        end
                    end
                end
            end
            -- If the detection has been added then print to the console with the number of resources modified.
            if added then
                print('^6[INFO] [VALKYRIE]^7 Blacklisted variable detection added to ' ..numResourcesModified.. ' resource(s) restart your server.')
            end
        else
            -- If the anticheat name contains any dashes exit and print to the console as this will cause removale issues.
            return print('^1[ERROR] [VALKYRIE]^7 Resource name can not contain dashes(-) blacklisted variable detection not added.')
        end
    else
        Wait(1000)
        -- Has the detection been removed.
        local deleted = false
        -- Get a number for each resource.
        for i = 1, GetNumResources() do
            -- Remove last number
            local resource_id = i - 1
            -- Get the name of each resource.
            local resource_name = GetResourceByFindIndex(resource_id)
            -- Check to make sure the resource name is not equal to the anticheat name.
            if resource_name ~= acName then
                -- Loop through each manifest.
                for _, manifest in pairs({'fxmanifest.lua', '__resource.lua'}) do
                    -- Load manifest file for each resource.
                    local data = LoadResourceFile(resource_name, manifest)
                    -- Check to make sure the file was loaded, the content of the file is a string, and the detection hasn't already been removed.
                    if data and type(data) == 'string' and string.find(data, 'client/cl_hook.lua') ~= nil then
                        -- Remove reference to the detection.
                        local removed = string.gsub(data, 'client_script "%@' ..acName.. '%/client%/cl_hook.lua"', "")
                        -- Save the file.
                        SaveResourceFile(resource_name, manifest, removed, -1)
                        -- Print which resource got modified to the console.
                        print('^6[INFO] [VALKYRIE]^7 Removed blacklisted variable detection from: ' .. resource_name)
                        -- Add to the number of resources modified.
                        numResourcesModified = numResourcesModified + 1
                        -- Detection has been removed.
                        deleted = true
                    end
                end
            end
        end
        -- Check if the detection has been removed and the number of resources modified isn't zero.
        if deleted and numResourcesModified > 0 then
            -- Print the information to the console.
            print('^6[INFO] [Valkyrie]^7 Blacklisted variable detection removed from ' ..numResourcesModified.. ' resource(s) restart your server.')
        end
    end
end)

local switch = function(choice)
    print('started switch function')
    choice = tostring(choice)

    case = {
        ['blacklist'] = function()
            useBlacklist = GetConvar('useBlacklist', 'no')
            if useBlacklist then
                blacklistedPeds = {}
                for _, pedModel in ipairs(json.decode(GetConvar('blacklistedPeds', '[]'))) do
                    blacklistedPeds[GetHashKey(pedModel)] = true
                end
                blacklistedVehicles = {}
                for _, vehicleModel in ipairs(json.decode(GetConvar('blacklistedVehicles', '[]'))) do
                    blacklistedVehicles[GetHashKey(vehicleModel)] = true
                end
                blacklistedWeapons = {}
                for _, weaponModel in ipairs(json.decode(GetConvar('blacklistedWeapons', '[]'))) do
                    blacklistedWeapons[GetHashKey(weaponModel)] = true
                end
            end
        end,

        ['variableDetection'] = function()
            useVariableDetection = GetConvar('variableDetection', 'no')
        end,

        ['default'] = function()
        useBlacklist = GetConvar('useBlacklist', 'no')
        if useBlacklist then
            blacklistedPeds = {}
            for _, pedModel in ipairs(json.decode(GetConvar('blacklistedPeds', '[]'))) do
                blacklistedPeds[GetHashKey(pedModel)] = true
            end
            blacklistedVehicles = {}
            for _, vehicleModel in ipairs(json.decode(GetConvar('blacklistedVehicles', '[]'))) do
                blacklistedVehicles[GetHashKey(vehicleModel)] = true
            end
            blacklistedWeapons = {}
            for _, weaponModel in ipairs(json.decode(GetConvar('blacklistedWeapons', '[]'))) do
                blacklistedWeapons[GetHashKey(weaponModel)] = true
            end
        end
        useVariableDetection = GetConvar('variableDetection', 'no')
        end
    }

    if case[choice] then
        case[choice]()
    else
        case['default']()
    end
end

local configPath = GetConvar('pathToConfig', nil)
AddEventHandler('__valkyrie__internal', function(module)
    if type(configPath) == 'string' and configPath ~= '' then
        ExecuteCommand('exec ' ..configPath)
    end
    print(switch(module))
end)