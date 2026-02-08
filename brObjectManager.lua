---@type _,br,NilName
local  _,br,nn = ...

---@type br.Logging, br.Settings
local Log,Settings = br.Logging,br.Settings

---@class br.ObjectManager
---@field GetObjectsByType fun(self: br.ObjectManager, type: number): table 
---@field Update fun(self: br.ObjectManager) @Updates the ObjectManager's list of units
---@field Active boolean @Indicates whether the ObjectManager is active
---@field Units table<number, Unit> @A table of Unit objects managed by the ObjectManager
---@field Timer fun(self: br.ObjectManager) @Starts the ObjectManager's update timer
---@field ObjectCount fun(self: br.ObjectManager): number @Returns the count of objects currently managed
---@field EnemiesInSpellRange fun(self: br.ObjectManager, spellID: number): table @Returns the count of enemies in range of the specified spell
local om = {}
br.ObjectManager = om
br.ObjectManager.__index = br.ObjectManager

local unit = br.ModuleLoader:LoadModule("Unit")
local player = br.ModuleLoader:LoadModule("Player")

om.Units={}
om.Bobbers = {}
om.FishingHoles = {}
om.Lootables = {}
om.Skinnables = {}
om.Active = false

function om:Timer()
    if self.Active then
        self:Update()
        if br.UI.ObjectExplorer and br.UI.ObjectExplorer.window then
            if br.UI.ObjectExplorer.window.diesalWindow:IsShown() then
                br.UI.ObjectExplorer:Refresh()
            end
        end
    end
    C_Timer.After(0.1, function() self:Timer() end)
end

function om:ObjectCount()
    local count = 0
    for _,_ in pairs(self.Units) do
        count = count + 1
    end
    return count
end

function om:LootableCount()
    local count = 0
    for _,v in pairs(self.Units) do
        if br.ObjectLootable(v.guid) then
            count = count + 1
        end
    end
    return count
end

function om:ClosestLootable()
    local closest = nil
    local closestDistance = 99999
    for _,v in pairs(self.Units) do
        if br.ObjectLootable(v.guid) then
            local distance = br.DistanceBetweenObjects(br.ActivePlayer.guid,v.guid)
            if distance < closestDistance then
                closestDistance = distance
                closest = v
            end
        end            
    end
    return closest
end

function om:SkinnableCount()
    local count = 0
    for _,v in pairs(self.Units) do
        if br.ObjectSkinnable(v.guid) then
            count = count + 1
        end
    end
    return count
end

function om:ClosestSkinnable()
    local closest = nil
    local closestDistance = 99999
    for _,v in pairs(self.Units) do
        if br.ObjectSkinnable(v.guid) then
            local distance = br.DistanceBetweenObjects(br.ActivePlayer.guid,v.guid)
            if distance < closestDistance then
                closestDistance = distance
                closest = v
            end
        end            
    end
    return closest
end

function om:SkinnableTable()
    local skinnables = {}
    local i=1
    for _,v in pairs(self.Units) do
        if br.ObjectSkinnable(v.guid) and v:Distance() <=20 then
            skinnables[i] = v
            i = i + 1
        end
    end
    return skinnables
end

function om:SummonedCount(name)
    local count = 0
    for _,v in pairs(self.Units) do
        if v.IsCreatedByPlayer then --and string.lower(v.name):find(string.lower(name)) ~= nil then
            count = count + 1
        end
    end
    return count
end

function om:CombatCount()
    local count = 0
    for _,v in pairs(self.Units) do
        if v.CombatWithPlayer then
            count = count + 1
        end
    end
    return count
end

