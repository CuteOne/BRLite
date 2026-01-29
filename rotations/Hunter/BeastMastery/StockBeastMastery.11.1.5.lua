---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock Hunter BM 11.1.5"
local RotationShortName = "StockHunterBM110105"
local RotationVersion = 1.0
local RotationDescription = "Standard HunterBM rotation for 11.1.5 TWW "
local RotationTOCLower = 110105
local RotationTOCUpper = 110105
local RotationClassName = "HUNTER"
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
    ArcaneShot          = 185358,
    SteadyShot         = 56641,
    FreezingTrap        = 187650,
    HuntersMark        = 257284,
    KillShot           = 53351,
    WingClip           = 195645,
    KillCommand        = 34026,
    BarbedShot        = 217200,
}

local AuraList = {
    HuntersMark        = 257284,

   
}

local TalentList = {

}

-----------------------------------------------------
--- Toggle Options  
--- Defines the toggle options that will appear
--- in the rotation UI when this rotation is selected
--- ----------------------------------------------------
local ToggleOptions = {}
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
local focus = br.ActivePlayer:Power()




local function Defensive()
   
end

local function cooldowns()

end

local function Opener()

end

local function fallback()

end



--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()
    target = br.ActivePlayer:TargetUnit()
    focus = br.ActivePlayer:Power()
   

    if player:IsBusy() or player:IsMounted() or UnitIsDeadOrGhost("player") then return end

    
    if Defensive() then return end



    if (player.InCombat or UnitAffectingCombat("pet")) and not player:ValidTarget("target") then
        print("No valid target, selecting best target")
        player:TargetBest()
    end

     --if we are too busy or still don't have a good attackable target then return
    if player:IsBusy() or 
        not player:ValidTarget("target") or
        not UnitCanAttack("player", "target") then return
    end

    target = br.ActivePlayer:TargetUnit()
    if not target then return end


    if UnitCanAttack("player", "target") then
        if not player.InCombat then
            br.PetAttack()
        end
        player:EnsureFacing(target)
    end

    if not player:IsAutoShot() then
        return player:StartAutoShot()
    end

    if cast.able.HuntersMark() and not br.Debuffs.up.HuntersMark(target) then
        return cast.HuntersMark()
    end

    if cast.able.BarbedShot() and br.Debuffs.up.HuntersMark(target) and focus <= 80  then
        return cast.BarbedShot()
    end

    if cast.able.KillShot() and target:HealthPercent() <= 20 then
        return cast.KillShot()
    end


    if cast.able.ArcaneShot() then
        return cast.ArcaneShot()
    end

    if cast.able.KillCommand() then
        return cast.KillCommand()
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
    rotation.CreateOptions = CreateOptions  
    rotation.CreateToggles = CreateToggles
    rotation.Pulse = Pulse
    rotation.SpellList = SpellList or {}
    rotation.ToggleOptions = ToggleOptions or {}
    br.ActivePlayer:BuffSetup(AuraList)
    br.Debuffs:AuraSetup(AuraList)
end 