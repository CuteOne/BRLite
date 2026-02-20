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

if WOW_PROJECT_ID ~= WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
    return
end

if not br.Version then
    print("Core object not located, cannot continue.")
    return
end

br.api.GetSpecialization = function()
    return nil
end

br.api.GetSpecializationName = function()
   return "Initial"
end

br.api.GetSpellCooldown = function(spellID)
    ---@type SpellCooldownInfo
    local scdInfo = C_Spell.GetSpellCooldown(spellID)
    --local start, duration, enabled = GetSpellCooldown(spellID)
    return scdInfo
end

br.api.IsSpellCurrent = function(spellID)
    return C_Spell.IsCurrentSpell(spellID)
end


br.api.GetLowestRankedSpell = function(spellId)
    ---@type SpellInfo
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    local lowestRank = math.huge
    local lowestRankIndex = nil
    local lowestBookType = nil
    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, numSpells = GetSpellTabInfo(tab)
        for index = offset + 1, offset + numSpells do
            local spellName, spellRank = GetSpellBookItemName(index, BOOKTYPE_SPELL)
            if spellName == spellInfo.name then
                local rankNumber = tonumber(spellRank:match("(%d+)"))
                if rankNumber and rankNumber < lowestRank then
                    lowestRank = rankNumber
                    lowestRankIndex = index
                    lowestBookType = BOOKTYPE_SPELL
                end
            end
        end
    end
    return GetSpellBookItemName(lowestRankIndex, lowestBookType)
end

br.api.IsSpellCastable = function(SpellId,target)
    target = target or "target"
    if br.ActivePlayer:IsCasting() or br.ActivePlayer:IsChanneling() then return false end
    if not br.api.IsSpellKnown(SpellId) then 
         --print("Spell not known:", SpellId)
        return false 
    end

    ---@type SpellInfo
    local spellInfo = C_Spell.GetSpellInfo(SpellId)

    ---@type SpellCooldownInfo
    local scd = br.api.GetSpellCooldown(spellInfo.spellID)

    local isUsable, notEnoughPower = IsUsableSpell(spellInfo.spellID)
    local inRange = IsSpellInRange(GetSpellInfo(spellInfo.spellID), "target")
    local isActiveOrQueued = C_Spell.IsCurrentSpell(spellInfo.spellID)
    local castable =  scd.isEnabled and (scd.startTime == 0 or scd.duration == 0) and 
        isUsable and (inRange == nil or inRange) and 
        not notEnoughPower and not isActiveOrQueued
        if not castable then
          -- print("Spell ID:", SpellId, "Cooldown:", scd.startTime, scd.duration, scd.isEnabled, "Is usable:", isUsable, "Not enough power:", notEnoughPower, "In range:", inRange, "Is active or queued:", isActiveOrQueued)        
        end
    return castable
end

br.api.IsSpellKnown = function(SpellId)
    ---@type SpellInfo
    local spellInfo = C_Spell.GetSpellInfo(SpellId)
    if not spellInfo then return false end
    return C_SpellBook.IsSpellKnown(spellInfo.spellID) -- IsSpellKnown(SpellId)
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
br.api.GetDebuffDataByIndex = function(...) return C_UnitAuras.GetDebuffDataByIndex(...) end
br.api.FindAuraByName = function(...) return AuraUtil.FindAuraByName(...) end   
br.api.UnitCastingInfo = function(...) return UnitCastingInfo(...) end
br.api.UnitChannelInfo = function(...) return UnitChannelInfo(...) end
br.api.GetSpellCooldown = function(spellID) 
    --local scdInfo = C_Spell.GetSpellCooldown(spellID)
     -- print("Spell ID:", spellID, "Cooldown Info:", scdInfo.startTime, scdInfo.duration, scdInfo.isEnabled)
     local start, duration, enabled, modRate = GetSpellCooldown(spellID)
     ---@type SpellCooldownInfo
     local scdInfo = {
        startTime = start,
        duration = duration,
        isEnabled = enabled == 1,
        modRate = modRate,
     }
    return scdInfo

end

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

br.api.UnitCanAttack = function(...)
    return UnitCanAttack(...)
end

br.api.UnitIsEnemy = function(...)
    return UnitIsEnemy(...)
end

Log:Log("Initializing TBC Classic API")
