---@type _,br,_
local  _,br,_ = ...

---@type br.Logging
local Log = br.Logging or {}

-- ---@type br.ModuleLoader
-- local ModuleLoader = br.ModuleLoader or {}
-- if(ModuleLoader.name ~= "ModuleLoader") then
--     Log:Log("Module Loader not found; It must be initialized first.")
--     return
-- end

---@class br.Settings
---@field settings table  #Settings table
---@field __index br.Settings
---@field settingsFullPath string  #Full path to settings file
---@field LoadSettings function  #Load settings from file
---@field SaveSettings function  #Save settings to file
---@field Initialize fun(self:br.Settings,path:string,file:string)  #Initialize settings system
local Settings = {}
br.Settings = Settings
br.Settings.__index = br.Settings 
Settings.Loaded = false
Settings.RootPath = ""


function Settings:LoadSettings()
    local data = br.ReadFile(self.settingsFullPath)
    if not data or data == "" then return end
    self.settings = br.JSONDecode(data)
    self.Loaded = true
end

function Settings:SaveSettings()
    local encoded = br.JSONEncode(self.settings)
    br.WriteFile(self.settingsFullPath, encoded)
end


function Settings:GetSettingToggle(key, default)
    local setting = self:GetSetting(key)
    if setting == nil then
        return default
    end
    return setting
end

---Return system setting with a given value
---@param key string @key to retrieve
---@return any @results may be string, number, table or nil
function Settings:GetSetting(key)
    if not self.Loaded then
        Log:LogError("Settings not loaded yet; cannot get setting for key: " .. tostring(key))
    end
    return self.settings[key] 
end

---Set a system setting with a given value
---@param key string @key to set
---@param value any @value to set
function Settings:SetSetting(key, value)
    self.settings[key] = value
    Settings:SaveSettings()
end

function Settings:GetProfileSetting()
end

function Settings:SetProfileSetting()
end

function Settings:Initialize(path,file)
    self.settingsLocation = self.RootPath or "./settings"
    self.settingsFile = file or "brlite_settings.json"
    self.settingsFullPath = self.settingsLocation .. "/" .. self.settingsFile

    path = path or self.settingsLocation

    print("Settings Path: " .. tostring(path))
    print("Settigns full path: " .. self.settingsFullPath )

    if not br.DirectoryExists(path) then
        br.CreateDirectory(path)
    end
    if not br.FileExists(self.settingsFullPath) then
        br.WriteFile(self.settingsFullPath , "{}")
    end
    Settings:LoadSettings()
end

br.Settings = Settings
Log:Log("Settings module initialized")

 
