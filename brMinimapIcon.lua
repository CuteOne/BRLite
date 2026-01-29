---@type _,br,_
local _,br,_ = ...

---@type br.Logging
local Log = br.Logging or {}
---@type br.Settings
local Settings = br.Settings 

if (not Settings) then
    Log:Log("Settings module not found; It must be initialized first.")
    return
end



---@type LibDBIcon.button.DB
local db = {
    icon = true,
    minimapPos = miniMapLocation,
    hide = false,
    lock = false,
}

--------------------------------------------------------------------------------
---Minimap Icon Module with hookable functions
---@class br.UI.Elements.MinimapIcon
---@field OnLeftClick function #Left Click Handler
---@field OnRightClick function #Right Click Handler
---@field OnMiddleClick function #Middle Click Handler
---@field OnShiftLeftClick function #Shift + Left Click Handler
---@field OnShiftRightClick function #Shift + Right Click Handler
---@field OnShiftMiddleClick function #Shift + Middle Click Handler
---@field Initialize fun(self: br.UI.Elements.MinimapIcon) @Initializes the Minimap Icon
local MinimapIcon = {} --ModuleLoader:CreateModule("BRMinimapIcon")

br.UI.Elements.MinimapIcon = MinimapIcon
MinimapIcon.__index = MinimapIcon

---@type LibDBIcon-1.0
local _LibDBIcon = LibStub("LibDBIcon-1.0");

local function reportUndefinedHandler(handlerName)
    Log:Log("Undefined Handler: " .. handlerName)
end

function MinimapIcon:Initialize()
    
    if not Settings then
        Log:Log("Settings module not found; Minimap Icon cannot be initialized.")
        return
    end
    
    local miniMapLocation = Settings:GetSetting("MinimapIconAngle") or 15
    db.minimapPos = miniMapLocation
    self.ICON =_LibDBIcon:Register(br.name, self:CreateDataBrokerObject(), db)
    self.OnLeftClick = function() reportUndefinedHandler("Left Click") end
    self.OnRightClick = function() reportUndefinedHandler("Right Click") end
    self.OnMiddleClick = function() reportUndefinedHandler("Middle Click") end
    self.OnShiftLeftClick = function() reportUndefinedHandler("Shift + Left Click") end
    self.OnShiftRightClick = function() reportUndefinedHandler("Shift + Right Click") end
    self.OnShiftMiddleClick = function() reportUndefinedHandler("Shift + Middle Click") end
end

function MinimapIcon:SetLeftClickHandler(handler)
    self.OnLeftClick = handler
end

function MinimapIcon:SetMiddleClickHandler(handler)
    self.OnMiddleClick = handler
end

function MinimapIcon:SetRightClickHandler(handler)
    self.OnRightClick = handler
end 

function MinimapIcon:SetShiftLeftClickHandler(handler)
    self.OnShiftLeftClick = handler
end


---comment
---@return LibDataBroker.QuickLauncher
function MinimapIcon:CreateDataBrokerObject()
    local LDBDataObject = LibStub("LibDataBroker-1.1"):NewDataObject(br.name, {
        type = "data source",
        icon = "Interface\\HelpFrame\\HotIssueIcon.blp",
        OnClick = function(_, button)
            ---@type br.UI.Elements.MinimapIcon
            local mmi = br.UI.Elements.MinimapIcon
            if button == "LeftButton" then
                if IsShiftKeyDown() then
                    mmi.OnShiftLeftClick()
                else
                    mmi.OnLeftClick()
                end
            elseif button == "RightButton" then
                if IsShiftKeyDown() then
                    mmi.OnShiftRightClick()
                else
                    mmi.OnRightClick()
                end
            elseif button == "MiddleButton" then
                if IsShiftKeyDown() then
                    mmi.OnShiftMiddleClick()
                else
                    mmi.OnMiddleClick()
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine(br.name)
            tooltip:AddLine("Left Click to toggle the BRLite Settings Window")
            tooltip:AddLine("Right Click to show/hide BRLite Toolbar")
            tooltip:AddLine("Shift + Left Click to show the position mover screen")
        end,
        OnLeave = function(frame) 
            local cX,cY = _G.Minimap:GetCenter()
            local x,y = GetCursorPosition()
            x, y = x / frame:GetEffectiveScale(), y / frame:GetEffectiveScale()
    		local pos = math.deg(math.atan2(y - cY, x - cX)) % 360
            print("Minimap Icon Angle: " .. tostring(pos))
            br.Settings:SetSetting("MinimapIconAngle", pos)
            
        end,
    })
    self.LDBDataObject = LDBDataObject
    return LDBDataObject
end

