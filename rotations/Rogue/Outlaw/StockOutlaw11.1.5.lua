---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Outlaw Rogue"
local RotationShortName = "StockOutlawRogue"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Outlaw Rogues. Only valid until level 10."
local RotationTOCLower = 110105
local RotationTOCUpper = 110105
local RotationClassName = "ROGUE"
local RotationSpecializationID = 2

local SpellList = {
    
}

local AuraList = {

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
local Energy
local CP

local function boolNumeric(value)
    if value then
        return 1
    else
        return 0
    end
end

local function Pulse()
    Energy = player:Power()
    CP = player:AlternatePower(Enum.PowerType.ComboPoints)
    target = br.ActivePlayer:TargetUnit()

    if player.InCombat and not target then
        return player:TargetBest()
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
end 
