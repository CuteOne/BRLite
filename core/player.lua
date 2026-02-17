---@type _,br,NilName
local _,br,nn=...

---@type br
br = br or {}

---@type br.Logging
local log = br.Logging or {}

---@class Player
---@inherits Unit
---@field new fun(self: Player, guid: string, x: number, y: number, z: number): Player|Unit @Creates a new Player object
---@field guid string @The unique identifier for the player
---@field name string @The name of the player
---@field X number @The X coordinate of the player
---@field Y number @The Y coordinate of the player
---@field Z number @The Z coordinate of the player
---@field Distance number @The distance to the player
---@field Lootable boolean @Whether the player is lootable
---@field Skinnable boolean @Whether the player is skinnable
---@field Created number @The time the player object was created
---@field LastUpdated number @The last time the player object was updated
---@field WoWGUID string @The WoW GUID of the player
---@field InCombat boolean @Whether the player is in combat
---@field NeedsOpener boolean @Whether the player needs an opener
---@field Age fun(self: Player): number @Returns the age of the player object in seconds
---@field Freshness fun(self: Player): number @Returns the time since last update in seconds
---@field UpdateLocation fun(self: Player, X: number, Y: number, Z: number): nil @Updates the player's location
---@field Talents table<number, {name: string, spellID: number, currentRank: number, maxRanks: number}> @A table of the player's talents
---@field RefreshTalents fun(self: Player): nil @Refreshes the player's talents from the game's talent system
---@field HasTalent fun(self: Player, spellID: number): boolean @Checks if the player has a given talent by ID 
---@field GetTalentRank fun(self: Player, spellID: number): number @Gets the current rank of the specified talent
---@field Class number @The class ID of the player
---@field ClassName string @The class name of the player
---@field Specialization number @The specialization ID of the player
---@field SpecializationName string @Returns the name of the player's current specialization
---@field TargetRange fun(self: Player): number @Returns the distance to the player's target
---@field ValidTarget fun(self: Player, target: string): boolean @Checks if the specified target is valid
---@field PowerType fun(self: Player): number @Returns the player's power type
---@field Power fun(self: Player): number @Returns the player's current power
---@field MaxPower fun(self: Player): number @Returns the player's maximum power
---@field PowerPercent fun(self: Player): number @Returns the player's current power as a percentage of maximum power
---@field PowerDeficit fun(self: Player): number @Returns the player's power deficit
---@field AlternatePower fun(self: Player, powerType: number): number @Returns the player's current alternate power of the specified type
---@field MaxAlternatePower fun(self: Player, powerType: number): number @Returns the player's maximum alternate power of the specified type
---@field AlternatePowerPercent fun(self: Player, powerType: number): number @Returns the player's current alternate power of the specified type as a percentage of maximum alternate power
---@field AlternatePowerDeficit fun(self: Player, powerType: number): number @Returns
---@field Health fun(self: Player): number @Returns the player's current health
---@field MaxHealth fun(self: Player): number @Returns the player's maximum health
---@field HealthPercent fun(self: Player): number @Returns the player's current health as a percentage of maximum health
---@field HealthDeficit fun(self: Player): number @Returns the player's health deficit
---@field Castable fun(self: Player, spell: string|number): boolean @Checks if the specified spell is castable
---@field SpellInRange fun(self: Player, spell: string|number, target: string): boolean @Checks if the specified spell is in range of the target
---@field Attack fun(self: Player, target: string): boolean @Commands the player to attack the specified target
---@field IsMounted fun(self: Player): boolean @Returns whether the player is mounted
---@field IsCasting fun(self: Player): boolean @Returns whether the player is currently casting a spell
---@field IsChanneling fun(self: Player): boolean @Returns whether the player is currently channel
---@field IsBusy fun(self: Player): boolean @Returns whether the player is busy (casting or channeling)
---@field IsMoving fun(self: Player): boolean @Returns whether the player is currently moving
---@field IsAuto fun(self: Player): boolean @Returns whether the player is currently auto-attacking
---@field StartAutoAttack fun(self: Player): nil @Starts auto-attacking the current target
---@field Cast fun(self: Player, spell: string|number, target: string): boolean @Casts the specified spell on the specified target
---@field buffs Player.buffs @Player buff related functions and data
---@field cast Player.cast @Player spell casting related functions and data
---@field SetupSpells fun(self: Player, SpellList: table<string, number>): nil @Sets up the player's spell casting functions based on the provided spell list
---@field BuffSetup fun(self: Player, AuraList: table<string, number>): nil @Sets up the player's buff functions based on the provided aura list
---@field TargetUnit fun(self: Player): Unit? @Returns the Unit object of the player's current target
---@field TimeToFight fun(self: Player): number @Returns the estimated time to defeat all enemies in combat with the player. Basically the MAX(TTD) of all enemies in combat with the player.
---@field Pet fun(self: Player): Unit? @Returns the Unit object of the player's pet, if it exists
---@field CombatTime fun(self: Player): number @Returns the duration of the player's current combat in seconds
---@field EnsureFacing fun(self: Player, unit?: Unit): boolean @Ensures the player is facing the specified unit within 5 degrees. Returns true if adjustment was made.
---@field CloseToMelee fun(self: Player, unit?: Unit): boolean @Ensures the player is within melee range (6 yards) of the specified unit. Returns true if movement was initiated.
---@field LastCastSpell number|nil @The spell ID of the last spell cast by the player
---@field DistanceToTarget fun(self: Player): number @Returns the distance to the player's current target
Player = br.ModuleLoader:CreateModule("Player")
Player.__index = Player
Player.Talents={}
Player.X = 0
Player.Y = 0
Player.Z = 0
Player.Distance = 0
Player.guid = 0
Player.Created = 0
Player.LastUpdated = 0
Player.InCombat = false
Player.CombatStartTime = 0
Player.NeedsOpener = false
Player.LastCastSpell = 0
Player.IsLooting = false



