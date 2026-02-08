---@type _,br,Daemonic
local _,br,dmc = ...

---@class br
br = br or {}

br.Initialization = br.Initialization or {}

br.Initialization.Startup = function(self)
    self.__index = self
    br.Logging:Log("BRLite Initialization Starting TOC: " .. br.clientTOC)
    
    local Includefile =dmc.GetExeDirectory() .. "/BRLite/include.json"
    local IncludeData = dmc.ReadFile(Includefile)
    
    if not IncludeData then
        br.Logging:Log("ERROR: Unable to read include file: " .. Includefile)
        return
    end

    local inclusions = dmc.JsonDecode(IncludeData)

    -- Unlocker specific Includes
    local unlocker = "UNLOCKER-" .. br.unlocker
    if inclusions[unlocker] then
        for _, file in pairs(inclusions[unlocker]) do
            if not dmc.FileExists(dmc.GetExeDirectory() .. "BRLite/" .. file) then
                br.Logging:Log("ERROR: Include file not found: " .. file)
                return
            end
            dmc.RequireFile(dmc.GetExeDirectory() .. "BRLite/" .. file,_G,br,dmc)
        end
    end

    --- EARLY INCLUDES    
    for _, file in pairs(inclusions["EARLY"]) do
        if not dmc.FileExists(dmc.GetExeDirectory() .. "BRLite/" .. file) then
            br.Logging:Log("ERROR: Include file not found: " .. file)
            return
        end
        local status,data = dmc.RequireFile(dmc.GetExeDirectory() .. "BRLite/" .. file,_G,br,dmc)
        if not status then
            br.Logging:Log("ERROR: Include file failed to load: " .. file .. " with error: " .. tostring(data))
            return
        end
    end

    --TOC Specific Includes
    local toc = "TOC-" .. br.clientTOC
    if inclusions[toc] then
        for _, file in pairs(inclusions[toc]) do
            if not dmc.FileExists(dmc.GetExeDirectory() .. "BRLite/" .. file) then
                br.Logging:Log("ERROR: Include file not found: " .. file)
                return
            end
            local status,data = dmc.RequireFile(dmc.GetExeDirectory() .. "BRLite/" .. file,_G,br,dmc)
        end
    end

    --- LATE INCLUDES
    for _, file in pairs(inclusions["LATE"]) do
        if not dmc.FileExists(dmc.GetExeDirectory() .. "BRLite/" .. file) then
            br.Logging:Log("ERROR: Include file not found: " .. file)
            return
        end
        dmc.RequireFile(dmc.GetExeDirectory() .. "BRLite/" .. file,_G,br,dmc)
    end

    
end