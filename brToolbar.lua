---@type _,br,_
local _,br,_ = ...

---@type AbstractFramework
local AF = _G.AbstractFramework

---@type br.Settings
local Settings = br.Settings

---@class br
br = br or {}

function br:ToggleToolbar()
    if br.TOOLBAR and br.TOOLBAR:IsShown() then
        br.TOOLBAR:Hide()
    else
        br.TOOLBAR:Show()
    end
end

function br:ShowMover()
    AF.ShowMovers("BR")
end

function br:InitializeToolbar()

    local savedSettings = br.Settings:GetSetting("TOOLBAR_SETTINGS")
    if not savedSettings then
        savedSettings = {}
        savedSettings.x = 100
        savedSettings.y = 100
        savedSettings.height = 40
        savedSettings.width = 200
        savedSettings.point = "TOPLEFT"
        savedSettings.shown = true
        Settings:SetSetting("TOOLBAR_SETTINGS",savedSettings)
    end

    ---@type AF_BorderedFrame
    local toolbarFrame = AF.CreateBorderedFrame(
        AF.UIParent,
        "TOOLBAR_FRAME",
        savedSettings.width,
        savedSettings.height,
        "white",
        "black"
    )
    AF.SetPoint(toolbarFrame,savedSettings.point,savedSettings.x,savedSettings.y)
    

    AF.CreateMover(toolbarFrame, "BR", "BR Toolbar Mover",function(p,x,y)
        savedSettings.x = x
        savedSettings.y = y
        savedSettings.point = p
        br.Settings:SetSetting("TOOLBAR_SETTINGS",savedSettings)
    end)
    toolbarFrame:SetFrameLevel(900)


    local brEnableButton = AF.CreateButton(toolbarFrame,nil,"red",40,40)
    brEnableButton:SetPoint("TOPLEFT",0,0)
    brEnableButton:SetTexture("classicon-" .. strlower(PlayerUtil.GetClassFile()),{34,34},{"CENTER",0,0},true) --inv_10_gearupgrade_flightstone_black
    brEnableButton:SetBorderHighlightColor("green")
    brEnableButton:SetBorderColor("green")
    AF.SetTooltips(brEnableButton,"TOPLEFT",-10,0,"Toggle BR Lite Pulse.  Pulse is the main loop that runs the rotation.")
    brEnableButton:SetScript("OnClick",function()
        br.pulse = not br.pulse
        if br.pulse then
            brEnableButton:SetBorderHighlightColor("green")
            brEnableButton:SetBorderColor("green")
            print("BR Lite Pulse Enabled")
        else
            brEnableButton:SetBorderHighlightColor("red")
            brEnableButton:SetBorderColor("red")
            print("BR Lite Pulse Disabled")
        end
    end)

    local brEnableFishing = AF.CreateButton(toolbarFrame,nil,"red",40,40)
    brEnableFishing:SetPoint("TOPLEFT",40,0)
    
    local brEnableFishingInnerFrame = AF.CreateFrame(brEnableFishing,nil,36,36)
    brEnableFishingInnerFrame:SetPoint("CENTER",0,0)
    local tex = brEnableFishingInnerFrame:CreateTexture(nil,"ARTWORK")
    tex:SetTexture(4620674)
    tex:SetSize(30,30)
    tex:SetPoint("CENTER",0,0)  
    tex:SetAllPoints(brEnableFishingInnerFrame)


    -- brEnableFishing:SetTexture("Interface\\Icons\\ui_profession_fishing",{"CENTER",0,0},true)
    brEnableFishing:SetBorderHighlightColor("red")
    brEnableFishing:SetBorderColor("red")
    AF.SetTooltips(brEnableFishing,"TOPLEFT",-10,0,"Toggle Auto Fishing.")
    brEnableFishing:SetScript("OnClick",function()
        br.Fishing.Active = not br.Fishing.Active
        if br.Fishing.Active then
            brEnableFishing:SetBorderHighlightColor("green")
            brEnableFishing:SetBorderColor("green")
             br.Fishing:Fish()
        else
            brEnableFishing:SetBorderHighlightColor("red")
            brEnableFishing:SetBorderColor("red")
           
        end
    end)

    local brMovement = AF.CreateButton(toolbarFrame,nil,"blue",40,40)
    brMovement:SetPoint("TOPLEFT",80,0)
    AF.SetTooltips(brMovement,"TOPLEFT",-10,0,"Enable BR Movement calls, like closing to a target.")
    local brMovementInnerFrame = AF.CreateFrame(brMovement,nil,36,36)
    brMovementInnerFrame:SetPoint("CENTER",0,0)
    local MoveTex = brMovementInnerFrame:CreateTexture(nil,"ARTWORK")
    MoveTex:SetTexture(3193420)
    MoveTex:SetSize(30,30)
    MoveTex:SetPoint("CENTER",0,0)
    if br.DoMovement then
            brMovement:SetBorderHighlightColor("green")
            brMovement:SetBorderColor("green")
        else
            brMovement:SetBorderHighlightColor("red")
            brMovement:SetBorderColor("red")
        end
    MoveTex:SetAllPoints(brMovementInnerFrame)
    brMovement:SetScript("OnClick",function()
        br.DoMovement = not br.DoMovement
        if br.DoMovement then
            brMovement:SetBorderHighlightColor("green")
            brMovement:SetBorderColor("green")
        else
            brMovement:SetBorderHighlightColor("red")
            brMovement:SetBorderColor("red")
        end
    end)

    local brFacing = AF.CreateButton(toolbarFrame,nil,"blue",40,40)
    brFacing:SetPoint("TOPLEFT",120,0)
    AF.SetTooltips(brFacing,"TOPLEFT",-10,0,"Enable BR Facing calls, like ensuring you are facing your target.")
    local brFacingInnerFrame = AF.CreateFrame(brFacing,nil,36,36)
    brFacingInnerFrame:SetPoint("CENTER",0,0)
    local FaceTex = brFacingInnerFrame:CreateTexture(nil,"ARTWORK")
    FaceTex:SetTexture(236372)
    FaceTex:SetSize(30,30)
    FaceTex:SetPoint("CENTER",0,0)
    if br.DoFacing then
            brFacing:SetBorderHighlightColor("green")
            brFacing:SetBorderColor("green")
        else
            brFacing:SetBorderHighlightColor("red")
            brFacing:SetBorderColor("red")
        end
    FaceTex:SetAllPoints(brFacingInnerFrame)
    brFacing:SetScript("OnClick",function()
        br.DoFacing = not br.DoFacing
        if br.DoFacing then
            brFacing:SetBorderHighlightColor("green")
            brFacing:SetBorderColor("green")
        else
            brFacing:SetBorderHighlightColor("red")
            brFacing:SetBorderColor("red")
        end
    end)

    local brLooting = AF.CreateButton(toolbarFrame,nil,"green",40,40)
    brLooting:SetPoint("TOPLEFT",160,0)
    AF.SetTooltips(brLooting,"TOPLEFT",-10,0,"Toggle Auto Looting.")
    local brLootingInnerFrame = AF.CreateFrame(brLooting,nil,36,36)
    brLootingInnerFrame:SetPoint("CENTER",0,0)
    local LootTex = brLootingInnerFrame:CreateTexture(nil,"ARTWORK")
    LootTex:SetTexture(133784)
    LootTex:SetSize(30,30)
    LootTex:SetPoint("CENTER",0,0)
    brLooting:SetBorderHighlightColor("green")
    brLooting:SetBorderColor("green")   
    LootTex:SetAllPoints(brLootingInnerFrame)
    brLooting:SetScript("OnClick",function()
        br.DoLooting = not br.DoLooting
        if br.DoLooting then
            brLooting:SetBorderHighlightColor("green")
            brLooting:SetBorderColor("green")
        else
            brLooting:SetBorderHighlightColor("red")
            brLooting:SetBorderColor("red")
        end
    end)
    br.TOOLBAR = toolbarFrame
end    




    
