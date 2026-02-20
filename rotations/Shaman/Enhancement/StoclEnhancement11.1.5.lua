--@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Shaman Enhancement"
local RotationShortName = "StockShamanEnhancement"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Enhancement Shamans. Only valid until level 10."
local RotationTOCLower = 110105
local RotationTOCUpper = 110105
local RotationClassName = "SHAMAN"
local RotationSpecializationID = 2

local SpellList = {
    FlameShock = 470411,
    LightningBolt = 188196,
    Stormstrike = 17364,
    LavaBurst = 51505,
    HealingSurge = 8004,
    LightningShield = 192106,
    LavaLash = 60103,
    GhostWolf = 2645,
    Skyfury = 462854,
    WindfuryWeapon = 33757,
    FlameTongueWeapon = 318038,
    DoomWinds = 384352,
    CrashLightning = 187874,
    PrimordialStorm = 1218090,
    FeralSpirit = 51533,
    EarthElemental = 198103,
    SurgingTotem = 444995,
    ElementalBlast = 117014,
    PrimordialWave = 375982,
    EarthShield = 974,

}

local AuraList = {
    AshenCatalyst = 390371,
    Bloodlust = 2825,
    CorruptingRage = 374002,
    DoomWinds = 466772,
    EarthElemental = 188616,
    EarthenWeapon = 392375,
    ElementalBlast_CriticalStrike = 118522,
    ElementalBlast_Haste = 173183,
    ElementalBlast_Mastery = 173183,
    FeralSpirit = 333957,
    Flurry = 382889,
    ForcefulWinds = 262652,
    HotHands = 215785,
    LegacyofTheFrostWitch = 384451,
    MaelstromWeapon = 344179,
    PrimordialStorm = 1218047,
    SplinteredElements = 382043,
    Stormblast = 470466,
    Stormsurge =201846,
    FlameShock = 188389,
    LightningShield = 192106,
    GhostWolf = 2645,
    Skyfury = 462854,
    Windfury = 5401,
    FlameTongue = 5400,
    LashingFlames=334168,
    EarthShield=974,
}

local TalentList = {
    LashingFlames = 334046,
    ElementalAssault = 210853,
    MoltenAssault = 334033,
    LegacyofTheFrostWitch = 384452,
    DeeplyRootedElements = 378270,
    Ascendance = 114051,

   
}


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
local mana = br.ActivePlayer:Power()
local meleeRange = false




