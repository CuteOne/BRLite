---@type Daemonic
local dmc = ...
    
---@type br
local br = nil
local success = false

if (not dmc) or (not dmc.IsInWorld) then
    print("DMC environment not detected. BRLite cannot initialize.")
    return
end

local unlockList =  --add the locked wow APIs you need to this list
{
  "CastSpellByName",
  "JumpOrAscendStart"
}

local localenv = setmetatable(
     {},
        {
            __index = function(self, func)
            return dmc[func] or _G[func]
            end
        }
)

for i = 1, #unlockList do
    local funcname = unlockList[i]
    local func = _G[funcname]
    localenv[funcname] = function(...) return dmc.SecureCode(func, ...) end
end    
    
localenv["GetAF"] = function(...)
    return _G.AbstractFramework
end
setfenv(1, localenv)

local function Main()
    local af = GetAF()
    if not af then
        print("AbstractFramework not found. BRLite cannot initialize.")
        return
    end

     success,br = dmc.RequireFile("/BRLite/br.lua",dmc)
        if not success then
            print("Failed to load br.lua: " .. tostring(br))
            return
        end

     br.unlocker="DMC"
     br.AF = af
     dmc.RequireFile("/BRLite/Bootstrap_DMC.lua",_G,br,dmc)
     dmc.RequireFile("/BRLite/brLogging.lua",_G,br,dmc)
     br.Initialization:Startup() --Unlocker and core functionality loaded here.  This is specific to unlocker.
     br.Settings.RootPath = dmc.GetExeDirectory() .. "settings"
     br.RotationBasePath = dmc.GetExeDirectory() .. "Brlite/rotations"
     br.Framework:Startup()     --The BR Framework.  This will scaffold up the main BR Class with all of the members
end

local function loader()
    if dmc.IsInWorld() then
        C_Timer.After(0.1, Main)
        return
    end
    C_Timer.After(0.1, loader)
end

loader()





   
     


  