Player.Class = select(3,UnitClass("player"))
Player.ClassName = select(2,UnitClass("player"))
--TODO Check version compat with spec stuff


Player.name = UnitName("player")

Player.Specialization =  br.api.GetSpecialization()
--Player.SpecializationName = select(2,GetSpecializationInfo(Player.Specialization))
Player.SpecializationName = br.api.GetSpecializationName()

--#region Spellbook/Cast
        ---@class Player.cast
        ---@field cost table<string, fun(): any> @Returns the primary power cost of the spell
        ---@field cast table<string, fun(target?: any): boolean?> @Casts the spell on the target
        ---@field able table<string, fun(target?: any): boolean?> @Checks Usability, Power Requirements, range, and Cooldown of Spell to ensure that it is castable
        ---@field secondary table<string, fun(target?: any): boolean?> @Casts the spell on the target using secondary method
        ---@field inRange table<string, fun(target?: any): boolean?> @Checks if the spell is in range of the target
        ---@field cdRemains table<string, fun(): number> @Returns the remaining cooldown of the spell in seconds
        ---@field executionTime table<string, fun(): number> @Returns the execution time of the spell in seconds
        ---@field gcdRemains fun(): number @Returns the remaining global cooldown in seconds
        ---@field gcdMax fun(): number @Returns the maximum global cooldown in seconds
        ---@field charges table<string, fun(): number> @Returns the current charges of the spell
        ---@field last table? any @The last spell that was cast
        ---@field atTargetGround table<string, fun(unit: Unit|Player): boolean?> @Casts the spell at the ground location of the target unit
        ---@field lowestRank table<string, fun(target?: any): boolean?> @Casts the lowest rank of the spell on the target
        ---@field castCount table<string, fun(): number> @Returns the number of times the spell has been cast
        ---@