local function Opener()
    --flame_shock,if=!ticking
    if not br.Debuffs.up.FlameShock(target) then
        if cast.able.FlameShock() then
            return cast.FlameShock("target")
        end
    end

    --primordial_wave,if=(buff.maelstrom_weapon.stack>=4)&dot.flame_shock.ticking
    if (buffs.stacks.MaelstromWeapon() >= 4) and br.Debuffs.up.FlameShock(target) then
        if cast.able.PrimordialWave() then
            return cast.PrimordialWave()
        end
    end

    --feral_spirit,if=buff.legacy_of_the_frost_witch.up|!talent.legacy_of_the_frost_witch.enabled
    if buffs.up.LegacyofTheFrostWitch() or not player:HasTalent(TalentList.LegacyofTheFrostWitch) then
        if cast.able.FeralSpirit() then
            return cast.FeralSpirit()
        end
    end

    --doom_winds,if=buff.legacy_of_the_frost_witch.up|!talent.legacy_of_the_frost_witch.enabled
    if buffs.up.LegacyofTheFrostWitch() or not player:HasTalent(TalentList.LegacyofTheFrostWitch) then
        if cast.able.DoomWinds() then
            return cast.DoomWinds()
        end
    end

    --primordial_storm,if=(buff.maelstrom_weapon.stack>=10)&(buff.legacy_of_the_frost_witch.up|!talent.legacy_of_the_frost_witch.enabled)
    if (buffs.stacks.MaelstromWeapon() >= 10) and (buffs.up.LegacyofTheFrostWitch() or not player:HasTalent(TalentList.LegacyofTheFrostWitch)) then
        if cast.able.PrimordialStorm() then
            return cast.PrimordialStorm()
        end
    end

    --elemental_blast,if=((buff.maelstrom_weapon.stack>=5&!talent.deeply_rooted_elements.enabled)|(talent.deeply_rooted_elements.enabled&buff.maelstrom_weapon.stack>=7))&(!buff.legacy_of_the_frost_witch.up|buff.ascendance.up|talent.deeply_rooted_elements.enabled)
    if (((buffs.stacks.MaelstromWeapon() >= 5 and 
        not player:HasTalent(TalentList.DeeplyRootedElements)) 
        or (player:HasTalent(TalentList.DeeplyRootedElements) 
        and buffs.stacks.MaelstromWeapon() >= 7)) 
        and (not buffs.up.LegacyofTheFrostWitch() or 
        (player:HasTalent(TalentList.Ascendance) and buffs.up.Ascendance() ) or 
        player:HasTalent(TalentList.DeeplyRootedElements))) then
        if cast.able.ElementalBlast() then
            return cast.ElementalBlast()
        end
    end

    --lightning_bolt,if=((buff.maelstrom_weapon.stack>=5&!talent.deeply_rooted_elements.enabled)|(talent.deeply_rooted_elements.enabled&buff.maelstrom_weapon.stack>=7))&(!buff.legacy_of_the_frost_witch.up|buff.ascendance.up|talent.deeply_rooted_elements.enabled)
    if (((buffs.stacks.MaelstromWeapon() >= 5 and 
        not player:HasTalent(TalentList.DeeplyRootedElements)) or 
        (player:HasTalent(TalentList.DeeplyRootedElements) and buffs.stacks.MaelstromWeapon() >= 7)) 
        and (not buffs.up.LegacyofTheFrostWitch() or 
        (player:HasTalent(TalentList.Ascendance) and buffs.up.Ascendance() ) or 
        player:HasTalent(TalentList.DeeplyRootedElements))) then
        if cast.able.LightningBolt() then
            return cast.LightningBolt()
        end
    end

    if cast.able.Stormstrike() then
        return cast.Stormstrike()
    end

    if cast.able.LavaLash() then
        return cast.LavaLash()
    end









end

