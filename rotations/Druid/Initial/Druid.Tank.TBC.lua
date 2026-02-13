---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Druid Tank TBC Classic"
local RotationShortName = "StockDruidTank2.5.5"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation"
local RotationTOCLower = 20505
local RotationTOCUpper = 20505
local RotationClassName = "DRUID"
local RotationSpecializationID = 3  --Starter Spec ID




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
    MarkOfTheWild = 1126,
    MarkOfTheWild2 = 5232,
    Thorns=467,
    Moonfire = 8921,
    HealingTouch = 5185,
    Rejuvenation = 774,
    Rejuvenation2 = 1058,
    EntanglingRoots = 339,
    Wrath = 5176,
}

local AuraList = {
    MarkOfTheWild = 1126,
    MarkOfTheWild2 = 5232,
    Thorns=467,
    Moonfire = 8921,
    HealingTouch = 5185,    
    Rejuvenation = 774,
    Rejuvenation2 = 1058,
    EntanglingRoots = 339,
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
        if cast.able.MarkOfTheWild2() then
            if not buffs.up.MarkOfTheWild2() then
                return cast.MarkOfTheWild2("player")
            end
        end
        if not buffs.up.Thorns() and cast.able.Thorns() then
            return cast.Thorns("player")
        end
        if not player.InCombat and player:HealthPercent() < 70 and Mana >= 60 then
            if cast.able.HealingTouch() then
                return cast.HealingTouch("player")
             end
        end
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

    --Defensive items while in combat
    if player:HealthPercent() < 80 then
        if cast.able.Rejuvenation2() and not buffs.up.Rejuvenation2() then
            return cast.Rejuvenation2("player")
        end
        
    end

    if target:Distance() <= 30 and 
        Mana >= 80 and
        not br.Debuffs.up.Moonfire(target) and cast.able.Moonfire() and player.LastCastSpell ~= SpellList.Moonfire then
        return cast.Moonfire("target")
    end

    --Regular rotation stuff

    if UnitCreatureType("target") == "Humanoid" and 
    target:Distance() <= 10 and  
    not br.Debuffs.up.EntanglingRoots(target) and
    target:HealthPercent() <= 30 and
    cast.able.EntanglingRoots() then
        return cast.EntanglingRoots("target")
    end
    
    if br.Debuffs.up.EntanglingRoots(target) and target:Distance() <= 10 and
    cast.able.Wrath() then
        return cast.Wrath("target")
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
