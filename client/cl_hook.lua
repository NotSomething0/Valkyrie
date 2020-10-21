--[[
    The code below except for a few bits and bops isn't mine. The code was taken from https://github.com/JaredScar/Badger-Anticheat/blob/master/acloader.lua
    Thanks to JamesUK-Developer/JaredScar(Badger) <3
]]

local ProhibitedVariables = {
    'WarMenu',
    'AlikhanCheats',
    'gaybuild',
    'Plane',
    'LynxEvo',
    'FendinX',
    'Menu',
    'LR',
    'Lynx8',
    'MIOddhwuie',
    'ililililil',
    'esxdestroyv2',
    'LiLLL',
    'obl2',
    'HamMafia',
    'Absolute',
    'Absolute_function',
    'TiagoMenu',
    'SkazaMenu',
    'BrutanPremium',
    'b00mMenu',
    'Cience',
    'MaestroMenu',
    'Crusader',
    'NertigelFunc',
    'dreanhsMod',
    'nukeserver',
    'SDefwsWr',
    'FlexSkazaMenu',
    'DynnoFamily',
    'FrostedMenu',
    'frosted_config',
    'FXMenu',
    'CKgang',
    'HoaxMenu',
    'alkomenu',
    'xseira',
    'KoGuSzEk',
    'LynxSeven',
    'lynxunknowncheats',
    'MaestroEra',
    'foriv',
    'ariesMenu',
    'Ham',
    'Outcasts666',
    'b00mek',
    'redMENU',
    'rootMenu',
    'xnsadifnias',
    'LDOWJDWDdddwdwdad',
    'moneymany',
    'FlexSkazaMenu',
    'VOITUREMenu',
    'fESX',
    'dexMenu',
    'zzzt',
    'AKTeam',
    'SwagMenu',
    'Gatekeeper',
    'Dopameme',
    'Lux',
    'Swag',
    'SwagUI',
    'Nisi',
    'nigmenu0001',
    'Motion',
    'MMenu',
    'FantaMenuEvo',
    'GRubyMenu',
    'InSec',
    'AlphaVeta',
    'ShaniuMenu',
    'HamHaxia',
    'FendinXMenu',
    'AlphaV',
    'Deer',
    'NyPremium',
    'lIlIllIlI',
    'OnionUI',
    'qJtbGTz5y8ZmqcAg',
    'LuxUI',
    'JokerMenu',
    'IlIlIlIlIlI',
    'SidMenu',
    'GheMenu',
    'INFINITY',
    'klVZJu56hiZnIjg88ekXcEgegjfDvuMv83grKxQiUJJFvN8SHENeK2WaRgTTuafpGe',
    'jailServerLoop',
    'carSpamServer',
    'nofuckinglol'
}

function CheckVariables()
    for _, varNames in pairs(ProhibitedVariables) do
        if _G[varNames] ~= nil then
            TriggerServerEvent('Valkyrie:ClientDetection', GetPlayerName(PlayerId()), 'Blacklisted Variable found in: ' ..GetCurrentResourceName().. '\n **Variable Name:** ' ..varNames, 'Running Malicious Code', true)
        end
    end
end

local spawned = false
AddEventHandler('playerSpawned', function()
    if not spawned then 
        spawned = true
    end
    if spawned then
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(15000)
                CheckVariables()
            end
        end)
    end
end)