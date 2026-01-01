--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\ui\elements\cl_popup.lua
  CLIENT
  Custom popup/modal dialog
---------------------------------------------------------------------------]]

local PANEL = {}

-----------------------------------------------------------------------------
-- Initialize the panel
-----------------------------------------------------------------------------
function PANEL:Init()
    local w, h = ScrW(), ScrH()
    self:SetSize(w * 0.3, h * 0.2)
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(true)
    self:MakePopup()

    self.bgColor = Color(30, 30, 30, 0)

    self.Header = vgui.Create("HackTopBar", self)
    self.Header:SetTitle("POPUP")
    self.Header:SetTall(self:GetTall() * 0.15)
    self.Header:SetCloseFunc(function()
        if self.OnClose then self:OnClose() end
        if IsValid(self.Overlay) then self.Overlay:Remove() end
        self:Close()
    end)

    -- Background fade
    self.Overlay = vgui.Create("DPanel")
    self.Overlay:SetSize(ScrW(), ScrH())
    self.Overlay:SetPos(0, 0)
    self.Overlay:SetDrawOnTop(true)
    self.Overlay.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 180))
    end

    self:SetDrawOnTop(true)

    -- Default colors
    self.titleColor = Color(220, 220, 220)
    self.textColor = Color(200, 200, 200)
    self.buttonColor = Color(80, 150, 255)
    self.buttonHover = Color(100, 180, 255)
    self.buttonTextColor = Color(255, 255, 255)

    -- Main content area
    self.Content = vgui.Create("DPanel", self)
    self.Content:Dock(FILL)
    self.Content.Paint = function(s, w, h)
        surface.SetDrawColor(50, 50, 50)
        surface.DrawRect(0, 0, w, h)
    end

    -- Body text
    self.BodyLabel = vgui.Create("DLabel", self.Content)
    self.BodyLabel:SetFont("ZKSlicerFramework.UI.PrimarySmall")
    self.BodyLabel:SetTextColor(self.textColor)
    self.BodyLabel:SetWrap(true)
    self.BodyLabel:SetAutoStretchVertical(true)
    self.BodyLabel:SetContentAlignment(5)
    self.BodyLabel:Dock(TOP)
    self.BodyLabel:DockMargin(10, 10, 10, 10)
    self.BodyLabel:SetText("Body text goes here.")

    -- Buttons container
    self.Buttons = vgui.Create("DPanel", self.Content)
    self.Buttons:Dock(BOTTOM)
    self.Buttons:SetTall(40)
    self.Buttons.Paint = function() end

    self.AcceptButton = vgui.Create("DButton", self.Buttons)
    self.AcceptButton:SetText("Accept")
    self.AcceptButton:SetFont("ZKSlicerFramework.UI.Primary")
    self.AcceptButton:SetTextColor(self.buttonTextColor)
    self.AcceptButton:Dock(RIGHT)
    self.AcceptButton:SetWide(300)
    self.AcceptButton:DockMargin(5, 5, 5, 5)
    self.AcceptButton.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and self.buttonHover or self.buttonColor)
        surface.DrawRect(0, 0, w, h)
    end
    self.AcceptButton.DoClick = function()
        if self.OnAccept then self:OnAccept() end
        self:Remove()
        if IsValid(self.Overlay) then self.Overlay:Remove() end
    end

    -- Optional Decline Button
    self.DeclineButton = vgui.Create("DButton", self.Buttons)
    self.DeclineButton:SetText("Decline")
    self.DeclineButton:SetFont("ZKSlicerFramework.UI.Primary")
    self.DeclineButton:SetTextColor(self.buttonTextColor)
    self.DeclineButton:Dock(LEFT)
    self.DeclineButton:SetWide(100)
    self.DeclineButton:DockMargin(5, 5, 5, 5)
    self.DeclineButton.Paint = function(s, w, h)
        surface.SetDrawColor(s:IsHovered() and Color(200,80,80) or Color(150,50,50))
        surface.DrawRect(0, 0, w, h)
    end
    self.DeclineButton.DoClick = function()
        if self.OnDecline then self:OnDecline() end
        self:Remove()
        if IsValid(self.Overlay) then self.Overlay:Remove() end
    end
end

-----------------------------------------------------------------------------
-- Called when closed
-----------------------------------------------------------------------------
function PANEL:OnClose()
    -- Override this
    if IsValid(self.Overlay) then self.Overlay:Remove() end
end

-----------------------------------------------------------------------------
-- Paint the popup (border/bg)
-- @param w number Width
-- @param h number Height
-----------------------------------------------------------------------------
function PANEL:Paint(w, h)
    -- fallback background if material missing
    draw.RoundedBox(8, 0, 0, w, h, self.bgColor)
end

-- Functions to customize

-----------------------------------------------------------------------------
-- Set header title
-- @param txt string Title
-----------------------------------------------------------------------------
function PANEL:SetHeaderTitle(txt)
    if self.Header then
        self.Header:SetTitle(txt)
    end
end

-----------------------------------------------------------------------------
-- Set body text
-- @param txt string Text
-----------------------------------------------------------------------------
function PANEL:SetText(txt)
    self.BodyLabel:SetText(txt)
end

-----------------------------------------------------------------------------
-- Set accept button action
-- @param text string Button label
-- @param func function Callback
-----------------------------------------------------------------------------
function PANEL:SetAcceptButton(text, func)
    self.AcceptButton:SetText(text or "Accept")
    self.OnAccept = func
end

-----------------------------------------------------------------------------
-- Set decline button action
-- @param text string Button label
-- @param func function Callback
-----------------------------------------------------------------------------
function PANEL:SetDeclineButton(text, func)
    self.DeclineButton:SetText(text or "Decline")
    self.OnDecline = func
end

vgui.Register("HackPopup", PANEL, "DFrame")