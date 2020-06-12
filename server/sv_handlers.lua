--[[
    Valkyrie Anticheat
]] 
--Discord webhook
local webhook = ''
--Contact link
local contactlink = ''
--Error Logging
function ValkyrieError(message)
  local source = source
  local embed = {
    {
      ['color'] = 15007744,
      ['title'] = 'Valkyrie Error',
      ['description'] = message,
      ['footer'] = {
        ['text'] = 'Valkyrie Anticheat',
      },
    }
  }
  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
--Identifiers
function ValkyrieIdentifiers(player)
  for k, v in ipairs(GetPlayerIdentifiers(player)) do
    if string.sub(v, 1, string.len('license:')) == 'license:' then
      license = v
    elseif string.sub(v, 1, string.len('discord:')) == 'discord:' then
      discord = v
    elseif discord == nil or discord == '' then
      discord = 'Discord identifier not found.'
    elseif string.sub(v, 1, string.len('steam:')) == 'steam:' then
      steam = v
    elseif steam == nil or steam == '' then
      steam = 'Steam identifier not found.'
    end
  end
end
--Kick logging
function ValkyrieLog(message)
  local source = source
  local embed = {
    {
      ['color'] = 1,
      ['title'] = 'Valkyrie',
      ['description'] = message,
      ['footer'] = {
        ['text'] = 'Valkyrie Anticheat',
      },
    }
  }
  PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
--Kicking function
function ValkyrieKickPlayer(player, reason)
  if player == nil then
    return
    ValkyrieError('No source was set for kicking function this is a fatal error, players will not be kicked!')
  end
  if reason == nil or reason == '' then
    return
    ValkyrieError('No reason was set for kicking function this is a fatal error, players will not be kicked!')
  end
  DropPlayer(player, 'Kicked \n You have been kicked for the following reason: ' ..reason..'. \n If you think this was a mistake contact us at ' ..contactlink.. '.')
end
--Main "kicking handler" for the client.
RegisterNetEvent('Valkyrie:ClientDetection')
AddEventHandler('Valkyrie:ClientDetection', function(reason)
  local player = source
  ValkyrieKickPlayer(player, reason)
end)
--Blacklisted models vehicles, peds, and props can go here. This list WILL not kick players if they spawn them.
local BlacklistedModels = {
  [`TUG`] = true,
  [`Deluxo`] = true,
  [`ZR380`] = true,
  [`khanjali`] = true,
  [`STROMBERG`] = true,
  [`BARRAGE`] = true,
  [`TA21`] = true
}
--Banned models vehicles, peds, and props can go here. This list WILL kick players if they spawm them.
local BannedModels = { 
  [`TA21`] = true, --not sure what the hell this vehicle is
  [`Cargoplane`] = true,
  [`Avenger`] = true,
  [`Blimp2`] = true, 
  --[[
    Most of the peds used in "main stream" mod menus.
  ]]
  [`a_c_chop`] = true,
  [`ig_wade`] = true,
  [`mp_m_niko_01`] = true,
  [`s_m_m_security_01`] = true,
  [`s_m_y_swat_01`] = true,
  [`s_m_y_robber_01`] = true,
  [`u_m_y_zombie_01`] = true,

  --[[
    Most of the props used in "mainstream" mod menus. Along with some additional ones.
  ]]
  [`stt_prop_stunt_track_dwslope30`] = true,
  [`stt_prop_ramp_spiral_xxl`] = true,
  [`stt_prop_ramp_adj_flip_mb`] = true,
  [`stt_prop_ramp_adj_flip_s`] = true,
  [`stt_prop_ramp_adj_flip_sb`] = true,
  [`stt_prop_ramp_adj_hloop`] = true,
  [`stt_prop_ramp_adj_loop`] = true,
  [`stt_prop_ramp_jump_l`] = true,
  [`stt_prop_ramp_jump_m`] = true,
  [`stt_prop_ramp_jump_s`] = true,
  [`stt_prop_ramp_jump_xl`] = true,
  [`stt_prop_ramp_jump_xs`] = true,
  [`stt_prop_ramp_jump_xxl`] = true,
  [`stt_prop_ramp_multi_loop_rb`] = true,
  [`stt_prop_ramp_spiral_l`] = true,
  [`stt_prop_ramp_spiral_l_m`] = true,
  [`stt_prop_ramp_spiral_l_s`] = true,
  [`stt_prop_ramp_spiral_l_xxl`] = true,
  [`stt_prop_ramp_spiral_m`] = true,
  [`stt_prop_ramp_spiral_s`] = true,
  [`stt_prop_ramp_spiral_xxl`] = true,
  [`xs_prop_hamburgher_wl`] = true,
  [`p_spinning_anus_s`] = true,
  [`prop_windmill_01`] = true,
  [`xs_prop_chips_tube_wl`] = true,
  [`xs_prop_plastic_bottle_wl`] = true,
  [`prop_weed_01`] = true,
  [`prop_fnclink_05crnr1`] = true,
  [`sr_prop_spec_tube_xxs_01a `] = true
}
--[[
  Handler for checking then deleting blacklisted/banned models.
]]
AddEventHandler('entityCreating', function(entity)
  if BlacklistedModels[GetEntityModel(entity)] then
    CancelEvent()
  end
  if BannedModels[GetEntityModel(entity)] then
    local entityOwner = NetworkGetEntityOwner(entity)
    if entityOwner == nil or entityOwner == '' then
      return 
    end
    ValkyrieIdentifiers(entityOwner)
    ValkyrieLog('**Player:** ' ..GetPlayerName(entityOwner).. '\n**' ..license.. '**\n**' ..discord.. '**\n**' ..steam.. '**\n Was kicked for spawning a blacklisted object.')
    ValkyrieKickPlayer(entityOwner, 'Banned Model')
    CancelEvent()
  end
end)
--List of blocked server events
local _blockedServerEvents  = {
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
--Handler and iterator for the above blocked server events.
for k, eventName in ipairs(_blockedServerEvents) do
  RegisterNetEvent(eventName)
  AddEventHandler(eventName, function()
    local _source = source
    ValkyrieIdentifiers(_source)
    ValkyrieLog('**Player:** ' ..GetPlayerName(_source).. '\n**' ..license.. '**\n**' ..discord.. '**\n**' ..steam.. '**\n Was kicked from the server for triggering a blocked server event')
    --ValkyrieKickPlayer(_source, 'Blocked Event ' ..eventName.. '')
  end)
end

local _blockedExplosion = { 1, 2, 4, 5, 25, 32, 33, 35, 36, 37, 38 }
AddEventHandler('explosionEvent', function(sender, ev)
  for _, v in ipairs(_blockedExplosion) do
    if ev.damageScale <= 0 or ev.isInvisible == true or ev.isAudible == false then
      return
    end
    if ev.explosionType == v and ev.damageScale >= 1 then
      ValkyrieIdentifiers(sender)
      ValkyrieLog('**Player:** ' ..GetPlayerName(sender).. '\n**' ..license.. '**\n**' ..discord.. '**\n**' ..steam.. '**\n Created a blacklisted explosion and has been kicked.')
      ValkyrieKickPlayer(sender, 'That\'s explosive 😮')
    end
  end
end)