---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Brewmaster Monk Starter"
local RotationShortName = "BrewMonkStarter"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Brewmaster Monks. Only valid until level 10."
local RotationTOCLower = 120001
local RotationTOCUpper = 120001
local RotationClassName = "MONK"
local RotationSpecializationID = 5  --Starter Spec ID



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
    TigerPalm = 100780,
    BlackoutKick = 100784,
    SpinningCraneKick = 101546,
    LegSweep = 119381,
    Vivify = 116670,
    CracklingJadeLightning = 117952,
    ExpelHarm = 322101,
    Provoke = 115546,
}

local AuraList = {
    Stagger = 124275,
}



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
---@type Unit?




--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()

    if not player:IsAlive() or player:IsMounted() then return end
    if player.InCombat and not player:ValidTarget("target") then
        player:TargetClosestInMeleeRange()
    end

    target = br.ActivePlayer:TargetUnit()

    if not player:IsBusy() and player:HealthPercent() <= 80 then 
        if cast.able.Vivify() then
            return cast.Vivify("player")
        end
    end

    if not target or player:IsBusy() or 
        not player:ValidTarget("target") or
        not UnitCanAttack("player", "target") then return
    else
        player:EnsureFacing()
        player:CloseToMelee()
    end

    if not player:IsAuto() then 
        return player:StartAutoAttack()
    end


    if cast.able.TigerPalm() then
        return cast.TigerPalm()
    end

    if cast.able.BlackoutKick() then
        return cast.BlackoutKick()
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
    rotation.Pulse = Pulse
    rotation.SpellList = SpellList or {}
    br.ActivePlayer:BuffSetup(AuraList)
    br.Debuffs:AuraSetup(AuraList)
end 
