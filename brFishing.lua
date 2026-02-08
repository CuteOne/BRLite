---@type _,br,nn
local  _,br,_ = ...

---@type br.Logging, br.Settings
local Log,Settings = br.Logging,br.Settings

---@class br.Fishing
local Fishing =  {}
Fishing.Active = false

local START_BAG = 0;
local END_BAG = 4;

function IsInventoryFull()
    for bagID = START_BAG, END_BAG do
        local numSlots = C_Container.GetContainerNumSlots(bagID);
        for slotIndex = 1, numSlots do
            -- Check if the slot is empty. GetContainerItemInfo returns nil for empty slots.
            if not C_Container.GetContainerItemInfo(bagID, slotIndex) then
                -- An empty slot was found, so the inventory is not full
                return false
            end
        end
    end
    -- No empty slots were found in any bag
    return true
end

function Fishing:Fish()
    local player = br.ActivePlayer
    if player.InCombat then
        Log:Log("Cannot fish while in combat.")
        self.Active = false
        return
    end
    local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo("player")
    if name == nil then
        ---@type SpellInfo
        local spellName = C_Spell.GetSpellInfo(131474) -- 131474 is the spell ID for "Fishing"
        Log:LogCast(spellName.name)
        br.CastSpellByName(spellName.name)
    end
    C_Timer.After(5, function() 
        if self.Active then
            if IsInventoryFull() then
                Log:Log("Inventory full, stopping fishing.")
                self.Active = false
                br.Logout()
                return
            end
            self:Fish()
        end
    end)
end

local g = CreateFrame("Frame")
g:RegisterEvent("LOOT_BIND_CONFIRM")
g:RegisterEvent("EQUIP_BIND_CONFIRM")
g:SetScript("OnEvent", function(self, event, id)
    if event == "LOOT_BIND_CONFIRM" then
        Log:Log(" Loot Bind Confirmed for ID: " .. tostring(id))
         local callbackTime = math.random(200,400)/1000
        C_Timer.After(callbackTime, function()
            ConfirmLootSlot(id)
        end)
        
    end
end)

br.Fishing = Fishing
Log:Log("BR Fishing module loaded")

