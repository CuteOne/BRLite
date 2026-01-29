---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Brewmaster Monk Starter"
local RotationShortName = "BrewMonkStarter"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Brewmaster Monks. Only valid until level 10."
local RotationTOCLower = 110105
local RotationTOCUpper = 110105
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
    ["Tiger Palm"] = 100780,
    ["Blackout Kick"] = 100784,
    ["Spinning Crane Kick"] = 101546,
    ["Leg Sweep"] = 119381,
    ["Vivify"] = 116670,
    ["Crackling Jade Lightning"] = 117952,
    ["Expel Harm"] = 322101,
    ["Provoke"] = 115546,
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


local player = br.ActivePlayer




--------------------------------------------------------
--- Pulse
--- The main pulse function that will be called
--- each pulse of the rotation
--- This is where the main rotation logic will go
--------------------------------------------------------
local function Pulse()
    
    -- Defensive Stuff
    if player:HealthPercent() < 50 then
        if player:Castable("Expel Harm") then
            return player:Cast("Expel Harm")
        end
    end

    if player:ValidTarget("target") and not player:IsMounted() then

        --range Check, don't count on actual distance, use range by spell
        if player:SpellInRange("Tiger Palm","target") then

            if not player:IsAuto()then
                print("Starting Auto Attack")
                return player:StartAutoAttack()
            end
            if player:Castable("Tiger Palm") then
                return player:Cast("Tiger Palm","target")
            end
            if player:Castable("Blackout Kick") then
                return player:Cast("Blackout Kick","target")
            end

        end
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
