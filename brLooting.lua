---@type _,br,_
local  _,br,_ = ...

---@type br.Logging
local Log = br.Logging

---@class br.Looting
---@field Active boolean Whether the looting module is active
---@field Loot fun(self: br.Looting) Performs looting actions
local Looting =  {}
Looting.Active = false
Looting.Target = nil
Looting.TimeoutTime = GetTime()

Looting.States = {
    Idle = 0,
    MovingToLoot = 1,
    Interacting = 2,
    WaitingForLoot = 3
}

Looting.State = Looting.States.Idle

function Looting:Loot()
   if not br.DoLooting then return end
   if UnitIsDeadOrGhost("player") then 
        self.State = Looting.States.Idle
        br.ActivePlayer.IsLooting = false
        return 
   end
   if br.ActivePlayer.InCombat or br.ObjectManager:LootableCount() == 0 then 
        self.State = Looting.States.Idle
        br.ActivePlayer.IsLooting = false
        return  
    else
        if not br.ActivePlayer.IsLooting then
            self.State = Looting.States.MovingToLoot
            self.TimeoutTime = GetTime() 
            self:Manager()
        end
    end
end

function Looting:Manager()
    if not br.DoLooting then return end
    if br.ObjectManager:LootableCount() == 0 then 
        self.State = Looting.States.Idle
        br.ActivePlayer.IsLooting = false
        return 
    end
    if br.ActivePlayer.InCombat then 
        self.State = Looting.States.Idle
        br.ActivePlayer.IsLooting = false
        return 
    end

    if GetTime() - self.TimeoutTime > 10 then
        Log:Log("Looting timed out.")
        self.State = Looting.States.Idle
        br.ActivePlayer.IsLooting = false
        return 
     end

    local target = br.ObjectManager:ClosestLootable()
    if not target then 
        self.State = Looting.States.Idle
        br.ActivePlayer.IsLooting = false
        return 
    end

    br.ActivePlayer.IsLooting = true

    if target:Distance() > br.api.InteractDistance then
        self.State = Looting.States.MovingToLoot
        self:MoveToLoot(target)
    else
        if self.State == Looting.States.MovingToLoot then
            self.State = Looting.States.Interacting
            C_Timer.After(.5,function() 
                self:InteractWithLoot(target)
            end)
        end
    end
    C_Timer.After(.7,function() 
        self:Manager()
    end)

end

function Looting:MoveToLoot(target)
    if target:Distance() > br.api.InteractDistance then
        br.ClickToMove(br.ObjectLocation(target.guid))
        br.SendMovementHeartbeat()
    end
end

function Looting:InteractWithLoot(target)
        self.State = Looting.States.WaitingForLoot
        br.ObjectInteract(target.guid)
end


local frameLootWatch = CreateFrame("Frame")
frameLootWatch:RegisterEvent("LOOT_CLOSED")
frameLootWatch:SetScript("OnEvent", function(self, event, ...)
    if event == "LOOT_CLOSED" then
        Log:Log("Loot window closed.")
        br.ActivePlayer.IsLooting = false
        Looting.State = Looting.States.Idle
    end
end)



br.Looting = Looting
Log:Log("BR Looting module loaded")