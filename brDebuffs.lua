---@TYPE _,br,_
local _, br, _ = ...

---@type br.Logging
local log = br.Logging or {}

---@class br.Debuffs
local auras = {}
br.Debuffs = auras

function auras:AuraSetup(AuraList)
    self.auras = self.auras or {}
    self.auras.up = {}
    self.auras.down = {}
    self.auras.stacks={}
    self.auras.remaining={}

    for auraName,auraID in pairs(AuraList) do
       
        self.auras.up[auraName] = function(unit)
            for i=1,40 do
                if not br.ObjectExists(unit.guid) then return false end
                ---@type AuraData
                local aura = br.api.GetDebuffDataByIndex(unit.WoWGUID,i,"HARMFUL")
                if aura and aura.spellId == auraID then
                    --print("Unit ", unit.name, " has debuff ", auraName, " with ", aura.charges or 0, " stacks and ", math.max(0,aura.expirationTime - GetTime()), " seconds remaining.")
                    return true
                end
            end
            return false
        end
       
        self.auras.down[auraName] = function(unit)
            return not self.auras.up[auraName](unit)
        end
        
        self.auras.stacks[auraName] = function(unit)
           for i=1,40 do
                ---@type AuraData?
                local aura = br.api.GetDebuffDataByIndex(unit.WoWGUID,i,"HARMFUL")
                if aura and aura.spellId == auraID then
                    return aura.charges or 0
                end
            end
            return 0
        end

        self.auras.remaining[auraName] = function(unit)
        for i=1,40 do
                ---@type AuraData?
                local aura = br.api.GetDebuffDataByIndex(unit.WoWGUID,i,"HARMFUL")
                if aura and aura.spellId == auraID then
                    return aura.expirationTime - GetTime()
                end
            end
            return 0
        end

    end
    br.Debuffs = self.auras
end

