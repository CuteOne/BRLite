---@type _,br,_
local _,br,_ = ...

---@type AbstractFramework
local AF = _G.AbstractFramework

---@type br.Settings
local Settings = br.Settings

---@type br.Logging
local Log = br.Logging

---@class br
br = br or {}

if br.clientTOC ~= 50503 then
    return
end

if not br.Version then
    print("Core object not located, cannot continue.")
    return
end

br.api.GetSpecialization = function()
    return  C_SpecializationInfo.GetSpecialization()
end

br.api.GetSpecializationName = function()
    local currentSpecIndex = br.api.GetSpecialization()
   local _, name, _, _, _, _, _, _, _, _ = C_SpecializationInfo.GetSpecializationInfo(currentSpecIndex)
   return name
end

br.api.GetSpellCooldown = function(spellID)
    return C_Spell.GetSpellCooldown(spellID)
end

br.api.IsSpellCastable = function(SpellId,target)
    target = target or "target"
    if br.ActivePlayer:IsCasting() or br.ActivePlayer:IsChanneling() then return false end
    if not br.api.IsSpellKnown(SpellId) then 
        print("Spell ID ", SpellId, " is not known by the player.")
        return false 

        end

    ---@type SpellCooldownInfo
    local cooldownInfo = br.api.GetSpellCooldown(SpellId)
    local isUsable, notEnoughPower = C_Spell.IsSpellUsable(SpellId)
    ---@type SpellInfo
    local spellInfo = C_Spell.GetSpellInfo(SpellId)
    local inRange = C_Spell.IsSpellInRange(spellInfo.spellID, "target")
    local isActiveOrQueued = C_Spell.IsCurrentSpell(SpellId)

    --  if spellInfo.name == "Stormstrike" then
    --     print("Cooldown info for Stormstrike: ", cooldownInfo)
    --     print("IsUsable: ", isUsable, " NotEnoughPower: ", notEnoughPower, " InRange: ", inRange, " IsActiveOrQueued: ", isActiveOrQueued)
    -- end
    
    return  cooldownInfo.isEnabled and (cooldownInfo.startTime == 0 or cooldownInfo.duration == 0) and 
        isUsable and (inRange == nil or inRange) and 
        not notEnoughPower and not isActiveOrQueued
end

br.api.IsSpellKnown = function(SpellId)
    ---@type SpellInfo
    local spellInfo = C_Spell.GetSpellInfo(SpellId)
    if not spellInfo then return false end
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        return C_SpellBook.IsSpellInSpellBook(spellInfo.spellID)
    else
        return IsSpellKnownOrOverridesKnown(spellInfo.spellID)
    end
end

br.api.AutoShotOn = false
br.api.AutoShotStarted = GetTime()

br.api.IsAutoShot = function()
    if  br.api.AutoShotOn and (GetTime() - br.api.AutoShotStarted) < 2.5 then
        return true
     end
    local ias = C_Spell.IsCurrentSpell(75)
    if ias then
        br.api.AutoShotOn = true
        br.api.AutoShotStarted = GetTime()
    end
    return ias
end
br.api.StartAutoShot = function()
    if not br.api.IsAutoShot() then
        br.api.AutoShotStarted = GetTime()
        br.api.AutoShotOn = true
        br.CastSpellByID(75)
    end
end

br.api.UnitHealth = function(...)
    return UnitHealth(...)
end

br.api.UnitHealthMax = function(...)
    return UnitHealthMax(...)
end
br.api.UnitPower = function(...)
    return UnitPower(...)
end

br.api.UnitPowerMax = function(...)
    return UnitPowerMax(...)
end
br.api.GetAuraDataByIndex = function(...) return C_UnitAuras.GetAuraDataByIndex(...) end
br.api.GetPlayerAuraBySpellID = function(...) return C_UnitAuras.GetPlayerAuraBySpellID(...) end
br.api.FindAuraByName = function(...) return AuraUtil.FindAuraByName(...) end   
br.api.InteractDistance = 5
br.api.MeleeDistance = 8.5

br.api.IsValidTarget = function(unit)
    if not unit or not br.ObjectExists(unit) then return false end
    if UnitIsDead(unit.WoWGUID) or unit:Health() <= 0 then return false end
    if unit:IsPlayersControl() then return false end
    if not UnitCanAttack("player",unit.WoWGUID) then return false end
    if not UnitIsEnemy("player",unit.WoWGUID) then return false end
    return true
end

br.api.UnitCastingInfo = function(...)
    return UnitCastingInfo(...)
end

br.api.UnitChannelInfo = function(...)
    return UnitChannelInfo(...)
end

br.api.GetDebuffDataByIndex = function(...) return C_UnitAuras.GetDebuffDataByIndex(...) end

br.api.UnitCanAttack = function(...)
    return UnitCanAttack(...)
end

br.api.UnitIsEnemy = function(...)
    return UnitIsEnemy(...)
end

Log:Log("Initializing Classic MOP ERA api")
