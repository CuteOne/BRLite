---@type _, br, Daemonic
local _, br, dmc = ...

---@class br
br = br or {}
---@type br.Logging
br.Logging = br.Logging or {}

br.RequireFile = function(path,...)
    local status,data = dmc.RequireFile(dmc.GetExeDirectory() .. path,_G,...)
    if not status then
        br.Logging:LogError("Error requiring file: " .. path .. " Error: " .. tostring(data))
        return nil
    end
    return data
end

br.GetObjects = function(type)
    local objects = {}
    local objectIndex = 1
    for i = 1, dmc.GetObjectCount(),1 do
        local guid = dmc.GetObjectWithIndex(i)
        if dmc.IsGuid(guid) then 
            if dmc.ObjectType(guid) == type then
                objects[objectIndex] = guid
                objectIndex = objectIndex + 1
            end
        end
     end
    return objects
end


br.CombatReach = dmc.UnitCombatReach
br.DistanceBetweenObjects = dmc.GetDistance3D
br.DistanceBetweenCoords = dmc.GetDistance3D
br.GetAngleBetweenPositions = dmc.GetAngles
br.GetPositionFromPosition = nil -- Not currently implemented in DMC, may require custom implementation
br.ObjectCreator = dmc.UnitCreatedBy
br.ObjectExists = dmc.ObjectExists
br.ObjectFacing = dmc.UnitFacing
br.ObjectId = dmc.ObjectID
br.ObjectInteract = dmc.Interact
br.ObjectOrUnitName = dmc.ObjectName
br.ObjectByIndex = dmc.GetObjectWithIndex
br.ObjectLootable = dmc.UnitIsLootable
br.ObjectLocation = dmc.GetUnitPosition
br.ObjectRotation = dmc.UnitRawFacing
br.ObjectSkinnable = dmc.UnitIsSkinnable
br.ObjectSummoner = dmc.UnitSummonedBy
br.ObjectType = dmc.ObjectType
br.ObjectYaw = dmc.UnitFacing
br.PlayerTarget = dmc.UnitTarget("player")
br.ScreenToWorld = dmc.ScreenToWorld
br.SetMouseOver = dmc.SetMouseOverObject
br.SetPlayerFacing = dmc.FaceDirection
br.SetFocus = dmc.SetTargetUnit
br.TraceLine = dmc.TraceLine
br.WorldToScreen = dmc.WorldToScreen
br.FileExists = dmc.FileExists
br.ReadFile = dmc.ReadFile
br.WriteFile = dmc.WriteFile
br.DeleteFile = dmc.DeleteFile
br.DirectoryExists = dmc.DirectoryExists
br.CreateDirectory = dmc.CreateDirectory
br.DeleteDirectory = dmc.DeleteDirectory
br.JSONEncode = dmc.JsonEncode
br.JSONDecode = dmc.JsonDecode
br.UnitTarget = dmc.UnitTarget
br.ObjectPointer = dmc.ObjectID
br.ClickPosition = dmc.ClickPosition
br.ClickToMove = dmc.MoveTo
br.ObjectAnimationFlag = dmc.UnitAnimationFlags
br.SendMovementHeartbeat = dmc.SendMovementHeartbeat
br.UnitTarget = dmc.UnitTarget
br.GetFocus = dmc.UnitTarget
br.LibDraw = dmc.Draw
br.ObjectField = dmc.ObjectField
br.ObjectFlags = dmc.UnitFlags
br.IsGuid = dmc.IsGuid
br.GetAngles = dmc.GetAngles


