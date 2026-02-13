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

if br.clientTOC < 120000 then return
end

if not br.Version then
    print("Core object not located, cannot continue.")
    return
end

br.api.GetSpecialization = function()
    return GetSpecialization()
end

br.api.GetSpecializationName = function()
   return select(2,GetSpecializationInfo(Player.Specialization))
end

br.api.GetSpellCooldown = function(spellID)
    ---@type SpellCooldownInfo
    local scdInfo = C_Spell.GetSpellCooldown(spellID)
    return scdInfo.startTime, scdInfo.duration, scdInfo.isEnabled
    
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
    if not br.api.IsSpellKnown(SpellId) then return false end

    local startTime, duration, enabled = br.api.GetSpellCooldown(SpellId)
    startTime,duration,enabled = br.unwrap(startTime,duration,enabled)
    local isUsable, notEnoughPower = C_Spell.IsSpellUsable(SpellId)
    ---@type SpellInfo
    local spellInfo = C_Spell.GetSpellInfo(SpellId)
    local inRange = C_Spell.IsSpellInRange(spellInfo.spellID, "target")
    local isActiveOrQueued = C_Spell.IsCurrentSpell(SpellId)
    -- if spellInfo.name == "Arcane Shot" then
    --     print("startTime: ",startTime," dur: ",duration, " enabled: ", tostring(enabled)," isusable: ", tostring(isUsable), " notEnoughPower: ", notEnoughPower)
    -- end
    
    return  enabled and (startTime == 0 or duration == 0) and 
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

--Secret field proxies
br.api.UnitHealth = function(...) return br.unwrap(UnitHealth(...)) end
br.api.UnitHealthMax = function(...) return br.unwrap(UnitHealthMax(...)) end
br.api.UnitPower = function(...) return br.unwrap(UnitPower(...)) end
br.api.UnitPowerMax = function(...) return br.unwrap(UnitPowerMax(...)) end


local function UnpackAuraData(auraData)
    if not auraData then return nil end
    auraData.sourceUnit = br.unwrap(auraData.sourceUnit)
    auraData.charges = tonumber(br.unwrap(auraData.charges))
    auraData.duration = tonumber(br.unwrap(auraData.duration))
    auraData.expirationTime = tonumber(br.unwrap(auraData.expirationTime))
    auraData.name = tostring(br.unwrap(auraData.name))
    auraData.spellId = tonumber(br.unwrap(auraData.spellId))
    auraData.charges = tonumber(br.unwrap(auraData.charges))
    return auraData
end


br.api.GetDebuffDataByIndex = function(...)
    ---@type AuraData
    local auraData = C_UnitAuras.GetDebuffDataByIndex(...)
    if not auraData then return nil end
    auraData = UnpackAuraData(auraData)
    return auraData
end

br.api.GetPlayerAuraBySpellID = function(...)
    ---@type AuraData
    local auraData = C_UnitAuras.GetPlayerAuraBySpellID(...)
    if not auraData then return nil end
    auraData = UnpackAuraData(auraData)
    return auraData
end


br.api.FindAuraByName = function(...)
    local name,icon,count,dispelType,duration,expirationTime = AuraUtil.FindAuraByName(...)
    name,icon,count,dispelType,duration,expirationTime = br.unwrap(name,icon,count,dispelType,duration,expirationTime)
    return name,icon,count,dispelType,duration,expirationTime
end

br.api.InteractDistance = 5
br.api.MeleeDistance = 8.5



Log:Log("Initializing Midnight 12.0.0 api")
