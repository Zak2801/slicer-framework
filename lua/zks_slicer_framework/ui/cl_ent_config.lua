ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}

local PANEL = {}
local w, h = ScrW(), ScrH()

function PANEL:Init()
    self:SetSize(w / 1.618 / 1.5, h / 1.618 / 1.5)
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:MakePopup()
    self:SetDraggable(true)

    self.bgColor = Color(25, 25, 25, 0)
    self.textColor = Color(230, 230, 230)
    self.accentColor = Color(100, 170, 255)

    -- Header
    self.Header = vgui.Create("HackTopBar", self)
    self.Header:SetTitle(language.GetPhrase("zksf.config.title"))
    self.Header:SetTall(self:GetTall() * 0.1)
    self.Header:SetCloseFunc(function()
        self:Close()
    end)

    -- Main content area
    self.Content = vgui.Create("DPanel", self)
    self.Content:Dock(FILL)
    self.Content.Paint = function(s, w, h)
        surface.SetDrawColor(50, 50, 50)
        surface.DrawRect(0, 0, w, h)
    end

    -- Tier Buttons
    self.Tiers = vgui.Create("DPanel", self.Content)
    self.Tiers:Dock(TOP)
    self.Tiers:SetTall(self:GetTall() * 0.15)
    self.Tiers:DockMargin(10, 10, 10, 0)
    self.Tiers.Paint = nil

    local tiers = {
        { name = language.GetPhrase("zksf.config.tier0"), diff = 1, time = 0, color = Color(100, 200, 100) },
        { name = language.GetPhrase("zksf.config.tier1"), diff = 1, time = 30, color = Color(100, 200, 225) },
        { name = language.GetPhrase("zksf.config.tier2"), diff = 3, time = 60, color = Color(225, 200, 100) },
        { name = language.GetPhrase("zksf.config.tier3"), diff = 5, time = 240, color = Color(240, 100, 100) },
    }

    self.TierButtons = {}

    for _, data in ipairs(tiers) do
        local btn = vgui.Create("DButton", self.Tiers)
        btn:SetSize(self:GetWide() / (#tiers + 1), self.Tiers:GetTall() / 2)
        btn:Dock(LEFT)
        btn:DockMargin(5, 0, 5, 0)
        btn:SetText(data.name)
        btn:SetFont("ZKSlicerFramework.UI.Primary")
        btn:SetTextColor(self.textColor)
        btn.Paint = function(s, w, h)
            local col = s:IsHovered() and Color(data.color.r + 20, data.color.g + 20, data.color.b + 20) or data.color
            draw.RoundedBox(8, 0, 0, w, h, col)
        end
        btn.DoClick = function()
            self.Difficulty:SetValue(data.diff)
            self.HackTime:SetValue(data.time)
            surface.PlaySound("buttons/button14.wav")
        end
        table.insert(self.TierButtons, btn)
    end

    self.Difficulty = vgui.Create("HackNumSlider", self.Content)
    self.Difficulty:Dock(TOP)
    self.Difficulty:SetText(language.GetPhrase("zksf.config.difficulty"))
    self.Difficulty:SetMin(1)
    self.Difficulty:SetMax(5)
    self.Difficulty:SetDecimals(0)
    self.Difficulty:SetValue(1)

    self.HackTime = vgui.Create("HackNumSlider", self.Content)
    self.HackTime:Dock(TOP)
    self.HackTime:SetText(language.GetPhrase("zksf.config.time"))
    self.HackTime:SetMin(0)
    self.HackTime:SetMax(360)
    self.HackTime:SetDecimals(0)
    self.HackTime:SetValue(0)

    local DLabel = vgui.Create( "DLabel", self.Content )
    DLabel:Dock(TOP)
    DLabel:DockMargin(28, 6, 10, 0)
    DLabel:SetText( language.GetPhrase("zksf.config.notimer") )
    DLabel:SetFont( "ZKSlicerFramework.UI.PrimarySmall" )
    
    if IsValid(self.ent) and ent:GetEmitDatapad() ~= nil then
        self.DatapadToggle = vgui.Create("HackCheckbox", self.Content)
        self.DatapadToggle:Dock(TOP)
        self.DatapadToggle:SetText(language.GetPhrase("zksf.config.emit_datapad"))
        self.DatapadToggle:DockMargin(18, 12, 10, 0)
        self.DatapadToggle:SetChecked(ent:GetEmitDatapad() == 1)
    end

    -- Save button
    self.Save = vgui.Create("DButton", self.Content)
    self.Save:Dock(BOTTOM)
    self.Save:DockMargin(10, 10, 10, 10)
    self.Save:SetTall(self:GetTall() * 0.1)
    self.Save:SetText(language.GetPhrase("zksf.config.save"))
    self.Save:SetFont("ZKSlicerFramework.UI.Primary")
    self.Save:SetTextColor(Color(255, 255, 255))
    self.Save.Paint = function(s, w, h)
        local col = s:IsHovered() and Color(120, 180, 255) or self.accentColor
        draw.RoundedBox(10, 0, 0, w, h, col)
    end
    self.Save.DoClick = function()
        if not IsValid(self.ent) then return end
        net.Start(ZKSlicerFramework.NetUtils.SyncEntConfig)
        net.WriteEntity(self.ent)
        net.WriteInt(self.Difficulty:GetValue(), 8)
        net.WriteInt(self.HackTime:GetValue(), 32)
        if IsValid(self.DatapadToggle) then
            net.WriteBool(self.DatapadToggle:GetChecked())
        else
            net.WriteBool(false)
        end
        net.SendToServer()
        surface.PlaySound("buttons/button15.wav")
        self:Close()
    end

    -- Reset button
    self.Reset = vgui.Create("DButton", self.Content)
    self.Reset:Dock(BOTTOM)
    self.Reset:DockMargin(10, 10, 10, 10)
    self.Reset:SetTall(self:GetTall() * 0.1)
    self.Reset:SetText(language.GetPhrase("zksf.config.reset"))
    self.Reset:SetFont("ZKSlicerFramework.UI.Primary")
    self.Reset:SetTextColor(Color(255, 255, 255))
    self.Reset.Paint = function(s, w, h)
        local col = s:IsHovered() and Color(120, 180, 255) or self.accentColor
        draw.RoundedBox(10, 0, 0, w, h, col)
    end
    self.Reset.DoClick = function()
        if not IsValid(self.ent) then return end
        net.Start(ZKSlicerFramework.NetUtils.SyncEntHackState)
        net.WriteEntity(self.ent)
        net.WriteBool(false)
        net.WriteBool(false)
        net.SendToServer()
        surface.PlaySound("buttons/button15.wav")
        self:Close()
    end
end

function PANEL:SetEntity(ent)
    if not IsValid(ent) then return end
    self.ent = ent

    self.Difficulty:SetValue(ent:GetDifficulty() or 1)
    self.HackTime:SetValue(ent:GetHackTime() or 60)

    -- entity supports datapad options
    local succ, err = pcall(function() ent:GetEmitDatapad() end)
    if succ then
        self.DatapadToggle = vgui.Create("HackCheckbox", self.Content)
        self.DatapadToggle:Dock(TOP)
        self.DatapadToggle:SetText(language.GetPhrase("zksf.config.emit_datapad"))
        self.DatapadToggle:DockMargin(18, 12, 10, 0)
        self.DatapadToggle:SetChecked(ent:GetEmitDatapad() == 1)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(12, 0, 0, w, h, self.bgColor)
end

vgui.Register("HackConfigPanel", PANEL, "DFrame")
