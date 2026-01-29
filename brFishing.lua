---@type _,br,_
local  _,br,_ = ...

---@type br.Logging, br.Settings
local Log,Settings = br.Logging,br.Settings

---@class br.Fishing
local Fishing =  {}
Fishing.Active = false




function Fishing:Fish()
    local player = br.ActivePlayer
    if player.InCombat then
        Log:Log("Cannot fish while in combat.")
        self.Active = false
        br.WINDOW_SETTINGS.updateFishingStatus()
        return
    end
    local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellId = UnitChannelInfo("player")
    if name == nil then
        ---@type SpellInfo
        local spellName = C_Spell.GetSpellInfo(131474) -- 131474 is the spell ID for "Fishing"
        Log:LogCast(spellName.name)
        br.CastSpellByName(spellName.name)
    end
    local callbackTime = math.random(2000,3000)/1000
    C_Timer.After(callbackTime, function() 
        if self.Active then
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
    if event == "EQUIP_BIND_CONFIRM" then
        Log:Log(" Equip Bind Confirmed for ID: " .. tostring(id))
         local callbackTime = math.random(200,400)/1000
        C_Timer.After(callbackTime, function()
           br.ConfirmBindOnUse()
           
        end)
        
    end
end)

br.Fishing = Fishing
Log:Log("BR Fishing module loaded")