Player.cast = {}
function Player:SetupSpells(SpellList)
        self.cast = self.cast or {}
        self.cast.secondary = {}
        self.cast.cost = {}
        self.cast.able = {}
        self.cast.inRange = {}
        self.cast.cdRemains = {}
        self.cast.executionTime = {}
        self.cast.gcdRemains = {}
        self.cast.gcdMax = {}
        self.cast.last = function() return self.LastCastSpell end
        self.cast.atTargetGround = {}
        self.cast.charges = {}
        self.cast.lowestRank = {}
        self.cast.castCount = {}

        for spell,id in pairs(SpellList) do
           ---Returns the primary power cost of the spell
           ---@return any
            self.cast.cost[spell] = function()
                return select(2,select(1,C_Spell.GetSpellPowerCost(id)))
            end

            ---Checks Usability, Power Requirements, range, and Cooldown of
            ---Spell to ensure that it is castable
            ---@param target any
            ---@return boolean?
            self.cast.able[spell] = function(target,spellid)
                spellid = spellid or id
                
                --if gcdRemains and we're not casting an instant then return false
                if self.cast.gcdRemains() > 0  then 
                    return false
                end
                target = target or "target"
                local castable = br.api.IsSpellCastable(spellid,target)
                return castable

            end
            self.cast.inRange[spell] = function(target)
                target = target or "target"
                return C_Spell.IsSpellInRange(id, target)
            end

            ---Casts the spell on the target
            ---@param target any
            ---@return boolean?
            self.cast[spell] = function(target)
                target = target or "target"
                log:LogCast(tostring(spell))
                local spellInfo = C_Spell.GetSpellInfo(id)
                self.LastCastSpell = id
                return br.CastSpellByName(spellInfo.name,target)
            end

            self.cast.lowestRank[spell] = function(target)
                target = target or "target"
                local lowestRankName = br.api.GetLowestRankedSpell(id)
                log:LogCast(tostring(lowestRankName))
                self.cast.last = id
                Player.LastCastSpell = id
                return br.CastSpellByName(lowestRankName,target)
            end

            self.cast.secondary[spell] = function(target)
                target = target or "target"
                log:LogCast(tostring(spell) .. " (secondary)")
                self.cast.last = id
                Player.LastCastSpell = id
                ---@type SpellInfo
                local spellInfo = C_Spell.GetSpellInfo(id)
                return br.CastSpellByName(spellInfo.name,target)
            end

            self.cast.cdRemains[spell] = function()
                ---@type SpellCooldownInfo
                local spellCooldownInfo = br.api.GetSpellCooldown(id)
                if spellCooldownInfo.startTime == 0 or spellCooldownInfo.duration == 0 then
                    return 0
                else
                    local remaining = (spellCooldownInfo.startTime + spellCooldownInfo.duration) - GetTime()
                    if remaining < 0 then
                        return 0
                    else
                        return remaining
                    end
                end
            end
            self.cast.executionTime[spell] = function()
                ---@type SpellInfo
                local spellInfo = C_Spell.GetSpellInfo(id)
                if spellInfo == nil then
                    return 0
                end
                if spellInfo.castTime == nil then
                    return 0
                end
                if spellInfo.castTime == 0 then
                    return 0
                end
                return spellInfo.castTime / 1000
            end
            self.cast.atTargetGround[spell] = function(unit)
                unit = unit or br.ActivePlayer:TargetUnit()
                if unit == nil then
                    return false
                end
                log:LogCast(tostring(spell) .. " at ground of Target")
                self.cast.last = id
                Player.LastCastSpell = id
                ---@type SpellInfo
                local spellInfo = C_Spell.GetSpellInfo(id)
                br.CastSpellByName(spellInfo.name)
                local x = 0
                while SpellIsTargeting() and x < 100 do
                    --local sx, sy = br.WorldToScreen(br.ObjectLocation(unit.guid))
                    br.ClickPosition(unit.X, unit.Y, unit.Z)
                    x = x + 1
                end
            end

            self.cast.gcdRemains = function()
                ---@type SpellCooldownInfo
                local gcdCooldownInfo = br.api.GetSpellCooldown(61304) --61304 is the global cooldown spell ID
                if gcdCooldownInfo.startTime == 0 or gcdCooldownInfo.duration == 0 then
                    return 0
                else
                    local remaining = (gcdCooldownInfo.startTime + gcdCooldownInfo.duration) - GetTime()
                    if remaining < 0 then
                        return 0
                    else
                        return remaining
                    end
                end
            end

            self.cast.gcdMax = function()
                local gcdCooldownInfo = br.api.GetSpellCooldown(61304) --61304 is the global cooldown spell ID
                return gcdCooldownInfo.duration
            end
            self.cast.castCount[spell] = function()
                return br.api.GetSpellCastCount(id)
            end
            self.cast.charges[spell] = function()
                ---@type SpellInfo
                local spellInfo = C_Spell.GetSpellInfo(id)
                ---@type SpellChargeInfo
                local spellChargeInfo = br.api.GetSpellCharges(id)
                
                if not spellChargeInfo or spellChargeInfo.currentCharges == nil then
                    return 0
                end
                return spellChargeInfo.currentCharges
            end
        end
