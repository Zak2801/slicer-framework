--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\ui\elements\cl_topbar.lua
  CLIENT
  Custom window title bar
---------------------------------------------------------------------------]]

local PANEL = {}

local width = 4

-----------------------------------------------------------------------------
-- Initialize the panel
-----------------------------------------------------------------------------
function PANEL:Init()
    self:SetTall(36)
    self:Dock(TOP)

    self.borderColor = Color(15, 50, 80)
    self.textColor = Color(220, 220, 220)
    self.highlightColor = Color(5, 22, 35)
    self.closeHover = Color(40, 90, 140)
    self.closeIdle = Color(32, 82, 130)

    self.title = "Top Bar"

    -- Close button
    self.CloseButton = vgui.Create("DButton", self)
    self.CloseButton:Dock(RIGHT)
    self.CloseButton:SetWide(40)
    self.CloseButton:SetText("✕") -- 
    self.CloseButton:SetFont("ZKSlicerFramework.UI.Primary")
    self.CloseButton:SetTextColor(self.textColor)
    self.CloseButton.Paint = function(s, w, h)
        local col = s:IsHovered() and self.closeHover or self.closeIdle
        draw.RoundedBox(0, 0, 0, w, h, col)
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, w, h - width) -- subtle top highlight
        surface.SetDrawColor(self.borderColor)
        surface.DrawRect(0, h - width, w, width) -- bottom shadow
    end
    self.CloseButton.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        if self.OnClose then self:OnClose() end
    end
end

-----------------------------------------------------------------------------
-- Set the title
-- @param txt string Title
-----------------------------------------------------------------------------
function PANEL:SetTitle(txt)
    self.title = txt
end

-----------------------------------------------------------------------------
-- Set close callback
-- @param fn function Callback
-----------------------------------------------------------------------------
function PANEL:SetCloseFunc(fn)
    self.OnClose = fn
end

-----------------------------------------------------------------------------
-- Paint the top bar
-- @param w number Width
-- @param h number Height
-----------------------------------------------------------------------------
function PANEL:Paint(w, h)
    -- Draw top subtle highlight
    surface.SetDrawColor(self.highlightColor)
    surface.DrawRect(0, 0, w, h - width)

    -- Bottom shadow line
    surface.SetDrawColor(self.borderColor)
    surface.DrawRect(0, h - width, w, width)

    draw.SimpleText(self.title, "ZKSlicerFramework.UI.PrimaryItalic", 10, h / 2, self.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("HackTopBar", PANEL, "DPanel")