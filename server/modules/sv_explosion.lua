-- Copyright (C) 2019 - 2023  NotSomething

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local RESOURCE_NAME <const> = GetCurrentResourceName()
local EXPLOSION_TAG_TO_NAME <const> = {
  [0] = 'DONTCARE',
  [1] = 'GRENADE',
  [2] = 'GRENADELAUNCHER',
  [3] = 'STICKYBOMB',
  [4] = 'MOLOTOV',
  [5] = 'ROCKET',
  [6] = 'TANKSHELL',
  [7] = 'HI_OCTANE',
  [8] = 'CAR',
  [9] = 'PLANE',
  [10] = 'PETROL_PUMP',
  [11] = 'BIKE',
  [12] = 'DIR_STEAM',
  [13] = 'DIR_FLAME',
  [14] = 'DIR_WATER_HYDRANT',
  [15] = 'DIR_GAS_CANISTER',
  [16] = 'BOAT',
  [17] = 'SHIP_DESTROY',
  [18] = 'TRUCK',
  [19] = 'BULLET',
  [20] = 'SMOKE_GRENADE_LAUNCHER',
  [21] = 'SMOKE_GRENADE',
  [22] = 'BZGAS',
  [23] = 'FLARE',
  [24] = 'GAS_CANISTER',
  [25] = 'EXTINGUISHER',
  [26] = 'PROGRAMMABLEAR',
  [27] = 'TRAIN',
  [28] = 'BARREL',
  [29] = 'PROPANE',
  [30] = 'BLIMP',
  [31] = 'DIR_FLAME_EXPLODE',
  [32] = 'TANKER',
  [33] = 'PLANE_ROCKET',
  [34] = 'VEHICLE_BULLET',
  [35] = 'GAS_TANK',
  [36] = 'BIRD_CRAP',
  [37] = 'RAILGUN',
  [38] = 'BLIMP2',
  [39] = 'FIREWORK',
  [40] = 'SNOWBALL',
  [41] = 'PROXMINE',
  [42] = 'VALKYRIE_CANNON',
  [43] = 'AIR_DEFENCE',
  [44] = 'PIPEBOMB',
  [45] = 'VEHICLEMINE',
  [46] = 'EXPLOSIVEAMMO',
  [47] = 'APCSHELL',
  [48] = 'BOMB_CLUSTER',
  [49] = 'BOMB_GAS',
  [50] = 'BOMB_INCENDIARY',
  [51] = 'BOMB_STANDARD',
  [52] = 'TORPEDO',
  [53] = 'TORPEDO_UNDERWATER',
  [54] = 'BOMBUSHKA_CANNON',
  [55] = 'BOMB_CLUSTER_SECONDARY',
  [56] = 'HUNTER_BARRAGE',
  [57] = 'HUNTER_CANNON',
  [58] = 'ROGUE_CANNON',
  [59] = 'MINE_UNDERWATER',
  [60] = 'ORBITAL_CANNON',
  [61] = 'BOMB_STANDARD_WIDE',
  [62] = 'EXPLOSIVEAMMO_SHOTGUN',
  [63] = 'OPPRESSOR2_CANNON',
  [64] = 'MORTAR_KINETIC',
  [65] = 'VEHICLEMINE_KINETIC',
  [66] = 'VEHICLEMINE_EMP',
  [67] = 'VEHICLEMINE_SPIKE',
  [68] = 'VEHICLEMINE_SLICK',
  [69] = 'VEHICLEMINE_TAR',
  [70] = 'SCRIPT_DRONE',
  [71] = 'RAYGUN',
  [72] = 'BURIEDMINE',
  [73] = 'SCRIPT_MISSILE',
  [74] = 'RCTANK_ROCKET',
  [75] = 'BOMB_WATER',
  [76] = 'BOMB_WATER_SECONDARY',
  [77] = 'MINE_CNCSPIKE',
  [78] = 'BZGAS_MK2',
  [79] = 'FLASHGRENADE',
  [80] = 'STUNGRENADE',
  [81] = 'CNC_KINETICRAM',
  [82] = 'SCRIPT_MISSILE_LARGE',
  [83] = 'SUBMARINE_BIG',
  [84] = 'EMPLAUNCHER_EMP'
}

