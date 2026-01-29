---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Paladin Protection"
local RotationShortName = "StockProtection"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Protection Paladins. Only valid until level 10."
local RotationTOCLower = 110105
local RotationTOCUpper = 110105
local RotationClassName = "PALADIN"
local RotationSpecializationID = 2

local SpellList = {
    AvengingWrath = 31884,
    BlessedHammer = 204019,
    Consecration = 26573,
    DevotionAura = 465,
    EyeOfTyr = 387174,
    HammerOfWrath = 24275,
    Judgement = 275779,
    Rebuke = 96231,
    ShieldOfTheRighteous = 53600,
    DivineToll = 375576,
    AvengersShield = 31935,
    WordOfGlory = 85673,

}

local AuraList = {
    Consecration = 188370,
    DevotionAura = 465,
    Judgement = 197277,
    ShieldOfTheRighteous = 132403,
    ShiningLight = 182104,

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

local holyPower = br.ActivePlayer:AlternatePower(Enum.PowerType.HolyPower)



local function boolNumeric(value)
    if value then
        return 1
    else
        return 0
    end
end

local function Pulse()

    holyPower = br.ActivePlayer:AlternatePower(Enum.PowerType.HolyPower)
    local var = {}

    if not player:IsBusy() then
        if player:HealthPercent() < 70 and player.buffs.up.ShiningLight() and cast.able.WordOfGlory() then
            return cast.WordOfGlory("player")
        end
    end
 

    if player:IsBusy() or 
        not player:ValidTarget("target") or
        not UnitCanAttack("player","target")  then return end


    --Refresh target variable
    target = br.ActivePlayer:TargetUnit()
    if not target then
        return
    end

    if not buffs.up.Consecration() and not player:IsMoving() and cast.able.Consecration() then
        return cast.Consecration("player")
    end


    if br.Debuffs.stacks.Judgement(target) < 3 
    and cast.able.Judgement() then
        return cast.Judgement(target)
    end

    if not buffs.up.ShieldOfTheRighteous() and cast.able.ShieldOfTheRighteous() then
        return cast.ShieldOfTheRighteous("player")
    end

    if cast.able.HammerOfWrath() then
        return cast.HammerOfWrath(target)
    end

    if cast.able.DivineToll() then
        return cast.DivineToll("player")
    end

    if cast.able.AvengersShield() then
        return cast.AvengersShield(target)
    end

    if cast.able.BlessedHammer() then
        return cast.BlessedHammer()
    end



    --Cast Devotion Aura if not active
    if not buffs.up.DevotionAura() then
        if cast.able.DevotionAura() then
            return cast.DevotionAura()
        end
    end

    if cast.able.AvengingWrath() then
        return cast.AvengingWrath()
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