---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock DK Blood Rotation"
local RotationShortName = "StockDKBloodRotation"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Blood Death Knights. Only valid until level 10."
local RotationTOCLower = 110105
local RotationTOCUpper = 110105
local RotationClassName = "DEATHKNIGHT"
local RotationSpecializationID = 1

local SpellList = {
    DeathAndDecay = 43265,
    VampiricBlood = 55233,
    HeartStrike = 206930,
    DeathsCaress = 195292,
    DancingRuneWeapon = 49028,
    ChainsOfIce = 45524,
    Consumption = 274156,
    Tombstone = 219809,
    Bonestorm = 194844,
    DeathCoil = 47541,
    DeathStrike = 49998,
    MindFreeze = 47528,
    ReapersMark = 439843,
    BloodBoil = 50842,
    SoulReaper = 343294,
    BloodDrinker = 206931,
    Marrowrend = 195182,
    RaiseDead = 46585,
    DeathGrip = 49576,
    DeathsAdvance = 48265,


}

local AuraList = {
    BloodDraw = 454871,
    BloodLust = 2825,
    BoneShield = 195181,
    CorruptingRage = 374002,
    CrimsonScourge = 81141,
    DancingRuneWeapon = 81256,
    DeathAndDecay = 188290,
    ElementalPotionOfUltimatePower = 371028,
    FrostShield = 207203,
    OssifiedVitriol = 458745,
    Ossuary = 219788,
    RuneMastery = 374585,
    VampiricBlood = 55233,    
    ChainsOfIce = 45524,
    Lichborne = 49039,
    Exterminate = 441416,
    Bonestorm = 194844,
    ReaperOfSouls = 469172,
    DeathGrip = 51399,
    DeathsAdvance = 48265,

}

local HeroTalentList = {
    --https://warcraft.wiki.gg/wiki/API_C_ClassTalents.GetActiveHeroTalentSpec
    Sanlayn = 31,
    RiderOfTheApocalypse = 32,
    Deathbringer=33,
}

local TalentList = {
    ShatteringBone=377640,
   
}

--Specific counters to target's spells/abilities
local Counters = {
    {   target="Rank Overseer",
        spell="Wild Wallop",
        counter=SpellList.DeathsAdvance,
        auraIgnore=AuraList.DeathsAdvance,
        spellTarget="player",
     },
}
   


--TODO: Handle rotation special Toggles/Options. Do we even do it?
local ToggleOptions = {}
local function CreateToggles() end
local function CreateOptions() end

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
local runicPower = br.ActivePlayer:Power()
local runes = br.ActivePlayer:AlternatePower(Enum.PowerType.Runes)
local meleeRange = false



local function Defensive()
    -- No defensive logic for this basic rotation
    return false
end

local function actions_db_cds()
    if player:IsHeroClass(HeroTalentList.Deathbringer) then
        --log:Log("Using Deathbringer Cooldowns")
       if cast.able.ReapersMark()  then cast.ReapersMark() return true end
       if cast.able.DancingRuneWeapon() and target:Distance() <= 10 then cast.DancingRuneWeapon("player") return true end
       
       --bonestorm,if=buff.bone_shield.stack>=5&(!talent.shattering_bone.enabled|death_and_decay.ticking)
       if buffs.stacks.BoneShield() >= 5 
       and (not player:HasTalent(TalentList.ShatteringBone) or 
            buffs.up.DeathAndDecay())
       then 
            if cast.able.Bonestorm("player")  then cast.Bonestorm("player") return true end
       end

       --tombstone,if=buff.bone_shield.stack>=8&(!talent.shattering_bone.enabled|death_and_decay.ticking)&cooldown.dancing_rune_weapon.remains>=25
       if buffs.stacks.BoneShield() >= 8 and 
          (not player:HasTalent(TalentList.ShatteringBone) or 
           buffs.up.DeathAndDecay()) and
          (cast.cdRemains.DancingRuneWeapon() >= 25)
       then 
            if cast.able.Tombstone("player")  then cast.Tombstone("player") return true end
       end

       if cast.able.RaiseDead() and target:Distance() <= 10 then
            return cast.RaiseDead("player")     
       end
    end
    return false
end

