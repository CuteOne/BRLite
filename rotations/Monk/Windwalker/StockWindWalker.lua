---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Monk WW 11.1.5"
local RotationShortName = "StockWW110105"
local RotationVersion = 1.0
local RotationDescription = "Standard WW rotation for 11.1.5 TWW "
local RotationTOCLower = 110105
local RotationTOCUpper = 110105
local RotationClassName = "MONK"
local RotationSpecializationID = 3  



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
    BlackoutKick = 100784,
    SpinningCraneKick = 101546,
    LegSweep = 119381,
    Vivify = 116670,
    CracklingJadeLightning = 117952,
    ExpelHarm = 322101,
    Provoke = 115546,
    RisingSunKick = 107428,
    ArcaneTorrent = 129597,  --TODO move racial determination to player object
     Disable = 116095,
     TouchOfKarma = 122470,
     Invoke_Xuen_The_White_Tiger = 123904,
     Storm_Earth_and_Fire = 137639,
     FistsOfFury = 113656,
     TouchOfDeath = 322109,
     StrikeOfTheWindlord = 392983,
     RingOfPeace = 116844,
}

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
   
}

local TalentList = {
    Ordered_Elements = 451463,
    Storm_Earth_and_Fire = 137639,
}

-----------------------------------------------------
--- Toggle Options  
--- Defines the toggle options that will appear
--- in the rotation UI when this rotation is selected
--- ----------------------------------------------------
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



local function CreateToggles()
    --No toggles for this basic rotation
end


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
local energy = br.ActivePlayer:Power()
local chi    = br.ActivePlayer:AlternatePower(Enum.PowerType.Chi)
local chiDeficit = br.ActivePlayer:AlternatePowerDeficit(Enum.PowerType.Chi)



local function Defensive()
    -- Defensive Stuff
    if player:HealthPercent() < 90 and buffs.up.Chi_Wave() and buffs.up.Vivacious_Vivification() then
        print("Low HealthPercent: " .. tostring(player:HealthPercent()) .. "% - Casting Expel Harm")
        if cast.able.Vivify() then
            cast.Vivify("player")
            return true
        end
    end
    if player:HealthPercent() < 70 then
      
        if cast.able.Vivify() then
            cast.Vivify("player")
            return true
        end
    end

    if player:HealthPercent()  < 40 then
        cast.atTargetGround.RingOfPeace(player)
        if cast.able.Vivify() then
            cast.Vivify("player")
            return true
        end
    end
    return false
end

local function cooldowns()
    target = br.ActivePlayer:TargetUnit()
    if target == nil then return false end
    --tiger_palm,if=(target.time_to_die>14)&!cooldown.invoke_xuen_the_white_tiger.remains&(chi<5&!talent.ordered_elements|chi<3)&(combo_strike|!talent.hit_combo)
    if target:TTD() > 14 and cast.cdRemains.Invoke_Xuen_The_White_Tiger() <= 0
         and (chi < 5 and not player:HasTalent(TalentList.Ordered_Elements) or chi < 3) then
        if cast.able.TigerPalm() then
            cast.TigerPalm("target")
            return true
        end
    end
    if cast.able.Invoke_Xuen_The_White_Tiger() then
        cast.Invoke_Xuen_The_White_Tiger("target")
        return true
    end

    if cast.able.Storm_Earth_and_Fire() then
        cast.Storm_Earth_and_Fire("target")
        return true
    end

    if cast.able.TouchOfKarma() and player:HealthPercent() < 50 then
        cast.TouchOfKarma("player")
        return true
    end
    return false
end

local function Opener()
    if chi < 6 then
        if cast.able.TigerPalm() then
            cast.TigerPalm("target")
            return true
        end
    end
    if player:HasTalent(TalentList.Ordered_Elements) then
        if cast.able.RisingSunKick() then
            cast.RisingSunKick("target")    
            return true
        end
    end
    return false
end

