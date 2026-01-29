---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Warlock Demonology"
local RotationShortName = "StockDemonology"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Demonology Warlocks. Only valid until level 10."
local RotationTOCLower = 110105
local RotationTOCUpper = 110105
local RotationClassName = "WARLOCK"
local RotationSpecializationID = 2

local SpellList = {
    ShadowBolt = 686,
    SummonImp = 688,
    SummonVoidwalker = 697,
    SummonSuccubus = 712,
    SummonFelguard = 30146,
    DemonArmor = 687,
    Immolate = 348,
    Corruption = 172,
    DrainLife = 234153,
    HealthFunnel = 755,
    SoulBurn = 385899,
    PowerSiphon=264130,
    SummonDemonicTyrant=265187,
    GrimoireFelGuard=111898,
    SummonVilefiend=264119,
    callDreadstalkers=104316,
    HandOfGuldan=105174,
    DemonicStrength=267171,
    DemonBolt = 264178,
    SummonCharhound = 455476,
}

local AuraList = {
    DemonicCore = 264173,
    DemonicCalling = 205146,
    Doom = 460551,
    SoulBurn = 387626,
}

local TalentList = {
    GrimoireFelGuard      = 111898,
    SummonVilefiend       = 264119,
    FelInvocation         = 428351,
    TheHoundmastersGambit = 455572,
}

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

-----------------------------------------------------
--- Create Toggles
--- Creates toggle buttons that will appear in the UI
--- When the rotation is active
------------------------------------------------------
local function CreateToggles()
    --No toggles for this basic rotation
end

-----------------------------------------------------
--- Create options
--- Creates options that will appear in the configuration
--- UI when the rotation is selected
------------------------------------------------------
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
local Mana
local SoulShards
---@type Unit?
local pet = player:Pet()

local function boolNumeric(value)
    if value then
        return 1
    else
        return 0
    end
end

local function Opener()
    --grimoire_felguard,if=soul_shard>=5-talent.fel_invocation
    if SoulShards>=(5 - boolNumeric(player:HasTalent(TalentList.FelInvocation))) then
        log:Log("Opener: Summoning Felguard")
        if cast.able.GrimoireFelGuard() then
            log:Log("Opener: Casting Felguard")
            return cast.GrimoireFelGuard()
        end
    end
    --summon_vilefiend,if=soul_shard=5
    if SoulShards==5 then
        log:Log("Opener: Summoning Vilefiend")
        if cast.able.SummonVilefiend() then
            log:Log("Opener: Casting Vilefiend")
            return cast.SummonVilefiend()
        end
    end
    --shadow_bolt,if=soul_shard<5&cooldown.call_dreadstalkers.up
    if SoulShards<5 and cast.cdRemains.callDreadstalkers() > 0 then
        log:Log("Opener: Casting Shadow Bolt")
        if cast.able.ShadowBolt() then
            log:Log("Opener: Casting Shadow Bolt")
            return cast.ShadowBolt()
        end
    end

    --call_dreadstalkers,if=soul_shard=5
    if SoulShards==5 then
        log:Log("Opener: Calling Dreadstalkers")
        if cast.able.callDreadstalkers() then
            log:Log("Opener: Calling Dreadstalkers")
            cast.callDreadstalkers()
            player.NeedsOpener = false
            return
        end
    end
end

local function Tyrant()

end

