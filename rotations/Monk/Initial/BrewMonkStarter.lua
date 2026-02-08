---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Brewmaster Monk Starter 12"
local RotationShortName = "BrewMonkStarter"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Brewmaster Monks. Only valid until level 10."
local RotationTOCLower = 120000
local RotationTOCUpper = 120000
local RotationClassName = "MONK"
local RotationSpecializationID = 5  --Starter Spec ID



print("br.name: " .. br.name)
-----------------------------------------------------
-- Not required, but will be run if needed to check
-- if character meets rotation requirements
-- Like certain specialization traits, gear, etc.
-----------------------------------------------------
local function CheckRequirements()
    return br.ActivePlayer.Specialization == 5
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
    RisingSunKick = 107428,
    SpinningCraneKick = 322729,
    ExpelHarm = 322101,
}



--------------------------------------------------------
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




--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()
    target = br.ActivePlayer:TargetUnit()
    energy = br.ActivePlayer:Power()

    -- Defensive Stuff
    if player:HealthPercent() < 50 then
        if cast.able.ExpelHarm() then
            return cast.ExpelHarm()
        end
    end

    if player:IsBusy() or player:IsMounted() or UnitIsDeadOrGhost("player") then return end

    if player.InCombat and not player:ValidTarget("target") then
        player:TargetClosestInMeleeRange()
    end

     if player:IsBusy() or 
        not player:ValidTarget("target") or
        not UnitCanAttack("player", "target") then return
    end

     -- pull the active player's target unit locally for ease of use
    -- if it isn't valid for some reason return
    target = br.ActivePlayer:TargetUnit()
    if not target then return end

     if UnitCanAttack("player", "target") then
        player:EnsureFacing(target)
        player:CloseToMelee(target)
    end

    if not player:IsAuto() then player:StartAutoAttack() return end
    -- if cast.able.TigerPalm() then
    --     return cast.TigerPalm()
    -- end
    if cast.able.BlackoutKick() then
        return cast.BlackoutKick()
    end


    

end

--------------------------------------------------------
--- DO NOT MODIFY BELOW THIS LINE
--- Registers the rotation with the framework
--------------------------------------------------------
local function Test()
    print("Test Function")
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
end 

print("Rotation " .. RotationName .. " version " .. RotationVersion .. " loaded.")
