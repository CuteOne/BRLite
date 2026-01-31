---@type _,br,_
local  _,br,_ = ...

---@type br.Logging
local Log = br.Logging

---@class br.Looting
---@field Active boolean Whether the looting module is active
---@field Loot fun(self: br.Looting) Performs looting actions
local Looting =  {}
Looting.Active = false

function Looting:Loot()
    if not br.DoLooting then return end
    if br.ObjectManager:LootableCount() == 0 then return end
    if br.ActivePlayer.InCombat then return end

    local target = br.ObjectManager:ClosestLootable()
    if not target then return end

    --TODO Set timer to blacklist unreachable lootables
    Log:Log("Moving to lootable: " .. target.name .. " at distance " .. tostring(target:Distance()))
    if target:Distance() > 8 then
            br.ClickToMove(br.ObjectLocation(target.guid))
            br.SendMovementHeartbeat()
    end
    Log:Log("Interacting with lootable: " .. target.name)
    br.ObjectInteract(target.guid)
end
br.Looting = Looting
Log:Log("BR Looting module loaded")