function om:Update()
    self.__index = self
    --self.Units = {}

    --Get Active Player
    local objs = br.GetObjects(7) 
    local x,y,z = br.ObjectLocation(objs[1])
    if not br.ActivePlayer then
        br.ActivePlayer = player:new(objs[1],x,y,z)
    else
        br.ActivePlayer:UpdateLocation(x,y,z)
        if br.ActivePlayer.guid ~= objs[1] then
            br.ActivePlayer.guid = objs[1]
            br.ActivePlayer.WoWGUID = UnitGUID("player")
        end
    end

    local bobObjs = br.GetObjects(8)
    for k,v in pairs(bobObjs) do
        if v and br.ObjectOrUnitName(v) == "Fishing Bobber" then
            if not self.Bobbers[v] then
                if br.ObjectCreator(v) == br.ActivePlayer.guid then
                    local u = unit:new(v,br.ObjectLocation(v))
                    u.name = br.ObjectOrUnitName(v)
                    u.AnimationFlag = br.ObjectAnimationFlag(v)
                  
                    self.Bobbers[v] = u
                end
            else
                self.Bobbers[v]:UpdateLocation(br.ObjectLocation(v))
                newFlag = br.ObjectAnimationFlag(v)
                if self.Bobbers[v].AnimationFlag ~= newFlag and 
                    not self.Bobbers[v].InteractionPending   then
                        Log:LogError("Fishing Bobber Sunk")
                        self.Bobbers[v].InteractionPending = true
                        local callbackTime = math.random(450,1000)/1000
                        C_Timer.After(callbackTime, function()
                            br.ObjectInteract(v)
                            C_Timer.After(1, function()
                                br.ConfirmBindOnUse()
                            end)
                        end)
                end
            end 
        end
        
    end
    

    -- Only get units (type 5)
    objs = br.GetObjects(5)
    for k,v in pairs(objs) do
        if self.Units[v] then
            self.Units[v]:UpdateLocation(br.ObjectLocation(v))
            --self.Units[v].Distance = br.DistanceBetweenObjects(br.ActivePlayer.guid,v)
        else
            local u = unit:new(v,br.ObjectLocation(v))
            --u.Distance = br.DistanceBetweenObjects(br.ActivePlayer.guid,u.guid)
            u.name = br.ObjectOrUnitName(v)
            self.Units[v] = u

            

        end
        -- if br.ObjectOrUnitName(v) == "Meandering Shalehorn" and UnitIsDead(UnitGUID(v)) then
        --         Log:Log("Found Corpse; checking flags")
        --         Log:Log(" Corpse Animation Flag: " .. tostring(br.ObjectAnimationFlag(v)))
        --         Log:Log(" Is Lootable: " .. tostring(br.ObjectLootable(v)))
        --         Log:Log(" Is Skinnable: " .. tostring(br.ObjectSkinnable(v)))
        -- end
    end
    -- Set Freshness and cleanup stale combat counters
    for k,_ in pairs(self.Units) do
        local Freshness = self.Units[k]:Freshness()
        
        --if no damage has been seen from/to in 10 seconds, reset combat flag
        if self.Units[k].LastContact > 0 and (GetTime() - self.Units[k].LastContact) > 10 then
            self.Units[k].CombatWithPlayer = false
            self.Units[k].FirstContact = 0
            self.Units[k].LastContact = 0
        end 
        
        --if not updated in last 1 second remove from OM
        if Freshness > 1 then
            self.Units[k] = nil
        end
    end

    --Check for lootable units
    for k,_ in pairs(self.Units) do
        if br.ObjectLootable(self.Units[k].guid) then
            self.Lootables[self.Units[k].guid] = self.Units[k]
        else
            self.Lootables[self.Units[k].guid] = nil
        end
        if br.ObjectSkinnable(self.Units[k].guid) then
            self.Skinnables[self.Units[k].guid] = self.Units[k]
        else
            self.Skinnables[self.Units[k].guid] = nil
        end
        if self.Units[k] == nil then
            self.Lootables[self.Units[k].guid] = nil
            self.Skinnables[self.Units[k].guid] = nil
        end
    end

    for k,_ in pairs(self.Bobbers) do
        local Freshness = self.Bobbers[k]:Freshness()
        --if not updated in last 5 seconds, remove from OM
        if Freshness > 1 then
            self.Bobbers[k] = nil
        end
    end

    for k,_ in pairs(self.FishingHoles) do
        local Freshness = self.FishingHoles[k]:Freshness()
        --if not updated in last 10 seconds, remove from OM
        if Freshness > 10 then
            Log:Log("Removing stale fishing hole object: " .. self.FishingHoles[k].name)
            self.FishingHoles[k] = nil
        end
    end


end

function om:EnemiesInSpellRange(spellID)
    local count = 0
    for _,v in pairs(self.Units) do
        if v:IsAlive() and UnitCanAttack("player",v.guid) and br.ActivePlayer.cast.inRange.Spell(spellID,v.guid) then
            count = count + 1
        end
    end
    return count
end

function om:EnemiesFacingMelee()
    local enemies = {}
    local i = 1
    --Log:Log("----------------------------------------------------------------")
    --Log:Log("Spell: " .. spellID)
    --Log:Log(" Spell Range: " .. spellInfo.minRange .. " to " .. spellInfo.maxRange)
    for _,v in pairs(self.Units) do
        if v:IsAlive() and UnitCanAttack("player",v.WoWGUID)
            and br.DistanceBetweenObjects(br.ActivePlayer.guid,v.guid) <= 6 
             then
            local angle2 = br.ObjectFacing(br.ActivePlayer.guid)                
            local angle1 = br.ObjectFacing(v.guid)
           -- Log:Log("Unit: " .. v.name .. " Facing Angle: " .. angle1 .. " Rad")
            local angle3 = 0
            local Y1,X1,Z1 = br.ActivePlayer.X, br.ActivePlayer.Y, br.ActivePlayer.Z
            local Y2,X2,Z2 = v.Y, v.X, v.Z

            -- local dot = (X1 * X2) + (Y1 * Y2) + (Z1 * Z2)
            -- local magnitude1 = math.sqrt(X1^2 + Y1^2 + Z1^2)
            -- local magnitude2 = math.sqrt(X2^2 + Y2^2 + Z2^2)
            -- local ansAgain = math.acos(dot / (magnitude1 * magnitude2))
            -- print("Angle between player and unit: " .. ansAgain)
            -- print(" outcome1: " .. math.abs(angle1 - math.pi * 2 ))
            -- print(" outcome2: " .. math.abs(angle2 - math.pi * 2 ))


            local deltaY = Y2 - Y1
            local deltaX = X2 - X1

            angle1 = math.deg(math.abs(angle1 - math.pi * 2 ))
            if deltaX > 0 then
				angle2 = math.deg(math.atan(deltaY / deltaX) + (math.pi / 2) + math.pi)
			elseif deltaX < 0 then
				angle2 = math.deg(math.atan(deltaY / deltaX) + (math.pi / 2))
			end
           -- print("Angle1: " .. angle1  .. " Angle2: " .. angle2)
			if angle2 - angle1 > 180 then
				angle3 = math.abs(angle2 - angle1 - 360)
			elseif angle1 - angle2 > 180 then
				angle3 = math.abs(angle1 - angle2 - 360)
			else
				angle3 = math.abs(angle2 - angle1)
			end
            --Log:Log("Unit: " .. v.name .. " Angle to Player Facing: " .. angle3)
            if angle3 < 90 then 
                enemies[i] = v
                i = i + 1
            end
        end
    end
    return enemies
end