local function fallback()
    if chi < 5 then
        if cast.able.SpinningCraneKick() then
            cast.SpinningCraneKick("target")
            return true
        end
    end
    if chi > 3 then
        if cast.able.RisingSunKick() then
            cast.RisingSunKick("target")
            return true
        end
    end
    if chi > 5 then
        if cast.able.TigerPalm() then
            cast.TigerPalm("target")
            return true
        end 
    end
    return false
end



--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()
    target = br.ActivePlayer:TargetUnit()
    chi    = br.ActivePlayer:AlternatePower(Enum.PowerType.Chi)
    chiDeficit = br.ActivePlayer:AlternatePowerDeficit(Enum.PowerType.Chi)
    energy = br.ActivePlayer:Power()

    if not player:IsBusy() and not player:IsMounted() then
        local actioned = Defensive()
        if actioned then 
            return 
        end
    end

    if player.InCombat and not player:ValidTarget("target") then
        print("No valid target, selecting closest in melee range")
        player:TargetClosestInMeleeRange()
    end

     --if we are too busy or still don't have a good attackable target then return
    if player:IsBusy() or 
        not player:ValidTarget("target") or
        not UnitCanAttack("player", "target") then return
    end

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
    
    --Auto Attack
    if not player:IsAuto() then         player:StartAutoAttack()        return
    end

    if not br.Debuffs.up.Disable(target) then
        if cast.able.Disable() then
            return cast.Disable("target")
        end
    end

    if player:DistanceToTarget() > 6 then
        return
    end

    if player:CombatTime() < 4 then
        local actions = Opener()
        if actions then return end
    end

    if player:HasTalent(TalentList.Storm_Earth_and_Fire) then
       local actions = cooldowns()
       if actions then return end
    end


    --Regular Rotation Elements
    if chi<5 and energy<55 then
        --TODO switch to player object to determine racial
        if cast.able.ArcaneTorrent() then
            return cast.ArcaneTorrent()
        end
    end

    if buffs.stacks.Dance_Of_Chi_Ji() == 2 then
        if cast.able.SpinningCraneKick() then
            return cast.SpinningCraneKick()
        end
    end

    if chiDeficit >= 2 
        and buffs.stacks.TeachingsOfTheMonastery() < 4 
        and buffs.up.Ordered_Elements() 
        and cast.cdRemains.FistsOfFury() ==0
        and chi < 3 then
            if cast.able.TigerPalm() then
                return cast.TigerPalm()
            end 
    end

    if cast.able.TouchOfDeath() then
        return cast.TouchOfDeath()
    end

    if not buffs.up.Invoke_Xuen_The_White_Tiger() and
        player.LastCastSpell == SpellList.TigerPalm
        and buffs.up.Storm_Earth_and_Fire() then
            if cast.able.RisingSunKick() then
                return cast.RisingSunKick()
            end
    end

    if cast.cdRemains.FistsOfFury() < 5 and 
        cast.cdRemains.Invoke_Xuen_The_White_Tiger() > 15 then
            if cast.able.StrikeOfTheWindlord() then
                return cast.StrikeOfTheWindlord()
            end
    end

    if cast.cdRemains.StrikeOfTheWindlord()  >1 and
        cast.cdRemains.Invoke_Xuen_The_White_Tiger() > 10
    then
        if cast.able.FistsOfFury() then
            return cast.FistsOfFury()
        end 
    end

    if chi > 4 or chi > 2 and energy > 50 or cast.cdRemains.FistsOfFury() > 2 then
        if cast.able.RisingSunKick() then
            return cast.RisingSunKick()
        end
    end

    if chiDeficit >=2 then
       if cast.able.TigerPalm() then
            return cast.TigerPalm()
       end
    end

    if buffs.up.Dance_Of_Chi_Ji() and buffs.remaining.Dance_Of_Chi_Ji() <= cast.gcdMax()*3 then
        if cast.able.SpinningCraneKick() then
            return cast.SpinningCraneKick()
        end
    end
    local actions = fallback()
    if actions then return end
  


    





    
    

    
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
