---@type _, br, NilName
local _, br, nn = ...

---@class br
br = br or {}

---@type br.Logging
br.Logging = br.Logging or {}

local function HardwareActionWrapper(func,...)
    nn.UpdateLastHardwareAction()
    return nn.Unlock(func,...)
end

br.RequireFile = function(path,...)
    return nn:Require(path,...)
end

br.GetObjects = function(type)
    return nn.ObjectManager(type)
end
br.CombatReach                  = nn.CombatReach
br.DistanceBetweenObjects       = nn.Distance
br.DistanceBetweenCoords        = nn.Distance
br.GetAnglesBetweenPositions    = nn.GetAnglesBetweenPositions
br.GetPositionFromPosition      = nn.GetPositionFromPosition
br.ObjectCreator                = nn.ObjectCreator
br.ObjectExists                 = nn.ObjectExists
br.ObjectFacing                 = nn.ObjectFacing
br.ObjectID                     = nn.ObjectID
br.ObjectInteract               = nn.ObjectInteract
br.ObjectOrUnitName             = nn.ObjectName
br.ObjectByIndex                = nn.ObjectByIndex
br.ObjectLootable               = nn.ObjectLootable
br.ObjectLocation               = nn.ObjectPosition
br.ObjectRotation               = nn.ObjectRotation
br.ObjectSkinnable              = nn.ObjectSkinnable
br.ObjectSummoner               = nn.ObjectSummoner
br.ObjectType                   = nn.ObjectType
br.ObjectYaw                    = nn.ObjectYaw
br.PlayerTarget                 = nn.PlayerTarget
br.ScreenToWorld                = nn.ScreenToWorld
br.SetMouseOver                 = nn.SetMouseover
br.SetPlayerFacing              = nn.SetPlayerFacing
br.SetFocus                     = nn.SetFocus
--br.TargetUnit                   = nn.TargetUnit
br.TraceLine                    = nn.TraceLine
br.WorldToScreen                = nn.WorldToScreen
br.FileExists                   = nn.FileExists
br.ReadFile                     = nn.ReadFile
br.WriteFile                    = nn.WriteFile
br.DeleteFile                   = nn.DeleteFile
br.DirectoryExists              = nn.DirectoryExists
br.CreateDirectory              = nn.CreateDirectory
br.DeleteDirectory              = nn.DeleteDirectory
br.ListFiles                    = nn.ListFiles
br.JSONEncode                   = nn.Utils.JSON.encode
br.JSONDecode                   = nn.Utils.JSON.decode
br.ReadFile                     = nn.ReadFile
br.WriteFile                    = nn.WriteFile
br.FileExists                   = nn.FileExists
br.DeleteFile                   = nn.DeleteFile
br.ListFiles                    = nn.ListFiles
br.UnitTarget                  = nn.UnitTarget
br.ObjectPointer               = nn.ObjectPointer
br.ClickPosition = nn.ClickPosition
br.ClickToMove = function(...) return HardwareActionWrapper("ClickToMove",...) end
br.ObjectAnimationFlag        = nn.ObjectAnimationFlag
br.SendMovementHeartbeat     = nn.SendMovementHeartbeat
br.UnitTarget = nn.UnitTarget
br.GetFocus = nn.GetFocus
br.LibDraw = nn.Utils.Draw:New()
br.ObjectField = nn.ObjectField
br.ObjectFlags = nn.ObjectFlags
br.UpdateLastHardwareAction = nn.UpdateLastHardwareAction



br.TargetUnit               = function(...)  return HardwareActionWrapper("TargetUnit",...) end
br.AttackTarget             =  function() return HardwareActionWrapper("AttackTarget") end
br.CancelShapeshiftForm     =  function() return HardwareActionWrapper("CancelShapeshiftForm") end  
br.CancelUnitBuff           =  function(...) return HardwareActionWrapper("CancelUnitBuff",...) end
br.CastPetAction            =  function(...) return HardwareActionWrapper("CastPetAction",...) end
br.CastShapeSiftForm        =  function(...) return HardwareActionWrapper("CastShapeSiftForm",...) end
br.CastSpell                =  function(...) return HardwareActionWrapper("CastSpell",...) end
br.CastSpellByID            =  function(...) return HardwareActionWrapper("CastSpellByID",...) end
br.CastSpellByName          =  function(...) return HardwareActionWrapper("CastSpellByName",...) end
br.ClearTarget              =  function() return HardwareActionWrapper("ClearTarget") end
br.FocusUnit                =  function(...) return HardwareActionWrapper("FocusUnit",...) end
br.ForceQuit                =  function() return HardwareActionWrapper("ForceQuit") end
br.Logout                   =  function() return HardwareActionWrapper("Logout") end
br.PetAssistMode            =  function() return HardwareActionWrapper("PetAssistMode") end
br.PetAttack                =  function() return HardwareActionWrapper("PetAttack") end
br.PetDefensiveAssistMode   =  function() return HardwareActionWrapper("PetDefensiveAssistMode") end
br.PetDefensiveMode         =  function() return HardwareActionWrapper("PetDefensiveMode") end
br.PetFollow                =  function() return HardwareActionWrapper("PetFollow") end
br.PetPassiveMode           =  function() return HardwareActionWrapper("PetPassiveMode") end
br.PetStopAttack            =  function() return HardwareActionWrapper("PetStopAttack") end
br.PetWait                  =  function() return HardwareActionWrapper("PetWait") end
br.RunMacro                 =  function(...) return HardwareActionWrapper("RunMacro",...) end
br.StartAttack              =  function(...) return HardwareActionWrapper("StartAttack",...) end
br.SpellStopCasting         =  function() return HardwareActionWrapper("SpellStopCasting") end
br.SpellStopTargeting       =  function() return HardwareActionWrapper("SpellStopTargeting") end
br.SpellTargetUnit          =  function(...) return HardwareActionWrapper("SpellTargetUnit",...) end
br.UseContainerItem         =  function(...) return HardwareActionWrapper("UseContainerItem",...) end
br.UseItemByName            =  function(...) return HardwareActionWrapper("UseItemByName",...) end
br.TargetNearestEnemy       =  function(...) return HardwareActionWrapper("TargetNearestEnemy",...) end
br.ConfirmBindOnUse         = function() return HardwareActionWrapper("ConfirmBindOnUse") end
br.FollowUnit               = function(...) return HardwareActionWrapper("FollowUnit",...) end
br.ConfirmBindOnUse         = function() return HardwareActionWrapper("ConfirmBindOnUse") end

--local draw = nn.Utils.Draw:New()

br.unwrap = function(...)
    if br.clientTOC < 120000 then
        return(...)
    end
    return secretunwrap(...)
end

br.api.GetUnitGUID = function(unitId)
    return UnitGUID(unitId)
end
br.Logging:Log("nn Unlocker Loaded");