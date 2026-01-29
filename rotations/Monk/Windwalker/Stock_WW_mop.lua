---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Monk Windwalker MOP"
local RotationShortName = "StockWindWalker"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Windwalker Monks"
local RotationTOCLower = 50503
local RotationTOCUpper = 50503
local RotationClassName = "MONK"
local RotationSpecializationID = 3  --Starter Spec ID



print("br.name: " .. br.name)
-----------------------------------------------------
-- Not required, but will be run if needed to check
-- if character meets rotation requirements
-- Like certain specialization traits, gear, etc.
-----------------------------------------------------
local function CheckRequirements()
    return br.ActivePlayer.Specialization == 5
end

-----------------------------------------------------
--- Spell List.  Yes I know the previous BR had all of
--- these inside the core code but they vary so much
--- by client release that to support multiple versions
--- we need to have them defined per rotation.
--- ------------------------------------------------
local SpellList = {
    TigerPalm = 100787,
    BlackoutKick = 100784,
    FistsOfFury = 113656,
    FlyingSerpentKick = 101545,
    Jab = 108557,
    TouchOfDeath = 115080,
    Disable = 116095,
    Provoke = 115546,
    TouchOfKarma = 122470,
    LegacyOfTheEmperor = 115921,
    ChiWave = 115098,

}

local AuraList = {
    LegacyOfTheEmperor = 117666,
    Disable = 116095,
    CombatWisdom = 129914,
    TeachingsOfTheMonastery = 202090,
    Provoked = 116189,
}

-----------------------------------------------------
--- Toggle Options  
--- Defines the toggle options that will appear
--- in the rotation UI when this rotation is selected
-------------------------------------------------------
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
local cast = br.ActivePlayer.cast
---@type Player.buffs
local buffs = br.ActivePlayer.buffs
---@type Unit?
local target = br.ActivePlayer:TargetUnit()
  
local Energy
local Chi






--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()

    if not player:IsAlive() or player:IsMounted() then return end

    if not player:IsBusy() then
        if not buffs.up.LegacyOfTheEmperor() then
            return cast.LegacyOfTheEmperor("player")
        end
    end

    -- Change our target if we're still in combat but don't have one
    if player.InCombat and not player:ValidTarget("target") then
        player:TargetBest()
    end

    --if we are too busy or still don't have a good attackable target then return
    if player:IsBusy() or 
        not player:ValidTarget("target") or
        not UnitCanAttack("player", "target") then return
    end

    --if we still don't have a valid target return
    target = br.ActivePlayer:TargetUnit()
    if not target then return end

    -- Face target and close to melee range
    -- In MOP we don't really get an InCombat until we engage
    -- so we're going to check and see if target is attackable
    if UnitCanAttack("player", "target") then
        player:EnsureFacing(target)
        player:CloseToMelee(target)
        if player:DistanceToTarget() > 6 then
            if cast.able.Provoke() then
                return cast.Provoke("target")
            end
        end
    end

    --If we're not auto attacking then start
    if not player:IsAuto() then return player:StartAutoAttack() end

    --Regular rotation stuff

    if not br.Debuffs.up.Disable(target) and cast.able.Disable() then
        return cast.Disable("target")
    end

    if cast.able.ChiWave() then
        return cast.ChiWave("target")
    end

    if cast.able.TigerPalm() then
        return cast.TigerPalm()
    end

    if cast.able.BlackoutKick() then
        return cast.BlackoutKick()
    end

    if cast.able.Jab() then
        return cast.Jab()
    end






end

--------------------------------------------------------
--- DO NOT MODIFY BELOW THIS LINE
--- Registers the rotation with the framework
--------------------------------------------------------
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
