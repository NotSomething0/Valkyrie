local IsPlayerAceAllowed = IsPlayerAceAllowed
local ValkyrieKickPlayer = ValkyrieKickPlayer
local ValkyrieBanPlayer = ValkyrieBanPlayer
local CancelEvent = CancelEvent
local GetPlayerName = GetPlayerName
-- Permission handler event.
RegisterNetEvent('Valkyrie:GetPlayerAcePermission')
AddEventHandler('Valkyrie:GetPlayerAcePermission', function()
  -- Check if the user has permission.
  if IsPlayerAceAllowed(source, 'valkyrie') then
    -- Send permssion to the client
    TriggerClientEvent('Valkyrie:RecieveClientPermission', source, true)
  else
    -- Send permssion to the client
    TriggerClientEvent('Valkyrie:RecieveClientPermission', source, false)
  end
end)
-- Client detection event.
RegisterNetEvent('Valkyrie:ClientDetection')
AddEventHandler('Valkyrie:ClientDetection', function(log, reason, bool)
  -- If no log reason is provided or the log reason provided is an empty string then set the log reason.
  if not log or log == '' then log = 'Triggerd `Valkyrie:ClientDetection`' end
  -- Check if were going to ban or kick the user.
  if bool == false then
    ValkyrieKickPlayer(source, reason, log)
  else
    ValkyrieBanPlayer(source, reason, log)
  end
end)

local whitelistedModels = Config.whitelistedEntities
-- Event for whitelisted entity checking.
AddEventHandler('entityCreating', function(entity)
  local entityModel = GetEntityModel(entity)
  if not whitelistedModels[tonumber(entityModel)] then
    CancelEvent()
  end
end)

