---@type _,br,_   #Must include typing to get intellisense in VSCode
local _,br,_ = ...  

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Monk BM 12.0.1"
local RotationShortName = "StockBM120001"
local RotationVersion = 1.0
local RotationDescription = "Standard BM rotation for 12.0.1 TWW "
local RotationTOCLower = 120001
local RotationTOCUpper = 120001
local RotationClassName = "MONK"
local RotationSpecializationID = 1  

-----------------------------------------------------
-- Not required, but will be run if needed to check
-- if character meets rotation requirements
-- Like certain specialization traits, gear, etc.
-----------------------------------------------------
local function CheckRequirements()
        return br.ActivePlayer.Specialization == RotationSpecializationID
end

-----------------------------------------------------
--- Spell List.  Yes I know the previous BR had all of
--- these inside the core code but they vary so much
--- by client release that to support multiple versions
--- we need to have them defined per rotation.
--- ------------------------------------------------
local SpellList = {
    TigerPalm = 100780,
    BlackoutKick = 205523,
    RisingSunKick = 107428,
    SpinningCraneKick = 322729,
    CracklingJadeLightning = 117952,
    Vivify = 116670,
    FortifyingBrew = 115203,
    BreathOfFire = 115181,
    InvokeNiuzaoTheBlackOx = 132578,
    SummonBlackOxStatue = 115315,
    CelestialBrew = 322507,
    KegSmash = 121253,
    PurifyingBrew = 119582,
    ChiBurst = 123986,
    LegSweep = 119381,
    TouchOfDeath = 322109,
    ExpelHarm = 322101,
    Provoke = 115546,
    TigersLust = 116841,
    SpearHandStrike = 116705,
    BlackOxBrew = 115399,
    WeaponsOfOrder = 387184,
    ExplodingKeg = 325153,
    RushingJadeWind = 116847,
    
}

--------------------------------------------------------
--- Aura List
--- List of Buffs to track in the player.buffs table or the Br.Debuffs table
--- --------------------------------------------------------
local AuraList = {
    CombatWisdom = 129914,
    TeachingsOfTheMonastery = 202090,
    Provoke = 116189,
    Bok_proc = 116768,
    Chi_Wave = 450380,
    Dance_Of_Chi_Ji = 325202,
    Invoke_Xuen_The_White_Tiger = 123904,
    Momentum_Boost_Damage = 451297,
    Momentum_Boost_Speed = 451298,
    Ordered_Elements = 451462,
    Spinning_Crane_Kick = 101546,
    Storm_Earth_and_Fire = 137639,
    Thunder_Fist = 393565,
    Vivacious_Vivification = 392883,
    Disable = 116095,
    PurifiedChi = 325092,
    BreathOfFire = 123725,
    BlackoutCombo = 228563,
   
}

--------------------------------------------------------
--- Talent List.  if you use Player:HasTalent() you can
--- use this list to define the talent ID rather than
--- typing in talentID
--- ------------------------------------------------------
local TalentList = {
    FluidityOfMotion = 387230,
    ScaldingBrew = 383698,
}

---------------------------------------------------------
--- Map your functions locally here for ease of use
--- -----------------------------------------------------
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

---@type number
local energy = br.ActivePlayer:Power()

---@type number
local stagger = br.unwrap(UnitStagger("player")) / player:MaxHealth()



local function Defensive()
   -- TODO check for healing spheres and either pull
   -- them in with SpinningCraneKick or use them
   -- with ExpelHarm depending on health defecit
   
end

