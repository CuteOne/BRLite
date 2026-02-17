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

br.api.GetSpellCooldown = function(...)
    ---@type SpellCooldownInfo
    local scdInfo = C_Spell.GetSpellCooldown(...)
    scdInfo.activeCategory = br.unwrap(scdInfo.activeCategory)
    scdInfo.duration = tonumber(br.unwrap(scdInfo.duration))
    scdInfo.startTime = tonumber(br.unwrap(scdInfo.startTime))
    scdInfo.isEnabled = br.unwrap(scdInfo.isEnabled)
    scdInfo.isOnGCD = br.unwrap(scdInfo.isOnGCD)
    scdInfo.timeUntilEndOfStartRecovery = tonumber(br.unwrap(scdInfo.timeUntilEndOfStartRecovery))
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
        --print("Spell not known: ", SpellId)
        return false 
    end

    ---@type SpellCooldownInfo
    local cooldownInfo = br.api.GetSpellCooldown(SpellId)
    local startTime, duration, enabled = cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled
    
    local isUsable, notEnoughPower = C_Spell.IsSpellUsable(SpellId)
    ---@type SpellInfo
    local spellInfo = C_Spell.GetSpellInfo(SpellId)
    local inRange = C_Spell.IsSpellInRange(spellInfo.spellID, "target")
    local isActiveOrQueued = C_Spell.IsCurrentSpell(SpellId)
    
    return  enabled and (startTime == 0 or duration == 0) and 
        isUsable and (inRange == nil or inRange) and 
        not notEnoughPower and not isActiveOrQueued
end

br.api.IsSpellKnown = function(SpellId)
    return C_SpellBook.IsSpellInSpellBook(SpellId)
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
br.api.UnitHealth = function(...) return br.unwrap(br.apis.UnitHealth(...)) end
br.api.UnitHealthMax = function(...) return br.unwrap(br.apis.UnitHealthMax(...)) end
br.api.UnitPower = function(...) return br.unwrap(br.apis.UnitPower(...)) end
br.api.UnitPowerMax = function(...) return br.unwrap(br.apis.UnitPowerMax(...)) end


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
    -- ---@type AuraData
    -- local auraData = br.apis.C_UnitAuras.GetDebuffDataByIndex(...)
    -- if not auraData then return nil end
    -- auraData = UnpackAuraData(auraData)
    local name,rank,icon,count,debuffType, duration, expirationTime, unitCaster,isStealable, shouldConsolidate, spellId = br.apis.UnitDebuff(...)
    ---@type AuraData
    local auraData = {
        name = tostring(br.unwrap(name)),
        applications = tonumber(br.unwrap(count)),
        icon = tonumber(br.unwrap(icon)),
        expirationTime = tonumber(br.unwrap(expirationTime)),
        duration = tonumber(br.unwrap(duration)),
        sourceUnit = br.unwrap(unitCaster),
        isStealable = br.unwrap(isStealable),
        spellId = tonumber(br.unwrap(spellId)),
    }
    return auraData
end

br.api.GetPlayerAuraBySpellID = function(...)
    ---@type AuraData
    local auraData = br.apis.C_UnitAuras.GetPlayerAuraBySpellID(...)
    if not auraData then return nil end
    auraData = UnpackAuraData(auraData)
    return auraData
end


br.api.FindAuraByName = function(...)
    local name,icon,count,dispelType,duration,expirationTime = br.apis.AuraUtil.FindAuraByName(...)
    name,icon,count,dispelType,duration,expirationTime = br.unwrap(name,icon,count,dispelType,duration,expirationTime)
    return name,icon,count,dispelType,duration,expirationTime
end

    
br.api.UnitCastingInfo = function(...)
    return br.apis.UnitCastingInfo(...)
end
br.api.UnitChannelInfo = function(...)
    return br.apis.UnitChannelInfo(...)
end

br.api.IsValidTarget = function(unit)
    if not unit then return false end
    if unit:Distance() <= 15 then
    -- print("Evaluating unit: ",unit.name," with guid: ", unit.WoWGUID)
    -- print("Alive Status: ", unit:IsAlive(), " Health: ", unit:Health())
    -- print("UnitIsDead status: ", UnitIsDead(unit.WoWGUID))
    -- print("Is Targeting Player: ", tostring(unit:IsTargetingPlayer()), " Is Targeting Pet: ", tostring(unit:IsTargetingPet()))
    -- print("---------------------------------------")
    end
    if UnitIsDead(unit.WoWGUID) or unit:Health() <= 0 then return false end
    if 
        (unit:IsTargetingPlayer() or unit:IsTargetingPet()) and
        br.apis.UnitCanAttack("player", unit.WoWGUID)
        then
        return true
    end
end

br.api.GetSpellCastCount = function(...)
    local castCount = br.apis.C_Spell.GetSpellCastCount(...)
    if not castCount then return nil end
    return tonumber(br.unwrap(castCount))
end

br.api.GetSpellCharges = function(...)
    ---@type SpellChargeInfo
    local sci = br.apis.C_Spell.GetSpellCharges(...)
    print("GetSpellCharges for ", tostring(...), ": ", sci and ("currentCharges: " .. tostring(sci.currentCharges) .. " maxCharges: " .. tostring(sci.maxCharges)) or "nil")
    local sci2 = br.apis.C_Spell.GetSpellCastCount(...)
    print("Direct C_Spell.GetSpellCharges for ", tostring(...), ": ", sci2 and ("currentCharges: " .. tostring(sci2.currentCharges) .. " maxCharges: " .. tostring(sci2.maxCharges)) or "nil")
    if not sci then return nil end
    sci.currentCharges = tonumber(br.unwrap(sci.currentCharges))
    sci.maxCharges = tonumber(br.unwrap(sci.maxCharges))
    sci.cooldownStartTime = tonumber(br.unwrap(sci.cooldownStartTime))
    sci.cooldownDuration = tonumber(br.unwrap(sci.cooldownDuration))
    sci.chargeModRate = tonumber(br.unwrap(sci.chargeModRate))
    return sci
end

br.api.InteractDistance = 5
br.api.MeleeDistance = 8.5



Log:Log("Initializing Midnight 12.0.0 api")
