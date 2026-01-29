---@type _,br,_
local _,br,_ = ...

---@type AbstractFramework
local AF = _G.AbstractFramework

---@class br
br = br or {}

function br:ShowSettingsWindow()

    local savedSettings = br.Settings:GetSetting("WINDOW_SETTINGS")
    if not savedSettings then
        savedSettings = {}
        savedSettings.top = 100
        savedSettings.left = 100
        savedSettings.height = 520
        savedSettings.width = 710
        savedSettings.shown = true
        br.Settings:SetSetting("WINDOW_SETTINGS",savedSettings)
    end

    if br.WINDOW_SETTINGS then
        if br.WINDOW_SETTINGS:IsShown() then
            br.WINDOW_SETTINGS:Hide()
            savedSettings.shown = false
        else            
            br.WINDOW_SETTINGS:Show()
            savedSettings.shown = true
        end            
        br.Settings:SetSetting("WINDOW_SETTINGS",savedSettings)
        return
    end

    savedSettings.shown = true
    br.Settings:SetSetting("WINDOW_SETTINGS",savedSettings)



    ---@type AF_HeaderedFrame
    local settingsWindow = AF.CreateHeaderedFrame(AF.UIParent, "WINDOW_SETTINGS",
        AF.GetIconString("Fluent_Color_Yes", 16) .."  " .. AF.GetGradientText("Bad Rotations Lite", "brightblue", "vividblue") .. " " .. AF.WrapTextInColor( "v" .. tostring(br.Version) , "white"), 
        savedSettings.width, 
        savedSettings.height)
    AF.SetPoint(settingsWindow,"TOPLEFT",savedSettings.top,savedSettings.left*-1)    
    
    settingsWindow:SetOnHide(function() 
        br.Settings:SetSetting(
            "WINDOW_SETTINGS",
            {
                top = br.WINDOW_SETTINGS:GetTop(),
                left = br.WINDOW_SETTINGS:GetLeft(),
                height = br.WINDOW_SETTINGS:GetHeight(),
                width = br.WINDOW_SETTINGS:GetWidth(),
                shown = false
            }
        )
    end)
    
    settingsWindow:SetFrameLevel(900)
    settingsWindow:SetTitleJustify("LEFT")
    
   
     local ns = AF.CreateNetStatsPane(settingsWindow.header, "RIGHT", false, true,"horizontal")
    AF.SetPoint(ns, "RIGHT", settingsWindow.header.closeBtn, "LEFT", -5, 0)

    local fps = AF.CreateFPSPane(settingsWindow.header, "RIGHT")
    AF.SetPoint(fps, "RIGHT", ns, "LEFT", -100, 0)


    local objFrame = AF.CreateFrame(settingsWindow.header,nil,20,20)
    objFrame.text = AF.CreateFontString(objFrame,"","sand","AF_FONT_SMALL")
    AF.SetPoint(objFrame.text,"RIGHT")
    objFrame.text:SetJustifyH("RIGHT")
    AF.SetPoint(objFrame,"RIGHT",fps,"LEFT",-50,0)
    settingsWindow.objFrame = objFrame

    local rotTP = AF.CreateTitledPane(settingsWindow,"Rotation",settingsWindow:GetWidth()-20,100,"vividblue")
    AF.SetPoint(rotTP,"TOPLEFT",10,-10)

    settingsWindow.ddRotation = AF.CreateDropdown(settingsWindow,400)
    AF.SetPoint(settingsWindow.ddRotation,"TOPLEFT",rotTP,"TOPLEFT",10,-40)
    settingsWindow.ddRotation:SetLabel("Select Rotation:")

    settingsWindow.updateRotations = function() 
        local rots = {}
        for k,v in pairs(br.Rotations) do
            tinsert(rots,{["text"]=v.Name,["value"]=k})
        end
        settingsWindow.ddRotation:ClearItems()
        settingsWindow.ddRotation:SetItems(rots)
        settingsWindow.ddRotation:SetSelectedText(rots[1] and rots[1].text or "None")
    end
    settingsWindow.updateRotations()
    settingsWindow:Show()
    br.WINDOW_SETTINGS = settingsWindow
end