--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()
    target = br.ActivePlayer:TargetUnit()
    energy = br.ActivePlayer:Power()
    stagger = br.unwrap(UnitStagger("player")) / player:MaxHealth()

    --if player is busy, mounted, or dead then return and save cycles
    if player:IsBusy() or player:IsMounted() or UnitIsDeadOrGhost("player") then return end

    --Run defensive
    local actionTaken = Defensive()
    --if actionTaken during defensive cycle then release and wait for 
    --next pulse cycle
    if actionTaken then return end
    
    --If in combat and no valid target then try to select closest in melee range
    if player.InCombat and not player:ValidTarget("target") then
        --print("No valid target, selecting closest in melee range")
        player:TargetClosestInMeleeRange()
        --TODO add logic for settings to define what this is
        -- You can also use player:TargetBest() which ignores range
        -- and just looks for lowest TTD of targets that are engaged with
        -- you.
    end

     --if we are too busy or still don't have a good attackable target then return
    if player:IsBusy() or 
        not player:ValidTarget("target") or
        not UnitCanAttack("player", "target") then return
    end

    -- pull the active player's target unit locally for ease of use
    -- if it isn't valid for some reason return
    target = br.ActivePlayer:TargetUnit()
    if not target then return end

   
    -- Face target and close to melee range
    -- In MOP we don't really get an InCombat until we engage
    -- so we're going to check and see if target is attackable
    if UnitCanAttack("player", "target") then
        player:EnsureFacing(target)
        player:CloseToMelee(target)
    end

    -- Interrupt 
    if target:IsInterruptable() then
        --try fast SHS first
        if cast.able.SpearHandStrike() then
            return cast.SpearHandStrike()
        end
        --then slower leg sweep
        if cast.able.LegSweep() and target:Distance() <= 8 then
            return cast.LegSweep()
        end

        --TODO Logic to look for ranged casts upon you and use
        --Paralysis to interrupt them 
    end

    if player:HealthPercent() <= 90 and cast.castCount.ExpelHarm() > 0 and cast.able.SpinningCraneKick() then
        log:Log("SCK to draw in healing spheres")
        return cast.SpinningCraneKick()
    end
    
    --Auto Attack
    if not player:IsAuto() then player:StartAutoAttack() return end

    --Regular Rotation, mostly from SimulationCraft with some adjustments

    if cast.able.RushingJadeWind() and target:Distance() <= 10 then return cast.RushingJadeWind() end

    if energy < 40 and cast.able.BlackOxBrew() then return cast.BlackOxBrew() end
    if buffs.up.PurifiedChi() and cast.able.CelestialBrew() then return cast.CelestialBrew() end
    if cast.able.BlackoutKick()    then
         return cast.BlackoutKick() 
    end
    if cast.able.ChiBurst() and not player:IsMoving() then return cast.ChiBurst() end
    if cast.able.WeaponsOfOrder() then return cast.WeaponsOfOrder() end
    if cast.able.RisingSunKick() and not player:HasTalent(TalentList.FluidityOfMotion) then 
        return cast.RisingSunKick() 
    end
    if cast.able.TigerPalm() and buffs.up.BlackoutCombo() then
        return cast.TigerPalm()
    end
    if cast.able.KegSmash() and target:Distance() <= 14 and player:HasTalent(TalentList.ScaldingBrew)  then
        return cast.KegSmash() 
    end
    if cast.able.KegSmash() and target:Distance() <= 14 and player:HasTalent(TalentList.ScaldingBrew)  then
        return cast.KegSmash() 
    end
    if cast.able.RisingSunKick() and player:HasTalent(TalentList.FluidityOfMotion) then 
        return cast.RisingSunKick() 
    end
    if cast.able.PurifyingBrew() and not buffs.up.BlackoutCombo() then 
        if stagger >= 0.05 then
            log:Log("Using Purifying Brew to reduce stagger of " .. string.format("%.2f",stagger*100) .. "%")
            return cast.PurifyingBrew() 
        end
    end
    if cast.able.TouchOfDeath() then return cast.TouchOfDeath() end
    if cast.able.BreathOfFire() and target:Distance() <= 10 and
        (not br.Debuffs.up.BreathOfFire(target) or br.Debuffs.remaining.BreathOfFire(target) < 3) 
        then 
            return cast.BreathOfFire() 
    end
    if cast.able.ExplodingKeg() and target:Distance() <= 30 then 
        return cast.atTargetGround.ExplodingKeg(target) 
    end
    if cast.able.KegSmash() and target:Distance() <= 14 then return cast.KegSmash() end
   
    --Don't waste cast on Invoke if we are far out and he has to run to target
    if cast.able.InvokeNiuzaoTheBlackOx() and target:Distance() <= 10 then 
        return cast.InvokeNiuzaoTheBlackOx() 
    end
    
    if energy >40-cast.cdRemains.KegSmash()*GetPowerRegen("player") then
        if cast.able.TigerPalm() then return cast.TigerPalm() end
    end

    if energy > 40 - cast.cdRemains.KegSmash()*GetPowerRegen("player") then
    
    
    if cast.able.SpinningCraneKick() and target:Distance() <= 8 then 
        return cast.SpinningCraneKick() end
    end

    if cast.able.TigerPalm() and not player.LastCastSpell == SpellList.TigerPalm then 
        return cast.TigerPalm() 
    end
    if cast.able.BlackoutKick() then return cast.BlackoutKick() end

end

--------------------------------------------------------
--- DO NOT MODIFY BELOW THIS LINE
--- Registers the rotation with the framework and 
--- follows that up with piping in some local variables
--- TODO, get rid of this section and have the framework
--- do this automatically
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