local function Pulse()
    if not player:IsBusy() and not player:IsMounted() then 
        if player:HealthPercent() < 50 and cast.able.HealingSurge() then
            return cast.HealingSurge("player")
        end
        if not buffs.up.LightningShield("player") and cast.able.LightningShield() then
            return cast.LightningShield("player")
        end
        if not buffs.up.Skyfury("player") and cast.able.Skyfury() then
            return cast.Skyfury("player")   
        end
        if player:EnsureMHWeaponEnchant(SpellList.WindfuryWeapon, AuraList.Windfury) then return true end
        if player:EnsureOHWeaponEnchant(SpellList.FlameTongueWeapon, AuraList.FlameTongue) then return true end
       
        if not buffs.up.EarthShield("player") and cast.able.EarthShield() then
            return cast.EarthShield("player")
        end
    end

    if player:IsMoving() and not IsSubmerged("player") then
       
        if not player:IsBusy() 
        and not player.InCombat 
        and not buffs.up.GhostWolf()
        and not player:IsMounted()
        
        then
           
            if cast.able.GhostWolf() then
                return cast.GhostWolf("player")
            end
            return
        end
    
    end

     --Check for a valid Target if not find one
    if player.InCombat and (player:TargetUnit() == nil or UnitIsDeadOrGhost("target"))  then
        log:Log("No valid target, selecting closest in melee range")
        player:TargetClosestInMeleeRange(15)
    end

    --Final validations
    if not UnitCanAttack("player","target") then return end
    target = player:TargetUnit()
    if not target or UnitIsDeadOrGhost("target") then
        --log:Log("Selected target is not valid after selection, returning to rotation manager")
         return 
   end
    meleeRange = target:Distance() <= 7.5

    -- if target:Distance() > 6 then
    --     print("Target Distance: " .. tostring(target:Distance()) )
    -- end

    
     player:EnsureFacing(target)
     player:CloseToMelee(target)
    


    if not player:IsAuto() then return player:StartAutoAttack() end


     if cast.able.DoomWinds() then
        return cast.DoomWinds()
     end
     --primordial_wave,if=dot.flame_shock.ticking&(raid_event.adds.in>action.primordial_wave.cooldown|raid_event.adds.in<6)
     if br.Debuffs.up.FlameShock(target) and cast.able.PrimordialWave() then
        return cast.PrimordialWave()
     end

     --elemental_blast,if=((!talent.overflowing_maelstrom.enabled&buff.maelstrom_weapon.stack>=5)|(buff.maelstrom_weapon.stack>=9))
        if (((not player:HasTalent(TalentList.OverflowingMaelstrom) and buffs.stacks.MaelstromWeapon() >= 5) or (buffs.stacks.MaelstromWeapon() >= 9)) and cast.able.ElementalBlast()) then
            return cast.ElementalBlast()
        end

    --lightning_bolt,if=buff.maelstrom_weapon.stack>=9
    if buffs.stacks.MaelstromWeapon() >= 9 and cast.able.LightningBolt() then
        return cast.LightningBolt()
     end

     --lava_lash,if=(buff.hot_hand.up&(buff.ashen_catalyst.stack=buff.ashen_catalyst.max_stack))|(dot.flame_shock.remains<=2&!talent.voltaic_blaze.enabled&talent.molten_assault.enabled)|(talent.lashing_flames.enabled&(debuff.lashing_flames.down))
     --print("ashen catalyst max stacks: " .. tostring(buffs.maxStacks.AshenCatalyst()) )
     if (buffs.up.HotHands() and (buffs.stacks.AshenCatalyst() == 8)) or br.Debuffs.remaining.FlameShock(target) <= 2 then
        if cast.able.LavaLash() then
            return cast.LavaLash()
        end
     end

     --stormstrike,if=buff.doom_winds.up|buff.stormblast.stack>0
     if buffs.up.DoomWinds() or buffs.stacks.Stormblast() > 0 then
        if cast.able.Stormstrike() then
            return cast.Stormstrike()
        end
     end

     --lava_lash,if=buff.hot_hand.up
        if buffs.up.HotHands() then
            if cast.able.LavaLash() then
                return cast.LavaLash()
            end
        end

    if cast.able.Stormstrike() then
        return cast.Stormstrike()
    end

     --elemental_blast,if=buff.maelstrom_weapon.stack>=5&!buff.primordial_storm.up
        if buffs.stacks.MaelstromWeapon() >= 5 and not buffs.up.PrimordialStorm() then
            if cast.able.ElementalBlast() then
                return cast.ElementalBlast()
            end
        end

        --	lightning_bolt,if=buff.maelstrom_weapon.stack>=5&!buff.primordial_storm.up
        if buffs.stacks.MaelstromWeapon() >= 5 and not buffs.up.PrimordialStorm() then
            if cast.able.LightningBolt() then
                return cast.LightningBolt()
            end
        end

        --crash_lightning
        if cast.able.CrashLightning() then
            return cast.CrashLightning()
        end

        --earth_elemental
        if cast.able.EarthElemental() then
            return cast.EarthElemental()
        end

        --flame_shock
        if cast.able.FlameShock() then
            return cast.FlameShock()
        end


--     --	primordial_storm,if=(buff.maelstrom_weapon.stack>=10|buff.primordial_storm.remains<=4&buff.maelstrom_weapon.stack>=5)
--     if (buffs.stacks.MaelstromWeapon() >= 10 
--         or (buffs.up.PrimordialStorm() and buffs.remaining.PrimordialStorm() <= 4 and buffs.stacks.MaelstromWeapon() >= 5)
--         ) then
--         if cast.able.PrimordialStorm() then
--             return cast.PrimordialStorm()
--         end
--     end

--     --feral_spirit,if=(cooldown.doom_winds.remains>25|cooldown.doom_winds.remains<=5)
--     if (cast.cdRemains.DoomWinds() > 25 
--         or cast.cdRemains.DoomWinds() <= 5) then
--         if cast.able.FeralSpirit() then
--             return cast.FeralSpirit()
--         end
--     end

--    if cast.able.SurgingTotem() then
--         return cast.atTargetGround.SurgingTotem(target)
--     end