end
--#endregion Spellbook/Cast

--#region Buffs
---
---@class Player.buffs
---@field up table<string, fun(): boolean> @Returns whether the buff is currently active
---@field down table<string, fun(): boolean> @Returns whether the buff is currently inactive
---@field stacks table<string, fun(): number> @Returns the current stack count of the buff
---@field remaining table<string, fun(): number> @Returns the remaining duration of the buff in seconds
Player.buffs = {}
function Player:BuffSetup(AuraList)
    self.buffs = self.buffs or {}
    self.buffs.up={}
    self.buffs.down={}
    self.buffs.stacks={}
    self.buffs.remaining={}
    for auraName,auraID in pairs(AuraList) do
        self.buffs.up[auraName] = function()


            return br.api.GetPlayerAuraBySpellID(auraID) ~= nil
        end
        self.buffs.down[auraName] = function()
            return br.api.GetPlayerAuraBySpellID(auraID) == nil
        end
        self.buffs.stacks[auraName] = function()

             ---@type SpellInfo
            local spellInfo = C_Spell.GetSpellInfo(auraID)
            if spellInfo == nil then return 0 end

            local name, spellId, stacks, _, _ = br.api.FindAuraByName(spellInfo.name,"player","HELPFUL")
            if name == nil then
                return 0
            else
                return stacks or 0
            end
        end

        self.buffs.remaining[auraName] = function()
            ---@type AuraData|nil
            local auraData = br.api.GetPlayerAuraBySpellID(auraID)
            if auraData and auraData.expirationTime then
                local remaining = auraData.expirationTime - GetTime()
                if remaining < 0 then
                    return 0
                else
                    return remaining
                end
            else
                return 0
            end
            return 0
        end
    end
end
--#endregion Buffs

--#region Constructors
function Player:new(guid,x,y,z)
    ---@type Player
    local obj = setmetatable(Unit:new(guid,x,y,z), Player)
    obj:RefreshTalents()
    return obj
end
--#endregion Constructors

function Player:UpdateLocation(X,Y,Z)
    self.X = X
    self.Y = Y
    self.Z = Z
    self.LastUpdated = GetTime()
end

