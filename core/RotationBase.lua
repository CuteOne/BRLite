---@type _,br,_
local _,br,_=...

---@type br.Logging, br.Settings
local Log,Settings = br.Logging,br.Settings

---@type AbstractFramework
local AF = _G.AbstractFramework

---@class br.RotationBase
---@field Name string @The name of the rotation
---@field Description string @A description of the rotation
---@field ShortName string @A short name for the rotation
---@field Version number @The version of the rotation
---@field TOCLower number @The minimum TOC version supported by the rotation
---@field TOCUpper number @The maximum TOC version supported by the rotation
---@field ClassName string @The class name the rotation is for
---@field SpecializationID number @The specialization ID the rotation is for
---@field CheckRequirements fun(self: br.RotationBase): boolean @Checks if the rotation's
---@field Initialize fun(self: br.RotationBase): nil @Initializes the rotation
---@field CreateOptions fun(self: br.RotationBase): nil @Creates the rotation's options
---@field CreateToggles fun(self: br.RotationBase): nil @Creates the rotation's toggles
---@field Pulse fun(self: br.RotationBase): nil @The main pulse function of the rotation
---@field Register fun(self: br.RotationBase, ShortName: string, Name: string, Description: string, Version: number, TOCLower: number, TOCUpper: number, ClassName: string, SpecializationID: number, SpellList: table): br.RotationBase|nil @Registers a new rotation
local RotationBase = {}
RotationBase.__index = RotationBase
br.RotationBase = RotationBase

RotationBase.Name = "Base Rotation"
RotationBase.Description = "Base Rotation Description"
RotationBase.ShortName = "Base"
RotationBase.Version = 0.1
RotationBase.TOCLower = 0
RotationBase.TOCUpper = 99999
RotationBase.ClassName = "ANY"
RotationBase.SpecializationID = 0
RotationBase.SpellList = {}
RotationBase.ToggleOptions={}


function RotationBaseUnhandledCallback(name)
    return false
end

RotationBase.CheckRequirements = function() return true end
RotationBase.funcInitialize = function () RotationBaseUnhandledCallback("Initialize") end 
RotationBase.CreateOptions = RotationBaseUnhandledCallback("CreateOptions")
RotationBase.CreateToggles = RotationBaseUnhandledCallback("CreateToggles")
RotationBase.Pulse = RotationBaseUnhandledCallback("Pulse")


function RotationBase:Initialize()
    self.__index = self
    local f = CreateFrame("Frame","test",UIParent)
    AF.SetSize(f,10,10)
    Mixin(f,RotationBase)
end




function RotationBase:Register(
    ShortName,
    Name,
    Description,
    Version,
    TOCLower,
    TOCUpper,
    ClassName,
    SpecializationID, SpellList)

    --Check Client version compatibility
    if br.clientTOC < TOCLower or br.clientTOC > TOCUpper then
        Log:Log("Rotation " .. ShortName .. " not compatible with client TOC version " .. tostring(br.clientTOC) .. " " .. TOCLower .. "-" .. TOCUpper)
        return nil
    end

    --check Class compatibility
    if ClassName ~= "ANY" and ClassName ~= br.ActivePlayer.ClassName then
        Log:Log("Rotation " .. ShortName .. " not compatible with player class " .. tostring(br.ActivePlayer.ClassName) .. ":" .. ClassName)
        return nil
    end

    --Set player's spell book
    br.ActivePlayer:SetupSpells(SpellList)


    ---@type br.RotationBase
    local obj = setmetatable({}, RotationBase)
    obj.ShortName = ShortName or obj.ShortName
    obj.Name = Name or obj.Name
    obj.Description = Description or obj.Description
    obj.Version = Version or obj.Version
    obj.TOCLower = TOCLower or obj.TOCLower
    obj.TOCUpper = TOCUpper or obj.TOCUpper
    obj.ClassName = ClassName or obj.ClassName
    obj.SpecializationID = SpecializationID or obj.SpecializationID
    obj.SpellList = SpellList or {}
    if not br.Rotations[ShortName] then
        br.Rotations[ShortName] = obj
        Log:Log("Registered rotation: [" .. ShortName .. "]")
    else
        Log:Log("Rotation with ShortName " .. ShortName .. " is already registered. Overwriting.")
        br.Rotations[ShortName] = obj
    end
    return obj;    
    
end