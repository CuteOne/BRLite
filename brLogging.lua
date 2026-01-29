---@type _,br,NilName
local  _,br,nn = ...


---@class br.Logging
---@field __index br.Logging
---@field Log fun(self: br.Logging, message: string): nil @Logs a message to the console
---@field LogError fun(self: br.Logging, message: string): nil @Logs an error message to the console
---@field LogCast fun(self: br.Logging, spellName: string): nil @Logs a spell cast message to the console
---@field LogTargetChange fun(self: br.Logging, newTarget: Unit): nil @Logs a target change message to the console
br.Logging = br.Logging or {}

function br.Logging:Log(message)
     self.__index = self
    print("|cffa330c9[BRLite]|r " .. message)
end

function br.Logging:LogError(message)
     self.__index = self
    print("|cffa330c9[BRLite] |cFFc41e3a" .. message .. "|r")
end

function br.Logging:LogCast(spellName)
     self.__index = self
    print("|cffa330c9[BRLite] |cFF00FF00Casting: " .. spellName .. "|r")
end

---comment
---@param newTarget Unit
function br.Logging:LogTargetChange(newTarget)
     self.__index = self
    print("|cffa330c9[BRLite] |cFF00FFFFTarget Changed To: " .. newTarget.name .. "|r")
end