local function Pulse()
    buffs = br.ActivePlayer.buffs
    target = br.ActivePlayer:TargetUnit()
    runicPower = br.ActivePlayer:Power()
    runes = br.ActivePlayer:AlternatePower(Enum.PowerType.Runes)

   

    ---@type table
    local enemiesMeleeFacing = br.ObjectManager:EnemiesFacingMelee()
    --log:Log("Enemies in Melee Facing Heart Strike: " .. #enemiesMeleeFacing)

    -- Return if we're busy channelling/Casting/Crafting/Gathering/etc
    -- Hopefully this will keep us from breaking gathering if we are 
    -- attacked but it isn't strong enough to interrupt the process
    if player:IsBusy() or 
            player:IsMounted() or 
            UnitIsDeadOrGhost("player")  
            then return end

    --Any Defensive spells or out of combat buffs, etc.
    if Defensive() then return true end

    --Check for a valid Target if not find one
    if player.InCombat and not player:ValidTarget("target")  then
        player:TargetClosestInMeleeRange()
    end

    --Testing Instance Priority Targeting
    player:InstanceSetPriorityTarget()


    --One final check for validity before we bail back to the rotation manager
    if not UnitCanAttack("player","target") then return end
    target = player:TargetUnit()
    if not target or UnitIsDeadOrGhost("target") then return end
    meleeRange = target:Distance() <= 7.5

    player:EnsureFacing(target)
    player:CloseToMelee(target)

    --Interrupts
    if target:IsInterruptable() then
        if cast.able.MindFreeze()  then
            return cast.MindFreeze("target")    
        end
    end


    --Preventatives/Counters
    --Death's Advance
    if target and target:IsCasting() then
        if player:HandleCounter(Counters,target) then return true end
        -- --See if the cast is one that we want to use Death's Advance for
        -- local castName,TTF = target:CastNameAndTTF()
        -- if castName then
        --     --Make sure we're not going to waste the DA by using it on a target that will die before the cast finishes
        --     if requiresDeathsAdvance(castName) and target:TTD() > TTF then
        --         log:Log("Using Death's Advance to prevent " .. castName .. " from " .. target.name)
        --         return cast.DeathsAdvance("player")
        --     end
        -- end
    end

    --Look for any likely unengaged targets within 30 yards to pull, if pull mode is enabled
    --We want to do this about 5 seconds into combat to allow for any initial aggro to settle
    if br.PullMode and player.InCombat then 
        local pullTarget = player:FindNonTargetingWithinRange(10,30)
        if pullTarget then
            if cast.able.DeathGrip(pullTarget.WoWGUID) and 
                not br.Debuffs.up.DeathGrip(target)  
                and player:CombatTime() > 5
                then
                    log:Log("Pulling target: " .. pullTarget.name .. " with Death Grip")
                    player:EnsureFacing(pullTarget)
                    br.SetFocus(pullTarget.guid)
                    return cast.DeathGrip("focus")

            end
        end
    end


    -- Tactical combat defensive, bonestorm heals for max of 10% so use at 90%
    if player:HealthPercent() < 90 and 
        cast.able.Bonestorm("player") 
        and buffs.stacks.BoneShield() >= 10 then
            return cast.Bonestorm("player")
    end

    -- Tactical combat defensive. If we're low on health and are undead
    -- with Lichborne then cast a Death Coil for some healing
    if player:HealthPercent() < 76 and 
        buffs.up.Lichborne() and
        cast.able.DeathCoil("player") then
            return cast.DeathCoil()
    end

    --if we aren't auto attacking then start
    if not player:IsAuto() then player:StartAutoAttack() return end

    --Begin main rotation
    --taken from SC 1115-02

    --vampiric_blood,if=!buff.vampiric_blood.up and target.distance<=10 so we don't waste it as we are navigating to the target
    if not buffs.up.VampiricBlood() and cast.able.VampiricBlood() and target:Distance() <= 10 then
        return cast.VampiricBlood("player")
    end

    --Deathbringer Cooldowns
    if actions_db_cds() then return true end

    if not buffs.up.DeathAndDecay() and 
        cast.able.DeathAndDecay() and 
        not player:IsMoving() and
        meleeRange
        then
            return cast.atTargetGround.DeathAndDecay(player)
        end
    

    if cast.able.DeathStrike("target")  then
        return cast.DeathStrike("target")
    end

    if buffs.up.Exterminate() and cast.able.Marrowrend() then
        return cast.Marrowrend("target")
    end

    if buffs.stacks.BoneShield() < 6 and not buffs.up.Bonestorm()
         and cast.able.Marrowrend() then
        return cast.Marrowrend("target")
    end

    if buffs.up.DancingRuneWeapon() and cast.able.BloodBoil("player") then
        return cast.BloodBoil("player")
    end
    if buffs.up.ReaperOfSouls() then
        if cast.cdRemains.DancingRuneWeapon() > 1 then
            if cast.able.SoulReaper() then
                return cast.SoulReaper()
            end
        end
    end

    if cast.able.DeathStrike() then
        return cast.DeathStrike("target")
    end

    if cast.able.Consumption() and target:Distance() <= 10 then
        return cast.Consumption("target")
    end

    if cast.able.BloodBoil("player") and meleeRange then
        return cast.BloodBoil("player")
    end

    if cast.able.HeartStrike() then
        return cast.HeartStrike("target")
    end

    if buffs.stacks.BoneShield()  >= 11 then
        if cast.able.DeathsCaress() and meleeRange then
            return cast.DeathsCaress("target")      
        end
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
    br.Debuffs:AuraSetup(AuraList)
end 