---@type _,br,_
local  _,br,_ = ...

---@type br.Logging
local Log = br.Logging

---@class br.Skinning
---@field Active boolean Whether the skinning module is active
---@field Skin fun(self: br.Skinning) Performs skinning actions
local Skinning =  {}
Skinning.BlackList = {}

Skinning.Active = false
function Skinning:SkinTarget(target)
    if br.DoSkinning and
      not br.ActivePlayer:IsCasting() and
      not br.ActivePlayer:IsChanneling() and
      not br.ActivePlayer:IsMoving() and
      not br.ActivePlayer:IsMounted() and
      br.ActivePlayer:IsAlive() and
      not br.ActivePlayer.InCombat then
        if target and br.ObjectExists(target.guid) and not self.BlackList[target.guid] then

            self.Active = true

            --TODO Set timer to blacklist unreachable skinnables
            Log:Log("Moving to skinnable: " .. target.name .. " at distance " .. tostring(target:Distance()))
            if target:Distance() > 8 then
                while target:Distance() > 8 do
                    br.ClickToMove(br.ObjectLocation(target.guid))
                    br.SendMovementHeartbeat()
                end
            end
            Log:Log("Interacting with skinnable: " .. target.name)
            br.ObjectInteract(target.guid)
            self.BlackList[target.guid] = GetTime()
            self.Active = false
        else
            if target and not br.ObjectExists(target.guid) then
                --remove from OM
                br.ObjectManager.Units[target.guid] = nil
            end
        end

        --Cleanun Blacklist entries older than 60 seconds
        for guid,timeAdded in pairs(self.BlackList) do
            if GetTime() - timeAdded > 60 then
                self.BlackList[guid] = nil
            end
        end
      end
end

function Skinning:Skin()
    if br.DoSkinning and
      br.ObjectManager:SkinnableCount() > 0 and
      not br.ActivePlayer:IsCasting() and
      not br.ActivePlayer:IsChanneling() and
      not br.ActivePlayer:IsMoving() and
      not br.ActivePlayer:IsMounted() and
      br.ActivePlayer:IsAlive() and
      not br.ActivePlayer.InCombat then
        local target = br.ObjectManager:ClosestSkinnable()
        if target and br.ObjectExists(target.guid) and not self.BlackList[target.guid] then

            self.Active = true

            --TODO Set timer to blacklist unreachable skinnables
            Log:Log("Moving to skinnable: " .. target.name .. " at distance " .. tostring(target:Distance()))
            if target:Distance() > 8 then
                while target:Distance() > 8 do
                    br.ClickToMove(br.ObjectLocation(target.guid))
                    br.SendMovementHeartbeat()
                end
            end
            Log:Log("Interacting with skinnable: " .. target.name)
            br.ObjectInteract(target.guid)
            self.BlackList[target.guid] = GetTime()
            self.Active = false
        else
            if target and not br.ObjectExists(target.guid) then
                --remove from OM
                br.ObjectManager.Units[target.guid] = nil

            end
        end

        --Cleanun Blacklist entries older than 60 seconds
        for guid,timeAdded in pairs(self.BlackList) do
            if GetTime() - timeAdded > 60 then
                self.BlackList[guid] = nil
            end
        end
    
    end
    --Retry in 0.5 second
    -- C_Timer.After(0.5, function()
    --         Skinning:Skin()                    
    -- end)
end

--Kick off skinning loop 2 seconds after load
-- C_Timer.NewTimer(2, function()
--     Log:Log("Starting Skinning loop")
--     Skinning:Skin()
-- end)



br.Skinning = Skinning
Log:Log("BR Skinning module loaded")