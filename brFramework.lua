---@type _,br,NilName
local  _,br,nn = ...

---@type br.Logging, br.Settings
local Log,Settings = br.Logging,br.Settings

---@class br.Framework
---@field Startup function #Scaffold the framework int br class
local Framework = br.Framework 

function br.Framework:RotationPulse()
    if br.pulse and br.ActiveRotation then
        br.ActiveRotation:Pulse()
    end
    local callbackTime = math.random(150,450)/1000
    C_Timer.After(callbackTime, function() br.Framework:RotationPulse() end)
end

function br.Framework:Startup()

    ---@type AbstractFramework
    local AF = _G.AbstractFramework
    if not AF then
        Log:LogError("ERROR: AbstractFramework not found. BRLite cannot start.")
        return
    end
    
    Settings:Initialize("/scripts/settings","brlite_settings.json")  
    br.UI.Elements.MinimapIcon:Initialize()
    br:InitializeToolbar()
  
    --Set ObjectManager to active and start its timer
    br.ObjectManager:Update()
    br.ObjectManager.Active = true
    br.ObjectManager:Timer() 

    --Combat Manager Initialization
    br.CombatManager:Initialize()

    --Load available Rotations
    br.Rotations = {}
     local specName = "AAAA"
    if br.ActivePlayer.Specialization ~= 5 then
        specName = br.ActivePlayer.SpecializationName
        specName = string.gsub(specName," ","")
    else        
        specName = "Initial"
    end
    
    local rotationPath = "/scripts/brlite/rotations/" .. br.ActivePlayer.ClassName .. "/" .. specName .. "/"
    local rotFiles = br.ListFiles(rotationPath .. "*.lua")
    if not rotFiles or #rotFiles == 0 then
        Log:LogError("No rotation files found in path: " .. rotationPath)
        Log:LogError("Please add a rotation for your client version, class, and specialty")
        Log:LogError("Then Reload the UI.")
        br.ActiveRotation = nil
        br.pulse = false
        return
    end
    for i=1,#rotFiles do
           br.RequireFile(rotationPath .. rotFiles[i],br)
    end
    -- Count non sequenced # of pairs in table and store
    local rotCount = 0
    for k,v in pairs(br.Rotations) do
        rotCount = rotCount + 1
    end
    br.RotationCount = rotCount

    --Set MinimapIcon handler
    br.UI.Elements.MinimapIcon:SetLeftClickHandler(
        function() 
            br:ShowSettingsWindow()
        end)
    br.UI.Elements.MinimapIcon:SetRightClickHandler(
        function() 
            br:ToggleToolbar()
        end)
        br.UI.Elements.MinimapIcon:SetShiftLeftClickHandler(
        function() 
           br:ShowMover()
        end)

    local savedSettings = br.Settings:GetSetting("WINDOW_SETTINGS")
    if savedSettings and savedSettings.shown then
        br:ShowSettingsWindow()
    end

    local rotationSettings = Settings:GetSetting("ACTIVE_ROTATION")
    if not rotationSettings then
        if not br.Rotations or br.RotationCount == 0 then
            Log:LogError("ERROR: Available Rotation Count: " .. br.RotationCount )
            Log:LogError("No rotations available to set as active.")
            Log:LogError("Please add a rotation for your client version, class, and specialty")
            Log:LogError("Then Reload the UI.")
            br.ActiveRotation = nil
            br.pulse = false
            return
        else
            Log:Log("No saved active rotation; defaulting to first available rotation.")
            _,br.ActiveRotation = next(br.Rotations)
            Log:Log("1. Setting Active Rotation to: " .. tostring(br.ActiveRotation.ShortName))
            br.pulse = true
        end
    else
        local rot = br.Rotations[rotationSettings.shortName]
        if rot then
            br.ActiveRotation = rot
            Log:Log("2. Setting Active Rotation to: " .. tostring(br.ActiveRotation.ShortName))
            br.pulse = true
        else
            Log:Log("Saved active rotation " .. rotationSettings.shortName .. " not found; defaulting to first available rotation.")
            _,br.ActiveRotation = next(br.Rotations)
            Log:Log("2. Setting Active Rotation to: " .. tostring(br.ActiveRotation.ShortName))
            br.pulse = true
        end
    end

    --Attempt to Initialize Active Rotation
    if br.ActiveRotation then
        br.ActiveRotation:Initialize()
        br.Framework:RotationPulse() 
    else
        Log:LogError("No  Active Rotation to initialize.")
        br.pulse = false
        return
    end

    Log:Log("BR Framework Startup Complete")
end





