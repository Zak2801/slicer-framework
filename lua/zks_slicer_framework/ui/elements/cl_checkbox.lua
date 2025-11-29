local PANEL = {}

function PANEL:Init()
    self:SetTall(32)
    self:DockMargin(10, 10, 10, 0)

    self.Checked     = false
    self.LabelText   = "Checkbox"
    self.HoverLerp   = 0

    -- Colors
    self.BoxColor        = Color(32, 82, 130)
    self.BoxBackground   = Color(20, 40, 60)
    self.CheckColor      = Color(255, 180, 50)
    self.TextColor       = Color(230, 230, 230)
    self.HighlightColor  = Color(70, 130, 200)

    self.LastSoundTime = 0
end

-- =========================================================
-- Setters
-- =========================================================
function PANEL:SetChecked(b)
    b = tobool(b)
    if b ~= self.Checked then
        self.Checked = b
        self:OnValueChanged(b)
    end
end

function PANEL:GetChecked()
    return self.Checked
end

function PANEL:SetText(t)
    self.LabelText = t
end

-- Override in parent
function PANEL:OnValueChanged(val)
end

-- =========================================================
-- Input
-- =========================================================
function PANEL:OnMousePressed(mc)
    if mc ~= MOUSE_LEFT then return end

    self.Checked = not self.Checked

    local t = CurTime()
    if t - self.LastSoundTime > 0.1 then
        surface.PlaySound("ui/buttonclick.wav")
        self.LastSoundTime = t
    end

    self:OnValueChanged(self.Checked)
end

function PANEL:Think()
    if self:IsHovered() then
        self.HoverLerp = Lerp(FrameTime() * 10, self.HoverLerp, 1)
    else
        self.HoverLerp = Lerp(FrameTime() * 8, self.HoverLerp, 0)
    end
end

-- =========================================================
-- Paint
-- =========================================================
function PANEL:Paint(w, h)
    local boxSize = h * 0.75
    local boxX    = 10
    local boxY    = h / 2 - boxSize / 2

    -- Hover blend color
    local col = Color(
        Lerp(self.HoverLerp, self.BoxColor.r, self.HighlightColor.r),
        Lerp(self.HoverLerp, self.BoxColor.g, self.HighlightColor.g),
        Lerp(self.HoverLerp, self.BoxColor.b, self.HighlightColor.b)
    )

    -- Background box
    surface.SetDrawColor(self.BoxBackground)
    surface.DrawRect(boxX, boxY, boxSize, boxSize)

    -- Fill if checked
    if self.Checked then
        surface.SetDrawColor(self.CheckColor)
        surface.DrawRect(boxX + 4, boxY + 4, boxSize - 8, boxSize - 8)
    else
        surface.SetDrawColor(col)
        surface.DrawOutlinedRect(boxX, boxY, boxSize, boxSize, 2)
    end

    -- Text
    draw.SimpleText(
        self.LabelText,
        "ZKSlicerFramework.UI.SecondarySmall",
        boxX + boxSize + 12,
        h / 2,
        self.TextColor,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )
end

vgui.Register("HackCheckbox", PANEL, "DPanel")