--     --doom_winds
--     if cast.inRange.Stormstrike() then
--         -- Melee Range Abilities
--         if cast.able.DoomWinds() then
--             return cast.DoomWinds()
--         end
--     end

    
--     --	stormstrike,if=buff.doom_winds.up|buff.stormblast.stack>0
--     if buffs.up.DoomWinds() or buffs.stacks.Stormblast() > 0 then
--         if cast.able.Stormstrike() then
--             return cast.Stormstrike()
--         end
--     end

--     --elemental_blast,if=buff.maelstrom_weapon.stack>=5&!buff.primordial_storm.up
--     if buffs.stacks.MaelstromWeapon() >= 5 and not buffs.up.PrimordialStorm() then
--         if cast.able.ElementalBlast() then
--             return cast.ElementalBlast()
--         end
--     end
--     --lightning_bolt,if=buff.maelstrom_weapon.stack>=5&!buff.primordial_storm.up
--     if buffs.stacks.MaelstromWeapon() >= 5 and not buffs.up.PrimordialStorm() then
--         if cast.able.LightningBolt() then
--             return cast.LightningBolt()
--         end
--     end

--     --flame_shock,if=!ticking
--     if not br.Debuffs.up.FlameShock(target) then
--         if cast.able.FlameShock() then
--             return cast.FlameShock("target")
--         end
--     end

--     --primordial_wave,if=dot.flame_shock.ticking
--     if br.Debuffs.up.FlameShock(target) then
--         if cast.able.PrimordialWave() then
--             return cast.PrimordialWave()
--         end
--     end

--     --stormstrike,if=buff.doom_winds.up|buff.stormblast.stack>0
--     if buffs.up.DoomWinds() or buffs.stacks.Stormblast() > 0 then
--         if cast.able.Stormstrike() then
--             return cast.Stormstrike()
--         end
--     end

--     --stormstrike,if=charges_fractional>=1.8
--     if cast.charges.Stormstrike() >= 1.8 then
--         if cast.able.Stormstrike() then
--             return cast.Stormstrike()
--         end
--     end


--     --lava_lash,if=(talent.lashing_flames.enabled&(debuff.lashing_flames.remains<2))
--     if player:HasTalent(TalentList.LashingFlames) and 
--         (br.Debuffs.remaining.LashingFlames(target) < 2) then
--         if cast.able.LavaLash() then
--             return cast.LavaLash()
--         end
--     end

--     --stormstrike
--     if cast.able.Stormstrike() then
--         return cast.Stormstrike()
--     end

--     --elemental_blast,if=buff.maelstrom_weapon.stack>=5&!buff.primordial_storm.up
--     if buffs.stacks.MaelstromWeapon() >= 5 and not buffs.up.PrimordialStorm() then
--         if cast.able.ElementalBlast() then
--             return cast.ElementalBlast()
--         end
--     end

--     --lightning_bolt,if=buff.maelstrom_weapon.stack>=5&!buff.primordial_storm.up
--     if buffs.stacks.MaelstromWeapon() >= 5 and not buffs.up.PrimordialStorm() then
--         if cast.able.LightningBolt() then
--             return cast.LightningBolt()
--         end
--     end

--     --lava_lash,if=talent.elemental_assault.enabled&talent.molten_assault.enabled&dot.flame_shock.ticking
--     if player:HasTalent(TalentList.ElementalAssault) and 
--         player:HasTalent(TalentList.MoltenAssault) and 
--         br.Debuffs.up.FlameShock(target) then
--         if cast.able.LavaLash() then
--             return cast.LavaLash()
--         end
--     end

--     if cast.able.CrashLightning() then
--         return cast.CrashLightning()
--     end

--     if cast.able.EarthElemental() then
--         return cast.EarthElemental()
--     end

--     if cast.able.FlameShock() then
--         return cast.FlameShock("target")
--     end

--     if cast.able.Stormstrike() then
--         return cast.Stormstrike()
--     end





    
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
    rotation.Pulse = Pulse
    rotation.SpellList = SpellList or {}
    br.ActivePlayer:BuffSetup(AuraList)
    br.Debuffs:AuraSetup(AuraList)
end 