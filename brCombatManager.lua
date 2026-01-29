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

    --Combat Log Parser
    self.CombatLogFrame = CreateFrame("Frame")
    self.CombatLogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.CombatLogFrame:SetScript("OnEvent", function(self, event, ...)
        local timestamp, subevent, hideCaster,
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
        destGUID, destName, destFlags, destRaidFlags,
        spellId, spellName, spellSchool,
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = CombatLogGetCurrentEventInfo()

        if subevent and subevent == "UNIT_DIED" then
            --print("UNIT_DIED: " .. tostring(destName) .. " " .. tostring(destGUID))
            --Remove from ObjectManager
            
        end

        if subevent and subevent == "SPELL_CAST_FAILED" then
            if sourceGUID == br.ActivePlayer.WoWGUID then
            --    Log:Log("Spell Cast Failed: " .. tostring(spellName) .. " (" .. tostring(spellId) .. ") Reason: " .. tostring(amount))
            end
        end


        --Track Summoned creatures/units
        if subevent and subevent == "SPELL_SUMMON" then
            -- Example: Log summon events
            if sourceGUID == br.ActivePlayer.WoWGUID then
                --Update OM to ensure object is there
                br.ObjectManager:Update()
               

                C_Timer.After(0.2, function() 
                    local found = false
                    for k,v in pairs(br.ObjectManager.Units) do
                        if v.WoWGUID == destGUID then
                            v.FirstContact = GetTime()
                            v.IsCreatedByPlayer = true
                            found = true
                            break
                        end
                    end
                    if not found then
                        Log:LogError("Could not find summoned unit in ObjectManager: " .. destName .. " " .. tostring(destGUID))
                    end
                end)
            end
        end
        

        if subevent and subevent:find("DAMAGE") ~= nil then
            -- if source or destination is player,summoned creature, or pet then unit is in combat with us
            if     sourceGUID == br.ActivePlayer.WoWGUID 
                or destGUID   == br.ActivePlayer.WoWGUID
                or br.ActivePlayer:PetGUID() and sourceGUID == br.ActivePlayer:PetGUID() 
                or br.ActivePlayer:PetGUID() and destGUID   == br.ActivePlayer:PetGUID()
                then

                for k,v in pairs(br.ObjectManager.Units) do
                    if v.WoWGUID == destGUID and not(v.IsCreatedByPlayer or v.WoWGUID == br.ActivePlayer.WoWGUID) then
                        v.CombatWithPlayer = true
                        v.LastContact = GetTime()
                        if v.FirstContact == 0 then
                            v.FirstContact = GetTime()
                        end
                        break
                    end
                end
            end
        end
    end)

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
            br.ActivePlayer.InCombat = true
            br.ActivePlayer.CombatStartTime = GetTime()
            br.ActivePlayer.NeedsOpener = true
        elseif event == "PLAYER_REGEN_ENABLED" then
            br.ActivePlayer.InCombat = false
            br.ActivePlayer.NeedsOpener = false
            C_Timer.After(1, function()
                if br.DoLooting and br.ObjectManager:LootableCount() > 0 then
                    br.Looting:Loot()
                end
            end)
        end
    end)
        


    Log:Log("Combat Manager Initialized")

end
