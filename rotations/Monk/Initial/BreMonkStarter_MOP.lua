---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Brewmaster Monk Starter MOP"
local RotationShortName = "BreMonkStarter_MOP"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Brewmaster Monks. Only valid until level 10."
local RotationTOCLower = 50503  --MOP 5.5.3 
local RotationTOCUpper = 50503
local RotationClassName = "MONK"
local RotationSpecializationID = 5  --Starter Spec ID



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
    Jab = 108557,
    TigerPalm = 100787,
    BlackoutKick = 100784,
    
}

local AuraList = {
    
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
  
local energy = br.ActivePlayer:Power()
local chi = br.ActivePlayer:AlternatePower(Enum.PowerType.Chi)
local chiDeficit = br.ActivePlayer:AlternatePowerDeficit(Enum.PowerType.Chi)




--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()
  
    energy = br.ActivePlayer:Power()
    chi = br.ActivePlayer:AlternatePower(Enum.PowerType.Chi)
    chiDeficit = br.ActivePlayer:AlternatePowerDeficit(Enum.PowerType.Chi)

    if not player:IsAlive() or player:IsMounted() then return end
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

     if UnitCanAttack("player", "target") then
        player:EnsureFacing(target)
        player:CloseToMelee(target)
    end

    if not player:IsAuto() then player:StartAutoAttack() return end

    if chiDeficit>= 2 and  cast.able.Jab() then
        return cast.Jab()   
    end

    if cast.able.TigerPalm() and player.LastCastSpell ~= SpellList.TigerPalm then
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
