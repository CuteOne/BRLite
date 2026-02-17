---@type _, br, NilName
local _, br, nn = ...

---@class br
br = br or {}

---@type br.Logging
br.Logging = br.Logging or {}

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
br.ClickToMove = nn.ClickToMove
br.ObjectAnimationFlag        = nn.ObjectAnimationFlag
br.SendMovementHeartbeat     = nn.SendMovementHeartbeat
br.UnitTarget = nn.UnitTarget
br.GetFocus = nn.GetFocus
br.LibDraw = nn.Utils.Draw:New()
br.ObjectField = nn.ObjectField
br.ObjectFlags = nn.ObjectFlags



br.TargetUnit               =  function(...) return nn.Unlock("TargetUnit",...) end
br.AttackTarget             =  function() return nn.Unlock("AttackTarget") end
br.CancelShapeshiftForm     =  function() return nn.Unlock("CancelShapeshiftForm") end
br.CancelUnitBuff           =  function(...) return nn.Unlock("CancelUnitBuff",...) end
br.CastPetAction            =  function(...) return nn.Unlock("CastPetAction",...) end
br.CastShapeSiftForm        =  function(...) return nn.Unlock("CastShapeSiftForm",...) end
br.CastSpell                =  function(...) return nn.Unlock("CastSpell",...) end
br.CastSpellByID            =  function(...) return nn.Unlock("CastSpellByID",...) end
br.CastSpellByName          =  function(...) return nn.Unlock("CastSpellByName",...) end
br.ClearTarget              =  function() return nn.Unlock("ClearTarget") end
--br.ClickPosition            =  function(...) return nn.Unlock("ClickPosition",...) end  
br.FocusUnit                =  function(...) return nn.Unlock("FocusUnit",...) end
br.ForceQuit                =  function() return nn.Unlock("ForceQuit") end
br.Logout                   =  function() return nn.Unlock("Logout") end
br.PetAssistMode            =  function() return nn.Unlock("PetAssistMode") end
br.PetAttack                =  function() return nn.Unlock("PetAttack") end
br.PetDefensiveAssistMode   =  function() return nn.Unlock("PetDefensiveAssistMode") end
br.PetDefensiveMode         =  function() return nn.Unlock("PetDefensiveMode") end
br.PetFollow                =  function() return nn.Unlock("PetFollow") end
br.PetPassiveMode           =  function() return nn.Unlock("PetPassiveMode") end
br.PetStopAttack            =  function() return nn.Unlock("PetStopAttack") end
br.PetWait                  =  function() return nn.Unlock("PetWait") end
--br.RunMacroText             =  function(...) return nn.Unlock("RunMacroText",...) end
br.RunMacro                 =  function(...) return nn.Unlock("RunMacro",...) end
br.StartAttack              =  function(...) return nn.Unlock("StartAttack",...) end
br.SpellStopCasting         =  function() return nn.Unlock("SpellStopCasting") end
br.SpellStopTargeting       =  function() return nn.Unlock("SpellStopTargeting") end
br.SpellTargetUnit          =  function(...) return nn.Unlock("SpellTargetUnit",...) end
br.UseContainerItem         =  function(...) return nn.Unlock("UseContainerItem",...) end
br.UseItemByName            =  function(...) return nn.Unlock("UseItemByName",...) end
br.TargetNearestEnemy       =  function(...) return nn.Unlock("TargetNearestEnemy",...) end
br.ConfirmBindOnUse         = function() return nn.Unlock("ConfirmBindOnUse") end
br.FollowUnit               = function(...) return nn.Unlock("FollowUnit",...) end
br.ConfirmBindOnUse         = function() return nn.Unlock("ConfirmBindOnUse") end

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