--#region Talents
function Player:RefreshTalents()
    
    --Skip if client version is too old
    if br.clientTOC < 100003 then return end

    self.Talents = {}

    local configId = C_ClassTalents.GetActiveConfigID()
    
    if configId == nil then return end --A Starter player, or caught during an update that required a respec 

    local configInfo = C_Traits.GetConfigInfo(configId)
    local treeId = configInfo.treeIDs[1]

    local nodes = C_Traits.GetTreeNodes(treeId)
    for _,nodeID in ipairs(nodes) do 
        
        local nodeInfo = C_Traits.GetNodeInfo(configId,nodeID)
        if nodeInfo and nodeInfo.currentRank and nodeInfo.currentRank > 0 then 
             local entryID =nodeInfo.activeEntry.entryID
             local entryInfo = entryID and C_Traits.GetEntryInfo(configId, entryID)
             local definitionInfo = entryInfo and entryInfo.definitionID and C_Traits.GetDefinitionInfo(entryInfo.definitionID)
             if definitionInfo ~= nil then 
                local talentName = TalentUtil.GetTalentName(definitionInfo.overrideName,definitionInfo.spellID)
                self.Talents[definitionInfo.spellID] = {
                    name = talentName,
                    spellID = definitionInfo.spellID,
                    currentRank = nodeInfo.currentRank,
                    maxRanks = nodeInfo.maxRanks
                }
             end
        end
    end
end

function Player:HasTalent(spellID)
    return self.Talents[spellID] ~= nil
end

function Player:GetTalentRank(spellID)
    if self.Talents[spellID] then
        return self.Talents[spellID].currentRank
    end
    return 0
end
--#endregion Talents


function Player:TimeToFight()
    local ttf = 0
    for _,v in pairs(br.ObjectManager.Units) do
        if v.CombatWithPlayer then
            ttf = math.max(ttf,v:TTD())
        end
    end
    return ttf
end

function Player:TargetRange()
    return br.DistanceBetweenObjects("player","target")
end

function Player:TargetUnit()
    local myTarget = br.PlayerTarget() 
    return br.ObjectManager.Units[myTarget]
end

function Player:ValidTarget(target)
    target = target or "target"
    return 
        br.ObjectExists(target) 
        and UnitExists(target) 
        and not UnitIsDeadOrGhost(target)
        and   UnitCanAttack("player",target)
end

function Player:PowerType()
    local i,name = UnitPowerType("player")
    return i
end

function Player:Power()
    return br.api.UnitPower("player",self:PowerType())
end

function Player:MaxPower()
    return br.api.UnitPowerMax("player",self:PowerType())
end
function Player:PowerPercent()
    local power = self:Power()
    local maxPower = self:MaxPower()
    if maxPower == 0 then
        return 0
    end
    return (power / maxPower) * 100
end
function Player:PowerDeficit()
    return self:MaxPower() - self:Power()
end
function Player:AlternatePower(powerType)
    return UnitPower("player",powerType)
end
function Player:MaxAlternatePower(powerType)
    return UnitPowerMax("player",powerType)
end
function Player:AlternatePowerPercent(powerType)
    local power = self:AlternatePower(powerType)
    local maxPower = self:MaxAlternatePower(powerType)
    if maxPower == 0 then
        return 0
    end
    return (power / maxPower) * 100
end
function Player:AlternatePowerDeficit(powerType)
    return self:MaxAlternatePower(powerType) - self:AlternatePower(powerType)
end

function Player:Health()
    return br.api.UnitHealth("player")
end
function Player:MaxHealth()
    return br.api.UnitHealthMax("player")
end
function Player:HealthPercent()
    local health = self:Health()
    local maxHealth = self:MaxHealth()
    if maxHealth == 0 then
        return 0
    end
    return (health / maxHealth) * 100
end

function Player:HealthDeficit()
    return self:MaxHealth() - self:Health()
end

function Player:SpellInRange(spell,target)
    target = target or "target"
    local inRange = C_Spell.IsSpellInRange(spell, target)
    return inRange
end

function Player:Attack(target)
    
    target = target or "target"
    if self:ValidTarget(target) then
        br.AttackTarget()
        return true
    else
        log:Log("Invalid attack target: " .. tostring(target))
    end
    return false
end

function Player:IsMounted()
    if IsMounted() then
        return true
    end
    if UnitInVehicle("player") then
        return true
    end
    return false
end

