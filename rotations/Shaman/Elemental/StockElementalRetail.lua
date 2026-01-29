--@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Shaman Elemental"
local RotationShortName = "StockShamanElemental"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Elemental Shamans. Only valid until level 10."
local RotationTOCLower = 110207
local RotationTOCUpper = 110207
local RotationClassName = "SHAMAN"
local RotationSpecializationID = 1

local SpellList = {
    FlameShock = 470411,
    LightningBolt = 188196,
    Stormstrike = 17364,
    LavaBurst = 51505,
    PrimalStrike = 73899,
    HealingSurge = 8004,
    LightningShield = 192106,

}

local AuraList = {
    FlameShock = 188389,
    LightningShield = 192106,
}

local TalentList = {

   
}

local ToggleOptions = {
    ["RotationMode"] = 
        {
            ["values"] = {"On","Off"},
            ["default"] = "On",
            ["Icon"] = "Interface\\Icons\\ability_monk_roundhousekick",
            ["tooltip"] = "Turn the Rotation On or Off",
        },
    ["AOEMode"] = {
            ["values"] = {"On","Off"},
            ["default"] = "Off",
            ["Icon"] = "Interface\\Icons\\aability_monk_cranekick",
            ["tooltip"] = "Turn AOE Mode On or Off",
        },
}

-----------------------------------------------------
--- Create Toggles
--- Creates toggle buttons that will appear in the UI
--- When the rotation is active
------------------------------------------------------
local function CreateToggles()
    --No toggles for this basic rotation
end

-----------------------------------------------------
--- Create options
--- Creates options that will appear in the configuration
--- UI when the rotation is selected
------------------------------------------------------
local function CreateOptions()
    --No options for this basic rotation
end

---@type br.Logging
local log    = br.Logging
---@type Player
local player = br.ActivePlayer
---@type Player.cast
local cast   = br.ActivePlayer.cast
---@type Player.buffs
local buffs  = br.ActivePlayer.buffs
---@type Unit?
local target = br.ActivePlayer:TargetUnit()
local mana = br.ActivePlayer:Power()


local function boolNumeric(value)
    if value then
        return 1
    else
        return 0
    end
end

local function Pulse()
    if not player:IsBusy() then 
        
        if player:HealthPercent() < 50 and cast.able.HealingSurge() then
            return cast.HealingSurge("player")
        end

        if not buffs.up.LightningShield("player") and cast.able.LightningShield() then
            return cast.LightningShield("player")
        end
        

    end

    if player:IsBusy() or 
        not player:ValidTarget("target") or 
        not UnitCanAttack("player","target")  then return   
    end

     target = br.ActivePlayer:TargetUnit()
    if not target then
        return
    end

    if not player:IsAuto() then return player:StartAutoAttack() end

    if not br.Debuffs.up.FlameShock(target) and cast.able.FlameShock() then
        return cast.FlameShock()
    end
    if cast.able.Stormstrike() then
        return cast.Stormstrike()
    end
    if cast.able.LavaBurst() then
        return cast.LavaBurst()
    end
    if cast.able.LightningBolt() then
        return cast.LightningBolt()
    end



        
    
end

local rotation = br.RotationBase:Register(
    RotationShortName,
    RotationName,
    RotationDescription,
    RotationVersion,
    RotationTOCLower,
    RotationTOCUpper,
    RotationClassName,
    RotationSpecializationID,
    SpellList
)
if rotation then
    rotation.CheckRequirements = CheckRequirements
    rotation.CreateOptions = CreateOptions  
    rotation.CreateToggles = CreateToggles
    rotation.Pulse = Pulse
    rotation.SpellList = SpellList or {}
    rotation.ToggleOptions = ToggleOptions or {}
    br.ActivePlayer:BuffSetup(AuraList)
    br.Debuffs:AuraSetup(AuraList)
end 