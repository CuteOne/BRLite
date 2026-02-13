---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Hunter Classic Era"
local RotationShortName = "StockHunterClassicEra"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation"
local RotationTOCLower = 11508
local RotationTOCUpper = 11508
local RotationClassName = "HUNTER"
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
   RaptorStrike = 2973,
   AspectOfTheMonkey = 13163,
   SerpentSting = 1978,
   HuntersMark = 1130,
   ArcaneShot=3044
}

local AuraList = {
   AspectOfTheMonkey = 13163,
   SerpentSting = 1978,
   HuntersMark = 1130,
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
    --   player:CloseToMelee(target)
        
    end

    if target:Distance() >20 and target:Distance() <=40 then
        if not br.Debuffs.up.HuntersMark(target) and cast.able.HuntersMark() then
            return cast.HuntersMark()
        end
    end

     --If we're not auto attacking then start
    if cast.inRange.ArcaneShot() then
       if not br.api.IsAutoShot() then return br.api.StartAutoShot() end
       if not br.Debuffs.up.SerpentSting(target) and cast.able.SerpentSting() then
            return cast.SerpentSting()
       end
    end

    if cast.inRange.ArcaneShot() then
        if cast.able.ArcaneShot() then
            return cast.ArcaneShot()
        end
    end

   
    if target:Distance() <= br.api.MeleeDistance then
        if not player:IsAuto() then return player:StartAutoAttack() end
    end
    --br.StartAttack(target.WoWGUID)

    --Defensive items while in combat
    if player:HealthPercent() < 80 then
   
    end

    if target:Distance() <= br.api.MeleeDistance then
        if cast.able.RaptorStrike() then
            return cast.lowestRank.RaptorStrike("target")
        end
    end




    --Regular rotation stuff

    

    

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
