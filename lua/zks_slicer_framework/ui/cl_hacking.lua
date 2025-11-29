ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}

local PANEL = {}

local w, h = ScrW(), ScrH()
local mat = Material("vgui/frame.png")

function PANEL:Init()
    self:SetSize(w / 1.618, h / 1.618)
    self:Center()
    self:SetTitle("")
    self:ShowCloseButton(false)
    self:SetDraggable(true)
    self:MakePopup()

    self.MinigameIndex = 0
    self.MinigameCount = 1
    self.difficulty = 1

    -- Custom colors
    self.bgColor = Color(30, 30, 30, 0)
    self.headerColor = Color(40, 40, 40)
    self.textColor = Color(200, 200, 200)
    self.accentColor = Color(100, 200, 255)

    self.Header = vgui.Create("HackTopBar", self)
    self.Header:SetTitle("HACKING INTERFACE")
    self.Header:SetTall(self:GetTall() * 0.05)
    self.Header:SetCloseFunc(function()
        if self.ent and IsValid(self.ent) then
            net.Start(ZKSlicerFramework.NetUtils.SyncEntHackState)
            net.WriteEntity(self.ent)
            net.WriteBool(false)
            net.SendToServer()
        end
        self:Close()
    end)

    -- Main content area
    self.Content = vgui.Create("DPanel", self)
    self.Content:Dock(FILL)
    self.Content.Paint = function(s, w, h)
        -- surface.SetDrawColor(50, 50, 50)
        -- surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)

        -- Timer bar
        if self.TimerRemaining and self.hackTime > 0 then
            local barWidth = w * 0.6
            local barHeight = 16
            local barX = w / 2 - barWidth / 2
            local barY = 50

            surface.SetDrawColor(50, 50, 50, 180)
            surface.DrawRect(barX, barY, barWidth, barHeight)

            local fraction = self.TimerRemaining / self.hackTime
            surface.SetDrawColor(255, 180, 50, 255)
            surface.DrawRect(barX, barY, barWidth * fraction, barHeight)

            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawOutlinedRect(barX, barY, barWidth, barHeight)
        end
    end
end

function PANEL:Think()
    if self.hackTime == 0 then return end
    if not self.TimerStartTime or not self.hackTime then return end

    local elapsed = RealTime() - self.TimerStartTime
    self.TimerRemaining = math.max(0, self.hackTime - elapsed)

    if self.TimerRemaining <= 0 then
        self:OnHackFailed()
    end
end

function PANEL:Paint(w, h)
    -- fallback background if material missing
    draw.RoundedBox(8, 0, 0, w, h, self.bgColor)
end

function PANEL:SetEntity(ent)
    self.ent = ent
end

function PANEL:SetHackTime(t)
    self.hackTime = math.max(0, t)
    self.TimerStartTime = RealTime()
    self.TimerRemaining = t
end

function PANEL:SetAllowedMinigames(t)
    self.allowedMinigames = t
end

function PANEL:SetDifficulty(d)
    self.difficulty = d
    self.MinigameCount = math.max(1, d) -- one per difficulty for now
end

-- Instead of SetHackType being the only logic, we’ll split init vs load
function PANEL:SetHackType(hackType)
    self.hackType = hackType
    self.MinigameIndex = 0
    self:StartNextMinigame()
end

-- Called to start the next stage
function PANEL:StartNextMinigame()
    self.MinigameIndex = self.MinigameIndex + 1

    -- Finished all minigames
    if self.MinigameIndex > self.MinigameCount then
        self:OnAllMinigamesCompleted()
        return
    end
    
    local randomMiniGame = table.Random(self.allowedMinigames or {})
    self:LoadMinigame(randomMiniGame, self.MinigameIndex)
end

function PANEL:LoadMinigame(type, index)
    if IsValid(self.Minigame) then
        self.Minigame:Remove()
    end

    local class = "HackMinigame_" .. type
    local pnl = vgui.Create(class, self.Content)
    if !IsValid(pnl) then
        ErrorNoHalt("[HACKING] Missing minigame type: " .. type .. "\n")
        self:OnMinigameFailed(index)
        return
    end

    pnl:Dock(FILL)
    pnl:SetParentFrame(self)
    pnl:SetDifficulty(self.difficulty)
    pnl:SetHackTime(self.hackTime)
    pnl:SetEntity(self.ent)

    function pnl:ReportResult(success)
        if not IsValid(self.ParentFrame) then return end
        if success then
            self.ParentFrame:OnMinigameSuccess(index)
        else
            self.ParentFrame:OnMinigameFailed(index)
        end
    end

    self.Minigame = pnl
end

-- =============================
-- CALLBACKS FROM MINIGAMES
-- =============================

function PANEL:OnMinigameSuccess(index)
    -- Optional: add a small transition or animation
    chat.AddText(Color(100,255,100), "[HACKING] Stage " .. index .. " complete!")
    self:StartNextMinigame()
end

function PANEL:OnMinigameFailed(index)
    chat.AddText(Color(255,100,100), "[HACKING] Stage " .. index .. " failed!")
    -- You can decide if you want to restart or fail the hack entirely:
    self:OnHackFailed()
end

function PANEL:OnAllMinigamesCompleted()
    chat.AddText(Color(0,255,0), "[HACKING] Hack successful!")
    net.Start(ZKSlicerFramework.NetUtils.HackSuccess)
    net.WriteEntity(self.ent)
    net.SendToServer()
    self:Close()
end

function PANEL:OnHackFailed()
    net.Start(ZKSlicerFramework.NetUtils.SyncEntHackState)
    net.WriteEntity(self.ent)
    net.WriteBool(false)
    net.SendToServer()
    chat.AddText(Color(255,0,0), "[HACKING] Hack failed.")
    self:Close()
end

vgui.Register("HackHackingFrame", PANEL, "DFrame")