local protectedExplosiveZones = {}

local function initializeProtectedZones()
  local protectedZones, _, errMsg = json.decode(GetConvar('vac:explosion:protected_zones', '{}'))

  if not protectedZones or errMsg then
    error(('An error occured while trying to parse protected explosive zones. Unable to parse from json to Lua object (%s), please check your configuration and try again.'):format(errMsg))
  end

  for i = 1, #protectedZones do
    local zoneCoords = protectedZones[i].coords
    local zoneRadius = protectedZones[i].radius

    if not zoneCoords or not zoneRadius then
      error(('An error occured while trying to parse protected explosive zones. Zone %d# Coords %s Radius %s is not valid, please check your configuration and try again.'):format(i, zoneCoords, zoneRadius))
    end

    -- from one table to another table, redundency at its finest
    protectedExplosiveZones[i] = { coords = vector3(zoneCoords.x, zoneCoords.y, zoneCoords.z), radius = zoneRadius}
  end
end

local function isExplosionInProtectedZone(explosionCoords)
  for i = 1, #protectedExplosiveZones do
    local protectedZone = protectedExplosiveZones[i]

    if #(protectedZone.coords - explosionCoords) <= protectedZone.radius then
      return true
    end
  end

  return false
end

AddEventHandler('explosionEvent', function(sender, data)
  data.weaponHash = data.f164
  data.f164 = nil

  data.isProjectile = data.f240
  data.f240 = nil

  -- Zero when killing a ped  
  data.vehicleNetworkId = data.f208
  data.f208 = nil

  if not data.f242 then
    data.f242 = nil
    data.posX224 = nil
    data.posY224 = nil
    data.posZ224 = nil
  end

  if not data.f40 then
    data.f40 = nil
  end

  local senderPed = GetPlayerPed(sender)
  local senderCoords = GetEntityCoords(senderPed)

  local maybeOwnerPed
  local maybeOwnerCoords

  if data.ownerNetId > 0 then
    maybeOwnerPed = GetPlayerPed(data.ownerNetId)
    maybeOwnerCoords = GetEntityCoords(maybeOwnerPed)
  end

  print(sender, json.encode(data, {indent = true}))

  if ProhibitedWeapons[data.weaponHash] then
    local senderWeapon = GetSelectedPedWeapon(senderPed)
    local maybeOwnerWeapon = maybeOwnerPed and GetSelectedPedWeapon(maybeOwnerPed)

    if senderWeapon and senderWeapon == data.weaponHash then
      RemoveWeaponFromPed(senderPed, senderWeapon)
      PlayerCache(sender):punish('prohibitedExplosiveWeapon', 'Attempted to cause a prohibited weapon explosion ' ..WEAPON_HASH_TO_NAME[data.weaponHash])
    end

    if data.ownerNetId ~= sender and maybeOwnerWeapon and maybeOwnerWeapon == data.weaponHash then
      RemoveWeaponFromPed(maybeOwnerPed, maybeOwnerWeapon)
      PlayerCache(data.ownerNetId):punish('prohibitedExplosiveWeapon', 'Attempted to cause a prohibited weapon explosion ' ..WEAPON_HASH_TO_NAME[data.weaponHash])
    end

    CancelEvent()
  end

  local explosionCoords = vector3(data.posX, data.posY, data.posZ)
  local explosionOffset

  if data.vehicleNetworkId then
    -- explosionOffset is never used again this is just here for a helpful visual
    explosionOffset = explosionCoords
    explosionCoords = GetEntityCoords(data.vehicleNetworkId) + explosionOffset
  end

  if isExplosionInProtectedZone(explosionCoords) then
    CancelEvent()
  end
end)

AddEventHandler('__vac_internal:initialize', function(module)
  if GetInvokingResource() ~= RESOURCE_NAME or module ~= 'all' and module ~= 'explosion' then
    return
  end

  initializeProtectedZones()
end)