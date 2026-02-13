---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock BM Hunter Midnight"
local RotationShortName = "StockBMHunterMidnight"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation"
local RotationTOCLower = 120000
local RotationTOCUpper = 120001
local RotationClassName = "HUNTER"
local RotationSpecializationID = 1




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
    AutoShot = 75,
   HuntersMark = 257284,
   ArcaneShot=185358,
   SteadyShot=56641,
   WingClip=195645,
   Disengage=781,
   KillCommand=34026,
   MendPet =136,
   BarbedShot = 217200,

}

local AuraList = {
   HuntersMark = 257284,
   WingClip=195645,
   BarbedShot = 217200,
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
local pet = br.ActivePlayer:Pet()
  
local Focus = 0
local FocusDeficit = 0

--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()

    Focus = player:Power()
    FocusDeficit = player:PowerDeficit()
    pet = br.ActivePlayer:Pet()

    if not player:IsAlive() or player:IsMounted() then return end

    if not player:IsBusy() then
        if pet and pet:HealthPercent() < 50 and cast.able.MendPet() then
            return cast.MendPet()   
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
        if pet then
            local petTarget = pet:GetTarget()
            if not petTarget or petTarget ~= target.guid then
                if cast.inRange.KillCommand("target") and cast.able.KillCommand("target") then
                    return cast.KillCommand("target")
                end
            end
        end
        player:EnsureFacing(target)
    --   player:CloseToMelee(target)
        
    end

     if cast.inRange.HuntersMark() then
         if not br.Debuffs.up.HuntersMark(target) and cast.able.HuntersMark() then
             return cast.HuntersMark()
         end
     end
     if cast.able.BarbedShot() then
            if not br.Debuffs.up.BarbedShot(target) then
                return cast.BarbedShot()
            end
     end
     

     --If we're not auto attacking then start
    if cast.inRange.AutoShot() then
       if not br.api.IsAutoShot() then return br.api.StartAutoShot() end
    end

    if cast.inRange.WingClip() then
        if not br.Debuffs.up.WingClip(target) and cast.able.WingClip() then
            return cast.WingClip()
        end
    end

    if target:Distance() <= br.api.MeleeDistance and br.Debuffs.up.WingClip(target) and target:IsTargettingPlayer() then
        if cast.able.Disengage() then
            return cast.Disengage()
        end
    end


    if FocusDeficit >= 40 then
         if cast.able.SteadyShot() then
            return cast.SteadyShot()
        end
    end

    if cast.inRange.ArcaneShot() then
        if cast.able.ArcaneShot() then
            return cast.ArcaneShot()
        end
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
