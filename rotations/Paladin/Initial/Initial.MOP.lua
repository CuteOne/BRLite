---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Paladin Initial MOP"
local RotationShortName = "StockPaladinInitialMOP"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation"
local RotationTOCLower = 50503
local RotationTOCUpper = 50503
local RotationClassName = "PALADIN"
local RotationSpecializationID = 1  --Starter Spec ID




-----------------------------------------------------
-- Not required, but will be run if needed to check
-- if character meets rotation requirements
-- Like certain specialization traits, gear, etc.
-----------------------------------------------------
local function CheckRequirements()
    return true
end

-----------------------------------------------------
--- Spell List.  Yes I know the previous BR had all of
--- these inside the core code but they vary so much
--- by client release that to support multiple versions
--- we need to have them defined per rotation.
--- ------------------------------------------------
local SpellList = {
    CrusaderStrike = 35395,
    SealOfCommand = 105361,
    Judgement = 20271,
    HammerOfJustice = 853,
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
  
local Mana

--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()

    Mana = player:PowerPercent()

    if not player:IsAlive() or player:IsMounted() then return end

    if not player:IsBusy() then
        -- perm buffs
        
    end

    if player.InCombat and UnitIsTapDenied("target") then
        br.ClearTarget()
        return
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
        
    end

    --If we're not auto attacking then start
    if not player:IsAuto() then return player:StartAutoAttack() end

    if target:Distance() <= 10 and target:IsInterruptable() then
        if cast.able.HammerOfJustice() then
            return cast.HammerOfJustice("target")
        end
    end

    if cast.able.Judgement() then
        return cast.Judgement("target")
    end

    if cast.able.CrusaderStrike() then
        return cast.CrusaderStrike("target")
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
