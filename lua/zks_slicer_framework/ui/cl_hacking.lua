--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\ui\cl_hacking.lua
  CLIENT
  Main UI frame for the hacking interface, managing minigame sequence
---------------------------------------------------------------------------]]

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}

local PANEL = {}

local w, h = ScrW(), ScrH()
local mat = Material("vgui/frame.png")

-----------------------------------------------------------------------------
-- Initialize the panel
-----------------------------------------------------------------------------
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

-----------------------------------------------------------------------------
-- Think hook for timer updates
-----------------------------------------------------------------------------
function PANEL:Think()
    if self.hackTime == 0 then return end
    if not self.TimerStartTime or not self.hackTime then return end

    local elapsed = RealTime() - self.TimerStartTime
    self.TimerRemaining = math.max(0, self.hackTime - elapsed)

    if self.TimerRemaining <= 0 then
        self:OnHackFailed()
    end
end

-----------------------------------------------------------------------------
-- Paint the panel background
-- @param w number Width
-- @param h number Height
-----------------------------------------------------------------------------
function PANEL:Paint(w, h)
    -- fallback background if material missing
    draw.RoundedBox(8, 0, 0, w, h, self.bgColor)
end

-----------------------------------------------------------------------------
-- Set the target entity
-- @param ent Entity
-----------------------------------------------------------------------------
function PANEL:SetEntity(ent)
    self.ent = ent
end

-----------------------------------------------------------------------------
-- Set the total time allowed for the hack
-- @param t number Time in seconds
-----------------------------------------------------------------------------
function PANEL:SetHackTime(t)
    self.hackTime = math.max(0, t)
    self.TimerStartTime = RealTime()
    self.TimerRemaining = t
end

-----------------------------------------------------------------------------
-- Set the list of allowed minigames
-- @param t table List of strings
-----------------------------------------------------------------------------
function PANEL:SetAllowedMinigames(t)
    self.allowedMinigames = t
end

-----------------------------------------------------------------------------
-- Set the difficulty level
-- @param d number Difficulty
-----------------------------------------------------------------------------
function PANEL:SetDifficulty(d)
    self.difficulty = d
    self.MinigameCount = math.max(1, d) -- one per difficulty for now
end

-----------------------------------------------------------------------------
-- Initialize the hack sequence
-- @param hackType string (unused legacy param?)
-----------------------------------------------------------------------------
function PANEL:SetHackType(hackType)
    self.hackType = hackType
    self.MinigameIndex = 0
    self:StartNextMinigame()
end

-----------------------------------------------------------------------------
-- Transitions to the next minigame in the sequence
-----------------------------------------------------------------------------
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

-----------------------------------------------------------------------------
-- Loads a specific minigame panel
-- @param type string Minigame type name (e.g., "cipher")
-- @param index number Current stage index
-----------------------------------------------------------------------------
function PANEL:LoadMinigame(type, index)
    if IsValid(self.Minigame) then
        self.Minigame:Remove()
    end

    local class = "HackMinigame_" .. type
    
    -- Try to look up in registry
    if ZKSlicerFramework.Minigames then
        local data = ZKSlicerFramework.Minigames.Get(type)
        if data and data.PanelClass then
            class = data.PanelClass
        end
    end

    local pnl = vgui.Create(class, self.Content)
    if not IsValid(pnl) then
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

-----------------------------------------------------------------------------
-- Called when a single minigame stage is passed
-- @param index number Stage index
-----------------------------------------------------------------------------
function PANEL:OnMinigameSuccess(index)
    -- Optional: add a small transition or animation
    chat.AddText(Color(100,255,100), "[HACKING] Stage " .. index .. " complete!")
    self:StartNextMinigame()
end

-----------------------------------------------------------------------------
-- Called when a single minigame stage is failed
-- @param index number Stage index
-----------------------------------------------------------------------------
function PANEL:OnMinigameFailed(index)
    chat.AddText(Color(255,100,100), "[HACKING] Stage " .. index .. " failed!")
    -- You can decide if you want to restart or fail the hack entirely:
    self:OnHackFailed()
end

-----------------------------------------------------------------------------
-- Called when all stages are successfully completed
-----------------------------------------------------------------------------
function PANEL:OnAllMinigamesCompleted()
    chat.AddText(Color(0,255,0), "[HACKING] Hack successful!")
    net.Start(ZKSlicerFramework.NetUtils.HackSuccess)
    net.WriteEntity(self.ent)
    net.SendToServer()
    self:Close()
end

-----------------------------------------------------------------------------
-- Called when the hack is failed (timer or minigame failure)
-----------------------------------------------------------------------------
function PANEL:OnHackFailed()
    net.Start(ZKSlicerFramework.NetUtils.SyncEntHackState)
    net.WriteEntity(self.ent)
    net.WriteBool(false)
    net.SendToServer()
    chat.AddText(Color(255,0,0), "[HACKING] Hack failed.")
    self:Close()
end

vgui.Register("HackHackingFrame", PANEL, "DFrame")