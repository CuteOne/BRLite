---@type _,br,_
local _,br,_ = ...


---@class br.ModuleLoader
---@field __index br.ModuleLoader
---@field CreateModule fun(self: br.ModuleLoader, name: string): table @Creates a new module or returns an existing one
local ModuleLoader = br.ModuleLoader

---@type br.Logging
local Log = br.Logging or {}
ModuleLoader.name = "ModuleLoader"
function ModuleLoader:CreateModule(name)
    if (not br.Modules[name]) then
        br.Modules[name] = { }
        return br.Modules[name]
    else
        return br.Modules[name]
    end
end

function ModuleLoader:LoadModule(name)
    if (not br.Modules[name]) then
        br.Modules[name] = {  }
        return br.Modules[name]
    else
        return br.Modules[name]
    end
end

function ModuleLoader:PopulateGlobals() -- Used to push modules into global area for debugging.
    for k, v in pairs(br.Modules) do
        _G[k] = v
    end
end


