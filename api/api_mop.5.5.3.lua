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
    local start, duration, enabled = GetSpellCooldown(spellID)
    return start, duration, enabled
end

br.api.IsSpellCastable = function(SpellId,target)
    target = target or "target"
    if br.ActivePlayer:IsCasting() or br.ActivePlayer:IsChanneling() then return false end
    if not br.api.IsSpellKnown(SpellId) then return false end

    local startTime, duration, enabled = br.api.GetSpellCooldown(SpellId)
    local isUsable, notEnoughPower = IsUsableSpell(SpellId)
    local inRange = IsSpellInRange(GetSpellInfo(SpellId), "target")
    local isActiveOrQueued = C_Spell.IsCurrentSpell(SpellId)
    
    return  enabled == 1 and (startTime == 0 or duration == 0) and 
        isUsable and (inRange == nil or inRange) and 
        not notEnoughPower and not isActiveOrQueued
end

br.api.IsSpellKnown = function(SpellId)
    return IsSpellKnown(SpellId)
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


Log:Log("Initializing Classic MOP ERA api")