-- A table of exploitable server events (If one of these events are in your server fix the exploit instead of removing it!)
local _blockedServerEvents = {
  "8321hiue89js",
  "adminmenu:allowall",
  "AdminMenu:giveBank",
  "AdminMenu:giveCash",
  "AdminMenu:giveDirtyMoney",
  "Tem2LPs5Para5dCyjuHm87y2catFkMpV",
  "dqd36JWLRC72k8FDttZ5adUKwvwq9n9m",
  "antilynx8:anticheat",
  "antilynxr4:detect",
  "antilynxr6:detection",
  "ynx8:anticheat",
  "antilynx8r4a:anticheat",
  "lynx8:anticheat",
  "AntiLynxR4:kick",
  "AntiLynxR4:log",
  "bank:deposit",
  "bank:withdraw",
  "Banca:deposit",
  "Banca:withdraw",
  "BsCuff:Cuff696999",
  "CheckHandcuff",
  "cuffServer",
  "cuffGranted",
  "DiscordBot:playerDied",
  "DFWM:adminmenuenable",
  "DFWM:askAwake",
  "DFWM:checkup",
  "DFWM:cleanareaentity",
  "DFWM:cleanareapeds",
  "DFWM:cleanareaveh",
  "DFWM:enable",
  "DFWM:invalid",
  "DFWM:log",
  "DFWM:openmenu",
  "DFWM:spectate",
  "DFWM:ViolationDetected",
  "dmv:success",
  "eden_garage:payhealth",
  "ems:revive",
  "esx_ambulancejob:revive",
  "esx_ambulancejob:setDeathStatus",
  "esx_billing:sendBill",
  "esx_banksecurity:pay",
  "esx_blanchisseur:startWhitening",
  "esx_carthief:alertcops",
  "esx_carthief:pay",
  "esx_dmvschool:addLicense",
  "esx_dmvschool:pay",
  "esx_drugs:startHarvestWeed",
  "esx_drugs:startTransformWeed",
  "esx_drugs:startSellWeed",
  "esx_drugs:startHarvestCoke",
  "esx_drugs:startTransformCoke",
  "esx_drugs:startSellCoke",
  "esx_drugs:startHarvestMeth",
  "esx_drugs:startTransformMeth",
  "esx_drugs:startSellMeth",
  "esx_drugs:startHarvestOpium",
  "esx_drugs:startTransformOpium",
  "esx_drugs:startSellOpium",
  "esx_drugs:stopHarvestCoke",
  "esx_drugs:stopTransformCoke",
  "esx_drugs:stopSellCoke",
  "esx_drugs:stopHarvestMeth",
  "esx_drugs:stopTransformMeth",
  "esx_drugs:stopSellMeth",
  "esx_drugs:stopHarvestWeed",
  "esx_drugs:stopTransformWeed",
  "esx_drugs:stopSellWeed",
  "esx_drugs:stopHarvestOpium",
  "esx_drugs:stopTransformOpium",
  "esx_drugs:stopSellOpium",
  "esx:enterpolicecar",
  "esx_fueldelivery:pay",
  "esx:giveInventoryItem",
  "esx_garbagejob:pay",
  "esx_godirtyjob:pay",
  "esx_gopostaljob:pay",
  "esx_handcuffs:cuffing",
  "esx_jail:sendToJail",
  "esx_jail:unjailQuest",
  "esx_jailer:sendToJail",
  "esx_jailer:unjailTime",
  "esx_jobs:caution",
  "esx_mecanojob:onNPCJobCompleted",
  "esx_mechanicjob:startHarvest",
  "esx_mechanicjob:startCraft",
  "esx_pizza:pay",
  "esx_policejob:handcuff",
  "esx_policejob:requestarrest",
  "esx-qalle-jail:jailPlayer",
  "esx-qalle-jail:jailPlayerNew",
  "esx-qalle-hunting:reward",
  "esx-qalle-hunting:sell",
  "esx_ranger:pay",
  "esx:removeInventoryItem",
  "esx_truckerjob:pay",
  "esx_skin:responseSaveSkin",
  "esx_slotmachine:sv:2",
  "esx_society:getOnlinePlayers",
  "esx_society:setJob",
  "esx_vehicleshop:setVehicleOwned",
  "hentailover:xdlol",
  "JailUpdate",
  "js:jailuser",
  "js:removejailtime",
  "LegacyFuel:PayFuel",
  "ljail:jailplayer",
  "lscustoms:payGarage",
  "mellotrainer:adminTempBan",
  "mellotrainer:adminKick",
  "mellotrainer:s_adminKill",
  "NB:destituerplayer",
  "NB:recruterplayer",
  "OG_cuffs:cuffCheckNearest",
  "paramedic:revive",
  "police:cuffGranted",
  "unCuffServer",
  "uncuffGranted",
  "vrp_slotmachine:server:2",
  "whoapd:revive",
  "gcPhone:_internalAddMessageDFWM",
  "gcPhone:tchat_channelDFWM",
  "esx_vehicleshop:setVehicleOwnedDFWM",
  "esx_mafiajob:confiscateDFWMPlayerItem",
  "_chat:messageEntDFWMered",
  "lscustoms:pDFWMayGarage",
  "vrp_slotmachDFWMine:server:2",
  "Banca:dDFWMeposit",
  "bank:depDFWMosit",
  "esx_jobs:caDFWMution",
  "give_back",
  "esx_fueldDFWMelivery:pay",
  "esx_carthDFWMief:pay",
  "esx_godiDFWMrtyjob:pay",
  "esx_pizza:pDFWMay",
  "esx_ranger:pDFWMay",
  "esx_garbageDFWMjob:pay",
  "esx_truckDFWMerjob:pay",
  "AdminMeDFWMnu:giveBank",
  "AdminMDFWMenu:giveCash",
  "esx_goDFWMpostaljob:pay",
  "esx_baDFWMnksecurity:pay",
  "esx_sloDFWMtmachine:sv:2",
  "esx:giDFWMveInventoryItem",
  "NB:recDFWMruterplayer",
  "esx_biDFWMlling:sendBill",
  "esx_jDFWMailer:sendToJail",
  "esx_jaDFWMil:sendToJail",
  "js:jaDFWMiluser",
  "esx-qalle-jail:jailPDFWMlayer",
  "esx_dmvschool:pDFWMay",
  "LegacyFuel:PayFuDFWMel",
  "OG_cuffs:cuffCheckNeDFWMarest",
  "CheckHandcDFWMuff",
  "cuffSeDFWMrver",
  "cuffGDFWMranted",
  "police:cuffGDFWMranted",
  "esx_handcuffs:cufDFWMfing",
  "esx_policejob:haDFWMndcuff",
  "bank:withdDFWMraw",
  "dmv:succeDFWMss",
  "esx_skin:responseSaDFWMveSkin",
  "esx_dmvschool:addLiceDFWMnse",
  "esx_mechanicjob:starDFWMtCraft",
  "esx_drugs:startHarvestWDFWMeed",
  "esx_drugs:startTransfoDFWMrmWeed",
  "esx_drugs:startSellWeDFWMed",
  "esx_drugs:startHarvestDFWMCoke",
  "esx_drugs:startTransDFWMformCoke",
  "esx_drugs:startSellCDFWMoke",
  "esx_drugs:startHarDFWMvestMeth",
  "esx_drugs:startTDFWMransformMeth",
  "esx_drugs:startSellMDFWMeth",
  "esx_drugs:startHDFWMarvestOpium",
  "esx_drugs:startSellDFWMOpium",
  "esx_drugs:starDFWMtTransformOpium",
  "esx_blanchisDFWMseur:startWhitening",
  "esx_drugs:stopHarvDFWMestCoke",
  "esx_drugs:stopTranDFWMsformCoke",
  "esx_drugs:stopSellDFWMCoke",
  "esx_drugs:stopHarvesDFWMtMeth",
  "esx_drugs:stopTranDFWMsformMeth",
  "esx_drugs:stopSellMDFWMeth",
  "esx_drugs:stopHarDFWMvestWeed",
  "esx_drugs:stopTDFWMransformWeed",
  "esx_drugs:stopSellWDFWMeed",
  "esx_drugs:stopHarvestDFWMOpium",
  "esx_drugs:stopTransDFWMformOpium",
  "esx_drugs:stopSellOpiuDFWMm",
  "esx_society:openBosDFWMsMenu",
  "esx_jobs:caDFWMution",
  "esx_tankerjob:DFWMpay",
  "esx_vehicletrunk:givDFWMeDirty",
  "gambling:speDFWMnd",
  "AdminMenu:giveDirtyMDFWMoney",
  "esx_moneywash:depoDFWMsit",
  "esx_moneywash:witDFWMhdraw",
  "mission:completDFWMed",
  "truckerJob:succeDFWMss",
  "99kr-burglary:addMDFWMoney",
  "esx_jailer:unjailTiDFWMme",
  "esx_ambulancejob:reDFWMvive",
  "DiscordBot:plaDFWMyerDied",
  "esx:getShDFWMaredObjDFWMect",
  "esx_society:getOnlDFWMinePlayers",
  "js:jaDFWMiluser",
  "h:xd",
  "adminmenu:setsalary",
  "adminmenu:cashoutall",
  "bank:tranDFWMsfer",
  "paycheck:bonDFWMus",
  "paycheck:salDFWMary",
  "HCheat:TempDisableDetDFWMection",
  "esx_drugs:pickedUpCDFWMannabis",
  "esx_drugs:processCDFWMannabis",
  "esx-qalle-hunting:DFWMreward",
  "esx-qalle-hunting:seDFWMll",
  "esx_mecanojob:onNPCJobCDFWMompleted",
  "BsCuff:Cuff696DFWM999",
  "veh_SR:CheckMonDFWMeyForVeh",
  "esx_carthief:alertcoDFWMps",
  "mellotrainer:adminTeDFWMmpBan",
  "mellotrainer:adminKickDFWM",
  "esx_society:putVehicleDFWMInGarage"
}
-- Loop through all events and add a handler for them.
for _, eventName in pairs(_blockedServerEvents) do
  RegisterNetEvent(eventName)
  AddEventHandler(eventName, function()
    -- Name of the user
    local playerName = GetPlayerName(source)
    -- Check to make sure the user is still in the server to prevent unnecessary calling of the ban fucntion.
    if playerName == nil then return end
    -- If the event was triggered ban the user.
    ValkyrieBanPlayer(source, 'Blocked Event', 'Blocked server event `' ..eventName.. '`')
  end)