function Player:IsAuto()
    return C_Spell.IsCurrentSpell(6603)
end
function Player:IsAutoShot()
    local isAS = C_Spell.IsCurrentSpell(75)
    local isAS2 = C_Spell.IsCurrentSpell(193455) --Rapid Fire
    local isAS3 = C_Spell.IsCurrentSpell(257284) --Sidewinders
    print("IsAutoShot: " .. tostring(isAS))
    return isAS
end

function Player:IsCasting()
    local name = select(1,br.api.UnitCastingInfo("player"))
    return name ~= nil
end

function Player:IsChanneling()
    local name = select(1,br.api.UnitChannelInfo("player"))
    return name ~= nil
end

function Player:IsBusy()
    return self:IsCasting() or self:IsChanneling() or
    HasVehicleActionBar() == true or HasOverrideActionBar() == true
    or self.IsLooting == true
end

function Player:StartAutoAttack()
    if not self:IsAuto() then
        br.CastSpellByID(6603)
    end
end
function Player:StartAutoShot()
   
        br.CastSpellByName("! Auto Shot")

end

function Player:IsSpellKnown(spellId)
    local isSpellKnown = false
    if  C_SpellBook.IsSpellInSpellBook then
       isSpellKnown = C_SpellBook.IsSpellInSpellBook(spellId,Enum.SpellBookSpellBank.Player,true)
   elseif C_SpellBook.IsSpellKnownOrInSpellBook then
       isSpellKnown =C_SpellBook.IsSpellKnownOrInSpellBook(spellId,Enum.SpellBookSpellBank.Player,true)
   elseif IsSpellKnownOrOverridesKnown then
       isSpellKnown =IsSpellKnownOrOverridesKnown(spellId,false)     
   else
       log:LogError("No method to determine if spell is known.")                    
   end
   return isSpellKnown
end

function Player:EnsureMHWeaponEnchant(spellId,AuraId)
    if self.LastCastSpell == spellId or not self:IsSpellKnown(spellId) then
        return false
    end
    local _, _, _, mainHandEnchantID, _, _, _, _ = GetWeaponEnchantInfo()
    if AuraId and AuraId ~= mainHandEnchantID then
        --@type SpellInfo
        local spellInfo = C_Spell.GetSpellInfo(spellId)
        
        log:LogCast("Mainhand Weapon: " .. spellInfo.name)
        br.CastSpellByName(spellInfo.name,"player")
        return true
    end
end
function Player:EnsureOHWeaponEnchant(spellId,AuraId)
    if self.LastCastSpell == spellId or not self:IsSpellKnown(spellId) then
        return false
    end
    local _, _, _, _, _, _, _, offHandEnchantID = GetWeaponEnchantInfo()
    if AuraId and AuraId ~= offHandEnchantID then
         ---@type SpellInfo
        local spellInfo = C_Spell.GetSpellInfo(spellId)
        log:LogCast("Offhand Weapon: " .. spellInfo.name)
        br.CastSpellByName(spellInfo.name,"player")
        return true
    end
end

function Player:Pet()
    local petGUID = UnitGUID("pet")
    if not petGUID then return nil end
    for _,v in pairs(br.ObjectManager.Units) do
        if v.WoWGUID == petGUID then
            return v
        end
    end
    return nil
end

function Player:PetGUID()
    return UnitGUID("pet")
end

function Player:IsMoving()
    return GetUnitSpeed("player") > 0
end

function Player:FindTarget30()
    br.ObjectManager:Update()
    for _,v in pairs(br.ObjectManager.Units) do
        if not v:IsTargettingPlayer() and
        v:Distance() <= 30
        and UnitCanAttack("player",v.WoWGUID)
        and UnitIsEnemy("player",v.WoWGUID)
        and v:TTD() > 0
        then
            return v
        end
    end
    return nil