local function Pulse()

    target = player:TargetUnit()
    
    if player:IsBusy() or player:IsMounted() then return end
     
    if player.InCombat and not player:ValidTarget("target")  then
        player:TargetBest()
    end

    if player.InCombat and target then  
        player:EnsureFacing(target)
    end

      

    

    --#region Vars
    local var = {}
    var.base_first_tyrant_time = 12
    var.first_tyrant_time = var.base_first_tyrant_time
    
    --variable,name=first_tyrant_time,op=add,value=action.grimoire_felguard.execute_time,if=talent.grimoire_felguard.enabled
    if  player:HasTalent(TalentList.GrimoireFelGuard) then
       var.first_tyrant_time = var.first_tyrant_time + cast.executionTime.GrimoireFelGuard()
    end

    --variable,name=first_tyrant_time,op=add,value=action.summon_vilefiend.execute_time,if=talent.summon_vilefiend.enabled
    if player:HasTalent(TalentList.SummonVilefiend) then
       var.first_tyrant_time = var.first_tyrant_time + cast.executionTime.SummonCharhound()
    end

    --variable,name=first_tyrant_time,op=add,value=gcd.max,if=talent.grimoire_felguard.enabled|talent.summon_vilefiend.enabled
    if player:HasTalent(TalentList.GrimoireFelGuard) or player:HasTalent(TalentList.SummonVilefiend) then
       var.first_tyrant_time = var.first_tyrant_time + cast.gcdMax()
    end

    --variable,name=first_tyrant_time,op=sub,value=action.summon_demonic_tyrant.execute_time+action.shadow_bolt.execute_time
    var.first_tyrant_time = var.first_tyrant_time - (cast.executionTime.SummonDemonicTyrant() + cast.executionTime.ShadowBolt())

    --variable,name=first_tyrant_time,op=min,value=10
    if var.first_tyrant_time < 10 then
        var.first_tyrant_time = 10
    end

    --Check if dreadstalkers are active
    var.dreadstalkers_active = function() 
        return br.ObjectManager:SummonedCount("Dreadstalker") > 0
    end

    --Checks if vilefiend or charhound are active which SC just consideres vilefiend in calculations
    var.vilefiend_active = function() 
        return 
        (br.ObjectManager:SummonedCount("Vilefiend") > 0 or 
         br.ObjectManager:SummonedCount("Charhound") > 0)
    end
    var.vilefiend_remains = function() 
        for k,v in pairs(br.ObjectManager.Units) do
            if v.IsCreatedByPlayer and (string.lower(v.name):find("vilefiend") ~= nil or string.lower(v.name):find("charhound") ~= nil) then
                local remains = (GetTime() - v.Created) - 15
                return remains
            end
            if v.IsCreatedByPlayer and string.lower(v.name):find("charhound") ~= nil then
                local remains = (GetTime() - v.Created) - 15
                return remains
            end
        end
        return 0
    end

    var.felguard_active = function() 
        return br.ObjectManager:SummonedCount("Felguard") > 0
    end
    var.felguard_remains = function() 
        for k,v in pairs(br.ObjectManager.Units) do
            if v.IsCreatedByPlayer and string.lower(v.name):find("felguard") ~= nil then
                local remains = (GetTime() - v.Created) - 17
                return remains
            end
        end
        return 0
    end

    var.demonic_tyrant_active = function() 
        return br.ObjectManager:SummonedCount("Demonic Tyrant") > 0
    end
    var.demonic_tyrant_remains = function() 
        for k,v in pairs(br.ObjectManager.Units) do
            if v.IsCreatedByPlayer and string.lower(v.name):find("demonic tyrant") ~= nil then
                local remains = (GetTime() - v.Created) - 15
                return remains
            end
        end
        return 0
    end

    --returns # of active wild imps
    var.wild_imps_count = function() 
        return br.ObjectManager:SummonedCount("Wild Imp")
    end
    --#endregion




    SoulShards = player:AlternatePower(Enum.PowerType.SoulShards)
    pet = player:Pet()


   
    --TODO Handle out of Combat Logic (stones, etc.)
    if pet == nil or not pet:IsAlive() then
        if cast.able.SummonFelguard() and player.LastCastSpell ~= SpellList.SummonFelguard then
            return cast.SummonFelguard()
        end
    
    end

    

    if player:ValidTarget("target") and not player:IsMounted() then
        br.PetAttack()
        


        if pet ~= nil and pet:HealthPercent() <= 50 then
            log:Log("Pet Low Health - Using Health Funnel: " .. tostring(pet:HealthPercent()) .. "%")
            if not buffs.up.SoulBurn() then
                if cast.able.SoulBurn() then
                    return cast.SoulBurn()
                end
            else
                if cast.able.HealthFunnel() then
                    return cast.HealthFunnel()
                end
            end
        end

        if player:HealthPercent() <= 60 then
            if not buffs.up.SoulBurn() then
                if cast.able.SoulBurn() then
                    return cast.SoulBurn("player")
                else
                    return cast.DrainLife("target")
                end
            else
                if cast.able.DrainLife() then
                    return cast.DrainLife("target")
                end
            end
        end


        --TODO Handle Opener Logic
        -- if player.NeedsOpener then
        --     Opener()
        --     return true
        -- end

        --TODO Handle End of Fight Logic


        ---------------------------------------------------
        --- Primary Action Set
        --- -----------------------------------------------

        --hand_of_guldan,if=soul_shard>=3&cooldown.summon_demonic_tyrant.remains_expected<10&pet.dreadstalker.active
        if SoulShards>=3 and cast.cdRemains.SummonDemonicTyrant()<10 and var.dreadstalkers_active() then
            if cast.able.HandOfGuldan() then
                return cast.HandOfGuldan()
            end
        end

        --summon_demonic_tyrant,
            --if=(variable.imp_despawn&pet.vilefiend.active&pet.dreadstalker.active&(variable.imp_despawn<time+gcd.max+cast_time|buff.wild_imps.stack>=9-2*prev_gcd.1.hand_of_guldan))|(buff.grimoire_felguard.remains>cast_time&buff.grimoire_felguard.remains<action.hand_of_guldan.cast_time+cast_time+gcd.max)|(buff.dreadstalkers.remains>cast_time&((buff.dreadstalkers.remains<action.hand_of_guldan.cast_time+cast_time+gcd.max)|(variable.hog_after_ds&(time>10|buff.wild_imps.stack>=9-2*prev_gcd.1.hand_of_guldan))))
        if  (var.vilefiend_active() and var.dreadstalkers_active() and
            (var.wild_imps_count()<9 - 2 * SoulShards or
             var.wild_imps_count()<9 - 2 * SoulShards))
            or (var.felguard_active() and
                var.felguard_remains()<cast.executionTime.HandOfGuldan() + cast.executionTime.SummonDemonicTyrant() + cast.gcdMax())
            or (var.dreadstalkers_active() and
                (var.wild_imps_count()<9 - 2 * SoulShards)) then
            if cast.able.SummonDemonicTyrant() then
                return cast.SummonDemonicTyrant()
            end
        end


        --grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<=15&cooldown.call_dreadstalkers.remains<10
        if cast.cdRemains.SummonDemonicTyrant()<=15 and cast.cdRemains.callDreadstalkers()<10 then
            if cast.able.GrimoireFelGuard() then
                return cast.GrimoireFelGuard()
            end
        end

        --summon_vilefiend,
            --if=cooldown.summon_demonic_tyrant.remains>=25+cast_time
            --&(!pet.vilefiend.active&talent.the_houndmasters_gambit|!talent.the_houndmasters_gambit)
            --|cooldown.summon_demonic_tyrant.remains<=13
            --&cooldown.call_dreadstalkers.remains<10
        if (cast.cdRemains.SummonDemonicTyrant()>=25 + cast.executionTime.SummonCharhound() and
            (not var.vilefiend_active() and player:HasTalent(TalentList.TheHoundmastersGambit) or
             not player:HasTalent(TalentList.TheHoundmastersGambit))
            or (cast.cdRemains.SummonDemonicTyrant()<=13 and
                cast.cdRemains.callDreadstalkers()<10)) then
            ---@type SpellInfo
            local spellInfo = C_Spell.GetSpellInfo("Summon Charhound")
            if cast.able.SummonCharhound() and SoulShards>1 then
                return cast.SummonCharhound()
            end
        end

        --call_dreadstalkers,if=cooldown.summon_demonic_tyrant.remains>=10|cooldown.summon_demonic_tyrant.remains<=10
        if cast.cdRemains.SummonDemonicTyrant()>=10 or cast.cdRemains.SummonDemonicTyrant()<=10 then
            if cast.able.callDreadstalkers() then
                return cast.callDreadstalkers()
            end
        end

        --call_dreadstalkers,if=buff.grimoire_felguard.up&buff.grimoire_felguard.remains<12+gcd.max+cast_time
        if  var.felguard_active() and var.felguard_remains()<12 + cast.gcdMax() + cast.executionTime.callDreadstalkers() then
            if cast.able.callDreadstalkers() then
                return cast.callDreadstalkers()
            end
        end

        --	call_dreadstalkers,if=buff.vilefiend.up&buff.vilefiend.remains<12+gcd.max+cast_time
        if  var.vilefiend_active() and var.vilefiend_remains()<12 + cast.gcdMax() + cast.executionTime.callDreadstalkers() then
            if cast.able.callDreadstalkers() then
                return cast.callDreadstalkers()
            end
        end

        --call_dreadstalkers,if=cooldown.summon_demonic_tyrant.remains>cooldown+gcd.max+action.summon_demonic_tyrant.cast_time
        if  cast.cdRemains.SummonDemonicTyrant()>cast.cdRemains.callDreadstalkers()+cast.gcdMax()+cast.executionTime.SummonDemonicTyrant() then
            if cast.able.callDreadstalkers() then
                return cast.callDreadstalkers()
            end
        end

        --call_dreadstalkers,if=(!talent.grimoire_felguard|buff.grimoire_felguard.down&cooldown.grimoire_felguard.remains>cooldown-gcd.max-cast_time-action.summon_demonic_tyrant.cast_time)&(!talent.summon_vilefiend|buff.vilefiend.down>cooldown-gcd.max-cast_time-action.summon_demonic_tyrant.cast_time)
        if  (not player:HasTalent(TalentList.GrimoireFelGuard) or
             (not var.felguard_active() and
              cast.cdRemains.GrimoireFelGuard()>cast.cdRemains.callDreadstalkers()-cast.gcdMax()-cast.executionTime.callDreadstalkers()-cast.executionTime.SummonDemonicTyrant()))
             and
             (not player:HasTalent(TalentList.SummonVilefiend) or
              (not var.vilefiend_active() and
               cast.cdRemains.SummonCharhound()>cast.cdRemains.callDreadstalkers()-cast.gcdMax()-cast.executionTime.callDreadstalkers()-cast.executionTime.SummonDemonicTyrant())) then
            if cast.able.callDreadstalkers() then
                return cast.callDreadstalkers()
            end
        end

        --demonic_strength,if=pet.demonic_tyrant.active
        if var.demonic_tyrant_active() then
            if cast.able.DemonicStrength() and player.LastCastSpell ~= SpellList.DemonicStrength then
                return cast.DemonicStrength()
            end
        end

        --	power_siphon,if=!buff.demonic_core.up
        if not buffs.up.DemonicCore() then
            if cast.able.PowerSiphon() then
                return cast.PowerSiphon()
            end
        end

        --	hand_of_guldan,if=soul_shard>=3
        if SoulShards>=3 then
            if cast.able.HandOfGuldan() then
                return cast.HandOfGuldan()
            end
        end

        --demonbolt,if=soul_shard<4&buff.demonic_core.react
        if SoulShards<4 and buffs.up.DemonicCore() then
            if cast.able.DemonBolt() then
                return cast.DemonBolt()
            end
        end

        if cast.able.ShadowBolt() then
            return cast.ShadowBolt()
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
end 