end


local blockedExplosions = {}
local explosionTracker = {}
local allowedExplosions = GetConvarInt('maximumExplosions', 5)
AddEventHandler('explosionEvent', function(sender, ev)
  if blockedExplosions[ev.explosionType] and ev.damageScale ~= 0.0 then
    if explosionTracker[sender] == nil then
      explosionTracker[sender] = 1
    else
      explosionTracker[sender] = explosionTracker[sender] + 1
    end
    if explosionTracker[sender] >= allowedExplosions then
      ValkyrieKickPlayer(sender, 'Blocked Explosions', 'Created the maximum allowed explosions ' ..explosionTracker[sender])
    end
    CancelEvent()
  end
end)

local censoredPharases = json.decode(GetConvar('blockedPhrases', '[]'))
local filterMessages = GetConvar('filterMessages', false)
local intMessage
exports.chat:registerMessageHook(
  function(source, outMessage, hookRef)
      intMessage = outMessage.args[2]
      if filterMessages then
          for _, phrases in ipairs(censoredPharases) do
              repeat
                  if intMessage:find(phrases) then
                      intMessage = intMessage:gsub(phrases, ("#"):rep(phrases:len()))
                  end
              until (intMessage:find(phrases) == nil)
          end
          hookRef.updateMessage(
              {
                  args = {
                      outMessage.args[1],
                      intMessage
                  }
              }
          )
      else
          for _, phrases in ipairs(censoredPharases) do
              if intMessage:find(phrases) then
                  hookRef.cancel()
              end
          end
      end
  end
)

RegisterCommand('conTest', function(source, args)
  for _, index in ipairs(json.decode(GetConvar('blockedExplosions', '[]'))) do
    blockedExplosions[index] = true
  end
end, false)

AddEventHandler('', function()
end)