local function split_from_last(input_str, separator)
    local last_index = nil
    local start_pos = 1
    while true do
        local i = string.find(input_str, separator, start_pos, true)
        if i then 
            last_index = i
            start_pos = i + 1
        else
            break
        end
    end
    if not last_index then return input_str, nil end
    local part1 = string.sub(input_str, 1, last_index - 1)
    local part2 = string.sub(input_str, last_index + #separator)
    return part1, part2
end

local function split(str,delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)" 
    for capture in string.gmatch(str, pattern) do
        table.insert(result, capture)
    end
    return result
end

br.ListFiles = function(path)
    local pathpart,pattern = split_from_last(path,"/")
    if not pattern then pattern = "*" end
    print("List Files PathPart: " .. tostring(pathpart) .. " Pattern: " .. tostring(pattern))
    local files = dmc.GetDirectoryFiles(dmc.GetExeDirectory() ..pathpart,pattern)

    if not files or #files == 0 then
        return nil
    end
    return split(files,"|")
end

br.TargetUnit               =  function(...) return dmc.SecureCode("TargetUnit",...) end
br.AttackTarget             =  function() return dmc.SecureCode("AttackTarget") end
br.CancelShapeshiftForm     =  function() return dmc.SecureCode("CancelShapeshiftForm") end
br.CancelUnitBuff           =  function(...) return dmc.SecureCode("CancelUnitBuff",...) end
br.CastPetAction            =  function(...) return dmc.SecureCode("CastPetAction",...) end
br.CastShapeSiftForm        =  function(...) return dmc.SecureCode("CastShapeSiftForm",...) end
br.CastSpell                =  function(...) return dmc.SecureCode("CastSpell",...) end
br.CastSpellByID            =  function(...) return dmc.SecureCode("CastSpellByID",...) end
br.CastSpellByName          =  function(...) return dmc.SecureCode("CastSpellByName",...) end
br.ClearTarget              =  function() return dmc.SecureCode("ClearTarget") end
br.FocusUnit                =  function(...) return dmc.SecureCode("FocusUnit",...) end
br.ForceQuit                =  function() return dmc.SecureCode("ForceQuit") end
br.Logout                   =  function() return dmc.SecureCode("Logout") end
br.PetAssistMode            =  function() return dmc.SecureCode("PetAssistMode") end
br.PetAttack                =  function() return dmc.SecureCode("PetAttack") end
br.PetDefensiveAssistMode   =  function() return dmc.SecureCode("PetDefensiveAssistMode") end
br.PetDefensiveMode         =  function() return dmc.SecureCode("PetDefensiveMode") end
br.PetFollow                =  function() return dmc.SecureCode("PetFollow") end
br.PetPassiveMode           =  function() return dmc.SecureCode("PetPassiveMode") end
br.PetStopAttack            =  function() return dmc.SecureCode("PetStopAttack") end
br.PetWait                  =  function() return dmc.SecureCode("PetWait") end
br.RunMacroText             =  function(...) return dmc.SecureCode("RunMacroText",...) end
br.RunMacro                 =  function(...) return dmc.SecureCode("RunMacro",...) end
br.StartAttack              =  function(...) return dmc.SecureCode("StartAttack",...) end
br.SpellStopCasting         =  function() return dmc.SecureCode("SpellStopCasting") end
br.SpellStopTargeting       =  function() return dmc.SecureCode("SpellStopTargeting") end
br.SpellTargetUnit          =  function(...) return dmc.SecureCode("SpellTargetUnit",...) end
br.UseContainerItem         =  function(...) return dmc.SecureCode("UseContainerItem",...) end
br.UseItemByName            =  function(...) return dmc.SecureCode("UseItemByName",...) end
br.TargetNearestEnemy       =  function(...) return dmc.SecureCode("TargetNearestEnemy",...) end
br.ConfirmBindOnUse         = function() return dmc.SecureCode("ConfirmBindOnUse") end
br.FollowUnit               = function(...) return dmc.SecureCode("FollowUnit",...) end
br.ConfirmBindOnUse         = function() return dmc.SecureCode("ConfirmBindOnUse") end
br.Logout                   = function() return dmc.SecureCode("Logout") end


br.StandarApis = {
    "UnitHealth",
    "UnitHealthMax",
    "UnitPower",
    "UnitPowerMax",
    "UnitHealthPercent",
    "C_Spell.GetSpellCooldown",
    "C_UnitAuras.GetDebuffDataByIndex",
    "UnitDebuff",
    "C_UnitAuras.GetPlayerAuraBySpellID",
    "AuraUtil.FindAuraByName",
    "UnitIsDeadOrGhost",
    "UnitIsDead",
    "UnitCanAttack",
    "UnitIsEnemy",
    "UnitCastingInfo",
    "UnitChannelInfo",
    "C_Spell.GetSpellCharges",
    "C_Spell.GetSpellCastCount"
}

br.apis = setmetatable(
     {},
        {
            __index = function(self, func)
            return dmc[func] or _G[func]
            end
        }
)

for i = 1, #br.StandarApis do
    local funcname = br.StandarApis[i]
    local func = _G[funcname]
    br.apis[funcname] = function(...) return dmc.SecureCode(func,...) end
end

br.unwrap = function(...)
    if issecretvalue(...) then
        return dmc.secretunwrap(...)
    else
        return ...
    end
end

br.api.GetUnitGUID = function(unitId)
    return unitId
end

setfenv(1, br.apis)


br.Logging:Log("DMC Unlocker Loaded")