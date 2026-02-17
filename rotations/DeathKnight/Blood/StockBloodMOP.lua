---@type _,br   #Must include typing to get intellisense in VSCode
local _,br=...

---------------------------------------------------------------------------
-- Rotation Information, Required to determine if the rotation can be used
---------------------------------------------------------------------------
local RotationName = "Stock DK Blood Rotation MOP"
local RotationShortName = "StockDKBloodRotationMOP"
local RotationVersion = 1.0
local RotationDescription = "A basic starter rotation for Blood Death Knights. Only valid until level 10."
local RotationTOCLower = 50503
local RotationTOCUpper = 50503
local RotationClassName = "DEATHKNIGHT"
local RotationSpecializationID = 1

local SpellList = {
 IcyTouch = 45477,
 PlagueStrike = 45462,
 BloodStrike = 45902,
 DeathCoil=47541,
 DeathStrike=49998,
 UnholyBlight=115989,
 BloodBoil=48721,
 MindFreeze=47528,
 Lichborne=49039,
 ChainsOfIce=45524,
 Asphyxiate=108194,
 DeathGrip=49576,
 DarkCommand=56222,
 DeathAndDecay=43265,

}

local AuraList = {
    FrostFever = 55095,
    BloodPlague = 55078,
    Lichborne = 49039,
    DarkCommand=56222,

}

local TalentList = {

   
}


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
local runicPower = br.ActivePlayer:Power()
local runes = br.ActivePlayer:AlternatePower(Enum.PowerType.Runes)


local enemies8yds = nil
local isAOE = false





local function Pulse()

   


    if player:IsBusy() or player:IsMounted() or not player:IsAlive() then return end

    if player.InCombat and not player:ValidTarget("target") then 
       -- print("No valid target, targeting closest enemy.")
        player:TargetBest()
    end
    
    target = br.ActivePlayer:TargetUnit()
    if not target or not UnitCanAttack("player", "target") or not UnitIsEnemy("player", "target") then return end -- still no good target 



    enemies8yds = player:Enemies(8)
    isAOE = #enemies8yds >= 2

    if UnitCanAttack("player", "target") and not UnitIsDeadOrGhost("target") then
        player:EnsureFacing(target)
        player:CloseToMelee(target)
    end

    if  player.InCombat and (cast.able.DeathGrip() or cast.able.DarkCommand()) and br.PullMode then 
        local potentialTarget = player:FindNonTargetingWithinRange(15,30)
        if potentialTarget then
            -- print("Found potential pull target: ", potentialTarget.name, " at distance: ", potentialTarget:Distance()   )
            -- -- if cast.able.DeathGrip(potentialTarget.WoWGUID) then
            -- --         return cast.DeathGrip(potentialTarget.WoWGUID)
            -- -- end
             if cast.able.DarkCommand(potentialTarget.WoWGUID) and not br.Debuffs.up.DarkCommand(potentialTarget) then
                    br.SetFocus(potentialTarget.guid)
                    cast.DarkCommand("focus")
                    br.SetFocus(target.guid)
             end
        end
    end

    if target:IsInterruptable() then
        if cast.able.MindFreeze() then
             return cast.MindFreeze()
        end 
        if cast.able.Asphyxiate() then
            return cast.Asphyxiate()
        end 
    end

    if player:HealthPercent() < 60 then
        if cast.able.Lichborne("player") then
            return cast.Lichborne("player")
        end
        if buffs.up.Lichborne() and cast.able.DeathCoil("player") then
            return cast.DeathCoil("player")
        end
    end


    if not player:IsAuto() then return player:StartAutoAttack() end

    if UnitIsDeadOrGhost("target") then return end

    if cast.able.DeathStrike() then
        return cast.DeathStrike()   
    end

    if isAOE and cast.able.UnholyBlight() then
        return cast.UnholyBlight()
    end

    if isAOE and cast.able.DeathAndDecay() then
        return cast.atTargetGround.DeathAndDecay("player")
    end

     if cast.able.BloodBoil() and br.Debuffs.up.BloodPlague(target) then
        return cast.BloodBoil()
    end

    if cast.able.PlagueStrike() and not br.Debuffs.up.BloodPlague(target) then
        return cast.PlagueStrike()
    end

    if cast.able.BloodStrike() then
        return cast.BloodStrike()
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
    rotation.Pulse = Pulse
    rotation.SpellList = SpellList or {}
    rotation.ToggleOptions = {}
    br.ActivePlayer:BuffSetup(AuraList)
    br.Debuffs:AuraSetup(AuraList)
end 