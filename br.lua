---@type AbstractFramework
local AF = _G.AbstractFramework

---@class br
---@field name string @The name of the application
---@field unlocker string @The textual abbreviation of the unlocker
---@field pulse boolean @Toggles the rotation pulse
---@field clientTOC string @The client's TOC version
---@field clientVersion string @The client's mainstream version
---@field IsRetail boolean @Is the game Retail
---@field Objects table @Active list of game objects
---@field ActivePlayer Player @GUID of activePlayer
---@field Intialization table @Initialization functions and data
---@field Logging table @Logging functions and data
---@field ModuleLoader table @ModuleLoader functions and data
---@field Modules table @Loaded modules
---@field Framework table @Loaded frameworks
---@field UI.Elements.Theme br.UI.Elements.Theme @Theme functions and data
---@field Settings table @Settings functions and data
---@field Helpers table @Helper functions and data
---@field ObjectManager br.ObjectManager @ObjectManager functions and data
---@field CombatManager br.CombatManager @CombatManager functions and data
---@field Geometry br.Geometry @Geometry functions and data
---@field Fishing br.Fishing @Fishing functions and data
---@field RotationBase br.RotationBase @RotationBase functions and data
---@field Rotations table<string, br.RotationBase> @Loaded rotations
---@field UI.ObjectManager br.ObjectManager @ObjectManager functions and data
---@field RequireFile fun(path: string, ...: any): any @Requires a file at the given path with optional parameters
---@field ObjectType fun(type: number|string): number? @Returns the object type string for the given type number
---@field AttackTarget fun(): nil @Attacks the current target
---@field GetObjects fun(type: number|string): table @Returns the object manager items for the given type
---@field ObjectLocation fun(objectID: number|string): number, number, number @Returns the X, Y, Z location of the given object ID
---@field ObjectOrUnitName fun(objectID: number|string): string @Returns the name of the given object ID
---@field ObjectExists fun(objectID: number|string): boolean @Returns whether the given object ID exists
---@field DistanceBetweenObjects fun(objectID1: number|string, objectID2: number|string): number @Returns the distance between two object IDs
---@field CastSpell fun(spell: string|number, target: string|number): boolean @Casts the given spell on the given target
---@field ListFiles fun(path: string):  string[] @Returns a table of files at the given path
---@field RotationCount number @The count of available rotations
---@field Debuffs br.Debuffs @Debuff functions and data
local br = {}


br.Version = 0.1
br.__index = br
br.Intialization = {}
br.Logging = {}
br.Modules = {}
br.ModuleLoader = {}
br.Framework = {}
br.LuaHelpers = {}
br.ObjectManager = {}
br.CombatManager = {}
br.RotationBase = {}
br.Rotations = {}
br.RotationCount = 0
br.ActiveRotation={}
br.Geometry = {}
br.Fishing = nil
br.Looting = nil
br.Skinning = nil
br.Gathering = nil
br.PullMode = false


-- AF Windows
br.WINDOW_TOGGLES = {}
br.TOOLBAR = {}

br.Settings = nil
br.UI = {}
br.UI.Elements = {}
br.UI.Elements.MinimapIcon = {}
br.UI.Elements.Theme = {}
br.UI.Elements.Button = {}
br.UI.Elements.Window = {}
br.UI.Elements.Dropdown = {}



---------------------------------------------------------------------------------------------
-- Overall Application fields
---------------------------------------------------------------------------------------------
br.name  = "BRLite"
br.unlocker = "UNKNOWN"
br.pulse = false
br.DoLooting = true
br.DoSkinning = true
br.DoGathering = false
br.DoMovement = true
br.DoFacing = true
br.PullMode = false
br.clientTOC = select(4, GetBuildInfo())
br.clientVersion = select(3, GetBuildInfo())


local function unhandledOverride(name,...)
    print("Unhandled call to br:" .. tostring(name) .. " with args: " .. tostring(...))
end

--Overridable in unlocker
br.RequireFile = function(path,...) unhandledOverride("RequireFile",path,...) end
br.GetObjects = function(type) unhandledOverride("ObjectManager",type) end
br.ObjectType = function(type) unhandledOverride("ObjectType",type) end
br.AttackTarget = function() unhandledOverride("AttackTarget") end

return br