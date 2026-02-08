---@type _,br,NilName
local _,br,nn = ...

---@type br.Logging
local Log = br.Logging or {}


---@class br.CombatManager
---@field Initialize fun(self:br.CombatManager)  #Initializes the Combat Manager
local cm = {}
br.CombatManager = cm
br.CombatManager.__index = br.CombatManager

cm.CombatLogFrame = {}
cm.InCombatFrame = {}

function cm:Initialize()
    self.__index = self

    --Player In Combat handler
    self.InCombatFrame = CreateFrame("Frame")
    self.InCombatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.InCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.InCombatFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    self.InCombatFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    self.InCombatFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_SPELLCAST_FAILED" then
            local unitID, spellName, _, _, spellID = ...
            if unitID == "player" and spellID ~= nil then

                Log:Log("Player Spell Cast Failed: " .. tostring(spellName) .. " (" .. tostring(spellID) .. ")")
            end
        end
        if event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unitID, castGuid, spellID = ...
            if unitID == "player" and spellID ~= nil then
                --br.ActivePlayer.LastCastSpell = spellID
                --Log:Log("Player Spell Cast Succeeded: " .. tostring(spellID))
            end
        end
        if event == "PLAYER_REGEN_DISABLED" then
            Log:Log("Player entered combat.")
            br.ActivePlayer.InCombat = true
            br.ActivePlayer.CombatStartTime = GetTime()
            br.ActivePlayer.NeedsOpener = true
        elseif event == "PLAYER_REGEN_ENABLED" then
            Log:Log("Player exited combat.")
            br.ActivePlayer.InCombat = false
            br.ActivePlayer.NeedsOpener = false
            C_Timer.After(1.2, function()
                if br.DoLooting and br.ObjectManager:LootableCount() > 0 then
                    br.Looting:Loot()
                end
            end)
        end
    end)
        


    Log:Log("Combat Manager Initialized")

end
