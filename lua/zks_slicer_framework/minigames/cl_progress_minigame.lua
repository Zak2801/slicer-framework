--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\minigames\cl_progress_minigame.lua
  CLIENT
  Simple progress bar minigame (wait to hack)
---------------------------------------------------------------------------]]

local PANEL = {}

-----------------------------------------------------------------------------
-- Initialize the panel
-----------------------------------------------------------------------------
function PANEL:Init()
    self.Progress = 0
    self.StartTime = CurTime()
    self.EndTime = self.StartTime + 5
    self.Label = vgui.Create("DLabel", self)
    self.Label:SetText("Hacking in progress...")
    self.Label:Dock(TOP)
    self.Label:SetContentAlignment(5)
end

-----------------------------------------------------------------------------
-- Set the parent frame
-- @param frame Panel The parent hacking frame
-----------------------------------------------------------------------------
function PANEL:SetParentFrame(frame)
    self.ParentFrame = frame
end

-----------------------------------------------------------------------------
-- Set the hack time limit
-- @param t number Time in seconds
-----------------------------------------------------------------------------
function PANEL:SetHackTime(t)
    self.hackTime = t
    -- Adjust EndTime if hackTime is provided, though Init sets a default 5s
    if t then
        self.EndTime = self.StartTime + t
    end
end

-----------------------------------------------------------------------------
-- Set the target entity
-- @param ent Entity The hackable entity
-----------------------------------------------------------------------------
function PANEL:SetEntity(ent)
    self.ent = ent
end

-----------------------------------------------------------------------------
-- Paint the minigame
-- @param w number Width
-- @param h number Height
-----------------------------------------------------------------------------
function PANEL:Paint(w, h)
    surface.SetDrawColor(40, 40, 40, 255)
    surface.DrawRect(0, h - 40, w, 30)

    local frac = math.Clamp((CurTime() - self.StartTime) / (self.EndTime - self.StartTime), 0, 1)
    surface.SetDrawColor(100, 200, 100, 255)
    surface.DrawRect(0, h - 40, w * frac, 30)

    if frac >= 1 and not self.Finished then
        self.Finished = true
        -- Randomize failure chance based on difficulty? (Currently hardcoded)
        local success = math.random() > 0.2
        self:ReportResult(success)
    end
end

-- This is just an example minigame
vgui.Register("HackMinigame_progress", PANEL, "DPanel")

-- ZKSlicerFramework.Minigames.Register("progress", {
--     Name = "Data Extraction",
--     Description = "Wait for the hack to complete.",
--     PanelClass = "HackMinigame_progress"
-- })