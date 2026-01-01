--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\ui\elements\cl_numslider.lua
  CLIENT
  Custom number slider element
---------------------------------------------------------------------------]]

local PANEL = {}

-----------------------------------------------------------------------------
-- Initialize the panel
-----------------------------------------------------------------------------
function PANEL:Init()
    self:SetTall(48)
    self:DockMargin(10, 10, 10, 0)

    self.Min = 0
    self.Max = 1
    self.Decimals = 0
    self.Value = 0.5
    self.LabelText = "Label"

    -- Colors
    self.BarColor = Color(32, 82, 130)
    self.BarBackground = Color(20, 40, 60)
    self.KnobColor = Color(255, 180, 50)
    self.TextColor = Color(230, 230, 230)
    self.HighlightColor = Color(70, 130, 200)

    self.HoverLerp = 0
    self.LastSoundTime = 0
end

-- ──────────────────────────────
-- Setters
-- ──────────────────────────────

-----------------------------------------------------------------------------
-- Set minimum value
-- @param val number
-----------------------------------------------------------------------------
function PANEL:SetMin(val) self.Min = val end

-----------------------------------------------------------------------------
-- Set maximum value
-- @param val number
-----------------------------------------------------------------------------
function PANEL:SetMax(val) self.Max = val end

-----------------------------------------------------------------------------
-- Set decimal places
-- @param val number
-----------------------------------------------------------------------------
function PANEL:SetDecimals(val) self.Decimals = val end

-----------------------------------------------------------------------------
-- Set current value
-- @param val number
-----------------------------------------------------------------------------
function PANEL:SetValue(val)
    self.Value = math.Clamp(val, self.Min, self.Max)
end

-----------------------------------------------------------------------------
-- Set label text
-- @param txt string
-----------------------------------------------------------------------------
function PANEL:SetText(txt) self.LabelText = txt end

-- ──────────────────────────────
-- Value Handling
-- ──────────────────────────────

-----------------------------------------------------------------------------
-- Get fraction (0-1)
-- @return number
-----------------------------------------------------------------------------
function PANEL:GetFraction()
    return (self.Value - self.Min) / (self.Max - self.Min)
end

-----------------------------------------------------------------------------
-- Get current value
-- @return number
-----------------------------------------------------------------------------
function PANEL:GetValue()
    return self.Value
end

-----------------------------------------------------------------------------
-- Set value by fraction
-- @param frac number
-----------------------------------------------------------------------------
function PANEL:SetFraction(frac)
    self:SetValue(self.Min + frac * (self.Max - self.Min))
end

-----------------------------------------------------------------------------
-- Called when value changes
-- @param val number
-----------------------------------------------------------------------------
function PANEL:OnValueChanged(val)
    -- override in parent
end

-- ──────────────────────────────
-- Input
-- ──────────────────────────────

-----------------------------------------------------------------------------
-- Handle mouse press
-----------------------------------------------------------------------------
function PANEL:OnMousePressed()
    self:MouseCapture(true)
    self.Dragging = true
    surface.PlaySound("ui/buttonclickrelease.wav")
end

-----------------------------------------------------------------------------
-- Handle mouse release
-----------------------------------------------------------------------------
function PANEL:OnMouseReleased()
    self:MouseCapture(false)
    self.Dragging = false
end

-----------------------------------------------------------------------------
-- Think loop for dragging and animations
-----------------------------------------------------------------------------
function PANEL:Think()
    if self:IsHovered() then
        self.HoverLerp = Lerp(FrameTime() * 10, self.HoverLerp, 1)
    else
        self.HoverLerp = Lerp(FrameTime() * 8, self.HoverLerp, 0)
    end

    if self.Dragging then
        local mx, my = self:CursorPos()
        local barX, barW = 160, self:GetWide() - 230
        local frac = math.Clamp((mx - barX) / barW, 0, 1)
        local val = self.Min + frac * (self.Max - self.Min)
        val = math.Round(val, self.Decimals)

        if val ~= self.Value then
            self.Value = val
            self:OnValueChanged(val)
            local t = CurTime()
            if t - self.LastSoundTime > 0.1 then
                surface.PlaySound("ui/buttonrollover.wav")
                self.LastSoundTime = t
            end
        end
    end
end

-- ──────────────────────────────
-- Paint
-- ──────────────────────────────

-----------------------------------------------------------------------------
-- Paint the slider
-- @param w number
-- @param h number
-----------------------------------------------------------------------------
function PANEL:Paint(w, h)
    local textMargin = 20
    local valMargin = 20
    local barHeight = 15
    local labelWidth = 130
    local valueWidth = 60

    local barX = labelWidth + textMargin
    local barW = w - labelWidth - valueWidth - valMargin * 2
    local barY = h / 2 - barHeight / 2

    -- Label
    draw.SimpleText(self.LabelText, "ZKSlicerFramework.UI.SecondarySmall", textMargin, h / 2, self.TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    -- Background
    surface.SetDrawColor(self.BarBackground)
    surface.DrawRect(barX, barY, barW, barHeight)

    -- Fill + Hover Highlight
    local fillW = barW * self:GetFraction()
    local col = Color(
        Lerp(self.HoverLerp, self.BarColor.r, self.HighlightColor.r),
        Lerp(self.HoverLerp, self.BarColor.g, self.HighlightColor.g),
        Lerp(self.HoverLerp, self.BarColor.b, self.HighlightColor.b)
    )
    surface.SetDrawColor(col)
    surface.DrawRect(barX, barY, fillW, barHeight)

    -- Knob
    local knobW, knobH = 10, 22
    local knobX = barX + fillW - knobW / 2
    local knobY = h / 2 - knobH / 2
    surface.SetDrawColor(self.KnobColor)
    surface.DrawRect(knobX, knobY, knobW, knobH)

    -- Value text
    local valText = string.format("%." .. self.Decimals .. "f", self.Value)
    draw.SimpleText(valText, "ZKSlicerFramework.UI.PrimarySmall", w - valMargin, h / 2, self.TextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

vgui.Register("HackNumSlider", PANEL, "DPanel")