end
--TODO: Optimize these target functions to avoid code duplication
function Player:TargetWeakestInMeleeRange()
    local bestTarget = nil
    local lowestHealth = math.huge
    br.ObjectManager:Update()
    for _,v in pairs(br.ObjectManager.Units) do
        if v:Distance() <= 10 and
            v:IsAlive() and
            not v:IsPlayersControl() and
            UnitCanAttack("player",v.WoWGUID) and
            UnitIsEnemy("player",v.WoWGUID)

        then
            local health = v:Health()
            if health < lowestHealth then
                lowestHealth = health
                bestTarget = v
            end
        end
    end
    if bestTarget then
        log:LogTargetChange(bestTarget)
        br.SetFocus(bestTarget.guid)
        br.TargetUnit("focus")
    end
end

function Player:TargetClosestInMeleeRange()
    local bestTarget = nil
    local bestDistance = math.huge
    br.ObjectManager:Update()
    for _,v in pairs(br.ObjectManager.Units) do
        if  br.api.IsValidTarget(v)
        and v:Distance() <= 10 and
            v:IsAlive() and
            not v:IsPlayersControl() and
            UnitCanAttack("player",v.WoWGUID) and
            UnitIsEnemy("player",v.WoWGUID) and 
            v:IsTargetingPlayer()
        then
            local distance = v:Distance()
            if distance < bestDistance then
                bestDistance = distance
                bestTarget = v
            end
        end
    end
    if bestTarget then
        log:LogTargetChange(bestTarget)
        br.SetFocus(bestTarget.guid)
        br.TargetUnit("focus")
    end
end

function Player:FindNonTargetingWithinRange(minrange,maxrange)
    for _,v in pairs(br.ObjectManager.Units) do
        if v:Distance() <= maxrange and
            v:Distance() >= minrange and
            v:IsAlive() and
            not v:IsTargetingPlayer() and
            UnitIsEnemy("player",v.WoWGUID) and
            UnitCanAttack("player",v.WoWGUID)
        then
            return v
        end
    end
    return nil
end

function Player:TargetBest()
    local bestTarget = nil
    local bestDistance = math.huge
    for _,v in pairs(br.ObjectManager.Units) do
        local isAlive = v:IsAlive()
        local isTargetingPlayer = v:IsTargetingPlayer()
        local isTargetingPet = v:IsTargetingPet()
        local distance = v:Distance()
        if 
             isAlive and 
             (isTargetingPet or isTargetingPlayer)
        then
            local distance = v:Distance()
            if distance < bestDistance then
                bestDistance = distance
                bestTarget = v
            end
        end
    end
    if bestTarget then
        log:LogTargetChange(bestTarget)
        br.SetFocus(bestTarget.guid)
        br.TargetUnit("focus")
    end
end

function Player:CombatTime()
    if not self.InCombat then
        return 0
    end
    return GetTime() - self.CombatStartTime
end

function Player:EnsureFacing(unit)
    if not br.DoFacing then return false end
    unit = unit or br.ActivePlayer:TargetUnit()
    if not unit then return false end
    if not br.Geometry:GetFacing(self,unit,5) then
        local a1,a2 = br.Geometry:GetAnglesBetweenObjects(self,unit)
        br.SetPlayerFacing(a1)
        br.SendMovementHeartbeat()
        return true
    end
    return false
end

function Player:CloseToMelee(unit)
    if not br.DoMovement then return false end
    unit = unit or br.ActivePlayer:TargetUnit()
    if not unit then return false end
    local distance = br.DistanceBetweenObjects(self.guid,unit.guid)
    if distance and distance > 8 then
        br.ClickToMove(br.ObjectLocation(unit.guid))
        br.SendMovementHeartbeat()
        return true
    end
    return false
end

