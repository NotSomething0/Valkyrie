RegisterNetEvent('Valkyrie:ClientDetection')
AddEventHandler('Valkyrie:ClientDetection', function(user, log, reason)
  local license = ValkyrieIdentifiers(source).license
  if not license then return end
  if not user or user == '' then user = GetPlayerName(source) end
  if not log or log == '' then log = 'Triggerd Valkyrie:ClientDetection' end
  ValkyrieLog('Player Kicked', '**Player:** ' ..user.. '\n**Reason:** ' ..log.. '\n**license:** ' ..license)
  ValkyrieKickPlayer(source, reason)
end)

AddEventHandler('entityCreating', function(entity)
  if Config._blacklistedModels[GetEntityModel(entity)] then
    CancelEvent()
  end
end)

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

for _, eventName in pairs(_blockedServerEvents) do
  RegisterNetEvent(eventName)
  AddEventHandler(eventName, function()
    local license = ValkyrieIdentifiers(source).license
    if not license then return end
    ValkyrieLog('Player Kicked', '**Player:** ' ..GetPlayerName(source).. '\n**Reason:** Blocked server event `' ..eventName.. '`\n**license:** ' ..license)
    ValkyrieKickPlayer(source, 'Blocked Event')
  end)
end

AddEventHandler('explosionEvent', function(sender, ev)
  local license = ValkyrieIdentifiers(sender).license
  if not license then return end
  for _, expNum in pairs(Config.blockedExplosion) do
    if ev.damageScale <= 0 or ev.isInvisible == true or ev.isAudible == false then return end
    if ev.explosionType == expNum and ev.damageScale >= 1 then
      CancelEvent()
      ValkyrieLog('Player Kicked', '**Player:** ' ..GetPlayerName(sender).. '\n**Reason:** Explosion created `' ..expNum.. '`\n**license:**' ..license)
      ValkyrieKickPlayer(sender, 'Blocked Explosion')
    end
  end
end)

AddEventHandler('chatMessage', function(source, author, text)
  local sender = GetPlayerName(source)
  local license = ValkyrieIdentifiers(source).license
  if not license then return end
  for _, messages in pairs(Config._blacklistedMessages) do
    if string.match(text:lower(), messages:lower()) then
      ValkyrieLog('Player kicked', '**Player:** ' ..sender.. '\n**Reason:** Blocked chat message `' ..text.. '`\n **license:** ' ..license)
      ValkyrieKickPlayer(source, 'Blocked chat message')
    end
  end
  if sender ~= author then
    CancelEvent()
    ValkyrieLog('Player kicked', '**Player:** ' ..sender.. '\n**Reason:** Tried to say: `' ..text.. '` as `' ..author..'`\n**license:** ' ..license)
    ValkyrieKickPlayer(source, 'Fake chat message')
  end
end)