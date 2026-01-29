---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock DK Blood Rotation"
local RotationShortName = "StockDKBloodRotation"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Blood Death Knights. Only valid until level 10."
local RotationTOCLower = 110207
local RotationTOCUpper = 110207
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

}

local TalentList = {

   
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
local runicPower = br.ActivePlayer:Power()
local runes = br.ActivePlayer:AlternatePower(Enum.PowerType.Runes)
local meleeRange = false




local function boolNumeric(value)
    if value then
        return 1
    else
        return 0
    end
end

local function Pulse()

   

    ---@type table
    local enemiesMeleeFacing = br.ObjectManager:EnemiesFacingMelee()
    --log:Log("Enemies in Melee Facing Heart Strike: " .. #enemiesMeleeFacing)

    -- Return if we're busy channelling/Casting/Crafting/Gathering/etc
    -- Hopefully this will keep us from breaking gathering if we are 
    -- attacked but it isn't strong enough to interrupt the process
    if player:IsBusy() or player:IsMounted() then return end

    --Check for a valid Target if not find one
    if player.InCombat and not Player:ValidTarget("target") then
        return Player:TargetBest()
        -- We need some sort of delay here to allow the target to register
        -- some sort of busy loop using GetTime()?
    end

    
    if player.InCombat and player:ValidTarget("target") then
        
        target = player:TargetUnit()
        meleeRange = cast.inRange.HeartStrike("target")

        --#region Defenses
        -- if player:HealthPercent() < 80 and cast.able.Consumption("player") and meleeRange then
        --     return cast.Consumption("player")
        -- end


            if player:HealthPercent() < 90 and 
                cast.able.Bonestorm("player") 
                and buffs.points.BoneShield(2) >= 10 then
                    return cast.Bonestorm("player")
            end
            if player:HealthPercent() < 76 and 
                cast.able.DeathCoil("player") 
                and runicPower >= 40 then
                    return cast.DeathCoil("player")
            end

        --#endregion Defenses

        if cast.able.DeathStrike("target") and (player:HealthPercent() < 90 or runicPower >= 100 ) then
            return cast.DeathStrike("target")
        end


        if cast.able.DeathsCaress() and meleeRange then
            return cast.DeathsCaress("target")
        end

        if not player:IsAuto() and meleeRange then
            return player:StartAutoAttack()
        end

        if cast.able.DancingRuneWeapon() and meleeRange then
            return cast.DancingRuneWeapon("player")
        end

        if not buffs.up.DeathAndDecay() and 
            cast.able.DeathAndDecay() and 
            not player:IsMoving() and
            meleeRange
            then
                return cast.atTargetGround.DeathAndDecay(player)
        end

        --VampiricBlood
        if not buffs.up.VampiricBlood() and cast.able.VampiricBlood() then
            return cast.VampiricBlood("player")
        end

        --Chains of Ice Debuff
        if not br.Debuffs.up.ChainsOfIce(target) and 
            cast.able.ChainsOfIce() and 
            meleeRange 
        then
            return cast.ChainsOfIce("target")
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