function Player:CloseToRange(unit,range)
    if not br.DoMovement then return false end
    unit = unit or br.ActivePlayer:TargetUnit()
    if not unit then return false end
    local distance = br.DistanceBetweenObjects(self.guid,unit.guid)
    if distance and distance > range then
        br.ClickToMove(br.ObjectLocation(unit.guid))
        br.SendMovementHeartbeat()
        return true
    else
        br.ClickToMove(br.ObjectLocation(self.guid)) --Stop moving
        br.SendMovementHeartbeat()      
    end
    return false
end

function Player:DistanceToTarget()
    local target = br.ActivePlayer:TargetUnit()
    if not target then return math.huge end
    return br.DistanceBetweenObjects(self.guid,target.guid)
end

function Player:IsAlive()
    return not UnitIsDeadOrGhost("player")
end

function Player:HasSkinning()
    local numProfessions = select(1, GetProfessions());
    for i = 1, numProfessions do
        local name, icon, skillLevel, maxSkillLevel, professionIndex = GetProfessionInfo(i);
        log:Log("Player Profession: " .. tostring(name) .. " Skill Level: " .. tostring(skillLevel) .. "/" .. tostring(maxSkillLevel))
        if name == "Skinning" then
            return true, skillLevel, maxSkillLevel;
        end
    end
    return false;
end


function Player:IsHeroClass(classId)
    classId = classId or 0
    if not C_ClassTalents and not C_ClassTalents.GetActiveHeroTalentSpec then
        return false
    end
    local specId = C_ClassTalents.GetActiveHeroTalentSpec()
    if specId == nil then
        return false
    end
    return specId == classId
end

-------------------------------------------------------------------
--- Helper function: returns true if the player is in an instance
--- -------------------------------------------------------------------
function Player:IsInInstance() return select(1,IsInInstance()) end


function Player:InstanceSetPriorityTarget()

    --if We're not in an instance, do nothing
    if not self:IsInInstance() then return  end

    --Don't have a target; we might be exiting combat, so do nothing
    if not Player:ValidTarget("target") then return end


    local target = br.ActivePlayer:TargetUnit()
    if not target then
        return
    end

    --get ranking of current Target
    local bestRank = self:InstancePriorityTarget(target)
    local bestTarget = target
    for _,v in pairs(br.ObjectManager.Units) do
        if v:Distance() <= 10 and not UnitIsDeadOrGhost(v.WoWGUID) then
            local rank = self:InstancePriorityTarget(v)
            if rank > bestRank then
                bestRank = rank
                bestTarget = v
            end
        end
    end

    if bestTarget and bestTarget.guid ~= target.guid then
        log:Log("Switching to higher priority target: " .. tostring(bestTarget.name))
        br.SetFocus(bestTarget.guid)
        br.TargetUnit("focus")
    end

end


function Player:InstancePriorityTarget(unitToRank)
    --Test to see if we can prioritize targets while inside of instances

    --TODO Move this to a config file
    --TODO Expand this to include priority interrupts
    --     
    local Priorities = {
        ["Darkflame Cleft-Normal"] = {          --Darkflame Cleft.  Need to target Overseer's first to minimize how much you get pushed around
            {name ="Rank Overseer", id = 21121, rank = 99},
            {name ="Royal Wicklighter", id = 21085, rank = 98},
        }
    }

    local inInstance,_ = IsInInstance()
    if inInstance then
        local name, _, _, difficultyName, _, _, _, instanceMapId, _ = GetInstanceInfo()
        local InstanceLookup = name .. "-" .. difficultyName
        if Priorities[InstanceLookup] then 
            for _,priority in pairs(Priorities[InstanceLookup]) do
                if unitToRank.name == priority.name then
                    return priority.rank
                end
            end
        end
    end
    return 0
end

function Player:Enemies(yds)
    local count = 0
    local enemies = {}
    for _,v in pairs(br.ObjectManager.Units) do
        if v:Distance() <= yds and
            v:IsAlive() and
            UnitIsEnemy("player",v.WoWGUID) and
            UnitCanAttack("player",v.WoWGUID)
        then
            count = count + 1
            enemies[count] = v
        end
    end
    return enemies
end







