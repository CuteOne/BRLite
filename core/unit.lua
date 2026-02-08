---@type _,br,NilName
local _,br, nn=...

---@type br
br = br or {}

---@type br.Logging
local log = br.Logging or {}

---@class Unit
---@field guid string @The GUID of the unit
---@field Health fun(self: Unit): number @Returns the current health of the unit
---@field MaxHealth fun(self: Unit): number @Returns the maximum health of the unit
---@field HealthPercent fun(self: Unit): number @Returns the health percentage of the unit
---@field X number @The X coordinate of the unit
---@field Y number @The Y coordinate of the unit
---@field Z number @The Z coordinate of the unit
---@field Lootable boolean @Whether the unit is lootable
---@field Skinnable boolean @Whether the unit is skinnable
---@field Created number @The time the unit object was created
---@field LastUpdated number @The last time the unit object was updated
---@field WoWGUID string @The WoW GUID of the unit
---@field CombatWithPlayer boolean @Whether the unit is in combat with the player
---@field FirstContact number @The time of first contact with the player
---@field LastContact number @The time of last contact with the player
---@field IsCreatedByPlayer boolean @Whether the unit was created by the player
---@field Age fun(self: Unit): number @Returns the age of the unit object in seconds
---@field Freshness fun(self: Unit): number @Returns the time since last update in seconds
---@field new fun(self: Unit, guid: string, X?: number, Y?: number, Z?: number): Unit @Creates a new Unit object
---@field UpdateLocation fun(self: Unit, X: number, Y: number, Z: number): nil @Updates the unit's location
---@field TTD fun(self: Unit): number @Returns the time to die of the unit in seconds
---@field IsAlive fun(self: Unit): boolean @Returns whether the unit is alive
---@field Classification fun(self: Unit): string @Returns the classification of the unit
---@field IsBoss fun(self: Unit): boolean @Returns whether the unit is a boss
Unit = br.ModuleLoader:CreateModule("Unit")
Unit.__index = Unit
Unit.__tostring = Unit.guid

Unit.X = 0
Unit.Y = 0  
Unit.Z = 0
--Unit.Distance = 0
Unit.Lootable = false
Unit.Skinnable = false
Unit.guid = 0
Unit.name = ""
Unit.Created = 0
Unit.LastUpdated = 0
Unit.WoWGUID = ""
Unit.CombatWithPlayer = false
Unit.FirstContact = 0
Unit.LastContact = 0
Unit.IsCreatedByPlayer = false
Unit.AnimationFlag = 0
Unit.InteractionPending = false
Unit.Type = "Unit"

function Unit:new(guid,X,Y,Z)
    ---@type Unit
    local obj = setmetatable({}, Unit)
    obj.guid = guid
    obj.X = X or 0
    obj.Y = Y or 0
    obj.Z = Z or 0
    obj.Created = GetTime()
    obj.LastUpdated = GetTime()
    obj.WoWGUID = UnitGUID(guid)
    obj.name = br.ObjectOrUnitName(guid)
    return obj
end

function Unit:UpdateLocation(X,Y,Z)
    self.X = X
    self.Y = Y
    self.Z = Z
    self.LastUpdated = GetTime()
end

function Unit:Age()
    return GetTime() - self.Created
end

function Unit:Freshness()
    return GetTime() - self.LastUpdated
end

function Unit:Health()
    return br.apis.UnitHealth(self.guid)
end

function Unit:MaxHealth()
    return  br.apis.UnitHealthMax(self.guid)
end

function Unit:TTD()
    --TODO: Settings for high value
    local highValue = 5940
    if not self.CombatWithPlayer then return highValue end

    local health = self:Health()
    local maxHealth = self:MaxHealth()
    if health == 0 or maxHealth == 0 then
        return 0
    end
    local dps = (self:MaxHealth()-self:Health()) / (GetTime() - self.FirstContact)

    if dps == 0 then
        return highValue
    end

    return health / dps
end

function Unit:HealthPercent()
    local health = self:Health()
    local maxHealth = self:MaxHealth()
    if maxHealth == 0 then
        return 0
    end
    return (health / maxHealth) * 100
end

function Unit:IsAlive()
    return not UnitIsDeadOrGhost(self.WoWGUID) or self:Health() > 0
end

function Unit:Classification()
    return UnitClassification(self.WoWGUID)
end

function Unit:IsElite()
    local classification = self:Classification()
    if classification == "elite" or classification == "rareelite" or classification == "worldboss" then
        return true
    end
    return false
end

function Unit:IsBoss()
    local classification = self:Classification()
    local unitLevel = UnitLevel(self.WoWGUID)
    if unitLevel == -1  and classification ~= "normal" then
        return true
    end
    return false
end

function Unit:GetTarget()
    local target = nil
    if br.clientTOC == 110105 then
        target = br.ObjectField(self.guid,0x1950,5)
    else
        target = br.UnitTarget(self.guid)
    end
    return target
end

function Unit:IsInterruptable()
    local spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo(self.WoWGUID)
    if spell and interrupt then
        return true
    end
    return false
end

function Unit:IsCasting(spellName)
    local name, displayName, textureID, startTimeMs, endTimeMs, isTradeskill, castID, notInterruptible, castingSpellID, castBarID = UnitCastingInfo(self.WoWGUID)
    if spellName and not type(spellName) == "number" then
        if name and string.lower(name) == string.lower(spellName) then
            return true
        end
        return false
    end
    if spellName and type(spellName) == "number" then
        if castingSpellID and castingSpellID == spellName then
            return true
        end
        return false
    end
    if name then
        return true
    end
    return false
end

function Unit:Summoner()
    local summoner = nil
    if br.clientTOC == 110105 then
        summoner = br.ObjectField(self.guid,0x1930,5)
    else
        return br.ObjectSummoner(self.guid)
    end
    return summoner
end

function Unit:Creator()
    local creator = nil
    if br.clientTOC == 110105 then
        creator = br.ObjectField(self.guid,0x1920,5)
    else
        return br.ObjectCreator(self.guid)
    end
    return creator
end

function Unit:IsPlayersControl()
    local creator = self:Creator()
    local summoner = self:Summoner()
    if creator == br.ActivePlayer.guid or summoner == br.ActivePlayer.guid then
        return true
    end
    return false
end

function Unit:IsTargettingPlayer()
    local target = self:GetTarget()
    if target and target == br.ActivePlayer.guid then
        return true
    end
    return false
end

function Unit:IsTargetingPet()
    local target = self:GetTarget()
    local pet = br.ActivePlayer:Pet()
    if target and pet then
        for _,v in pairs(br.ObjectManager.Units) do
            if target == pet.guid then
                return true
            end
        end
    end
    return false
end

function Unit:Distance()
    --print ("Calculating distance between " .. tostring(br.ActivePlayer.guid) .. " and " .. tostring(self.guid))
    return br.DistanceBetweenObjects(br.ActivePlayer.guid, self.guid) or math.huge
end

function Unit:HasDebuff(auraID)
    for i=1,40 do
        ---@type AuraData?
        local aura = C_UnitAuras.GetDebuffDataByIndex(self.WoWGUID,i,"HARMFUL")
        if aura and aura.spellId == auraID then
            return true
        end
    end
    return false
end




-- function Unit:IsLineOfSight()
--     local LD = br.LibDraw
--     return LD:TraceLine(br.ObjectLocation("player"),br.ObjectLocation(self.guid)) == false
-- end

