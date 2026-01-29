---@type _,br,NilName
local  _,br,nn = ...

local JSON = nn.Utils.JSON

---@class br.Intialization
---@field __index br.Intialization
---@field Startup fun(self: br.Intialization): nil @Starts up the BRLite application
br.Intialization = br.Intialization or {}

function br.Intialization:Startup()
    self.__index = self
    br.Logging:Log("BRLite Initialization Starting TOC: " .. br.clientTOC)
    
    local Includefile = "/scripts/BRLite/include.json"
    local IncludeData = nn.ReadFile(Includefile)
    
    if not IncludeData then
        br.Logging:Log("ERROR: Unable to read include file: " .. Includefile)
        return
    end

    local inclusions = JSON.decode(IncludeData)

    -- Unlocker specific Includes
    local unlocker = "UNLOCKER-" .. br.unlocker
    if inclusions[unlocker] then
        for _, file in pairs(inclusions[unlocker]) do
            if not nn.FileExists("/scripts/BRLite/" .. file) then
                br.Logging:Log("ERROR: Include file not found: " .. file)
                return
            end
            nn:Require("/scripts/BRLite/" .. file,br,nn)
        end
    end

    --- EARLY INCLUDES    
    for _, file in pairs(inclusions["EARLY"]) do
        if not nn.FileExists("/scripts/BRLite/" .. file) then
            br.Logging:Log("ERROR: Include file not found: " .. file)
            return
        end
        nn:Require("/scripts/BRLite/" .. file,br,nn)
    end

    --TOC Specific Includes
    local toc = "TOC-" .. br.clientTOC
    if inclusions[toc] then
        for _, file in pairs(inclusions[toc]) do
            if not nn.FileExists("/scripts/BRLite/" .. file) then
                br.Logging:Log("ERROR: Include file not found: " .. file)
                return
            end
            nn:Require("/scripts/BRLite/" .. file,br,nn)
        end
    end

    --- LATE INCLUDES
    for _, file in pairs(inclusions["LATE"]) do
        if not nn.FileExists("/scripts/BRLite/" .. file) then
            br.Logging:Log("ERROR: Include file not found: " .. file)
            return
        end
        nn:Require("/scripts/BRLite/" .. file,br,nn)
    end

end


