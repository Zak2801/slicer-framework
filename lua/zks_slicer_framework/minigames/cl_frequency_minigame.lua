local PANEL = {}

local points = 60

function PANEL:Init()
    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(true)

    self.TargetWave = {
        frequency = math.random(1,5),
        amplitude = math.random(50,150),
        phase = math.random() * math.pi * 2
    }

    self.PlayerWave = {
        frequency = 1,
        amplitude = 100,
        phase = 0
    }

    -- Sliders
    self.FreqSlider = vgui.Create("HackNumSlider", self)
    self.FreqSlider:SetText("Frequency")
    self.FreqSlider:SetMin(0.1)
    self.FreqSlider:SetMax(8)
    self.FreqSlider:SetDecimals(1)
    self.FreqSlider:Dock(TOP)
    self.FreqSlider:DockMargin(0, 120, 0, 0)

    self.AmpSlider = vgui.Create("HackNumSlider", self)
    self.AmpSlider:SetText("Amplitude")
    self.AmpSlider:SetMin(10)
    self.AmpSlider:SetMax(150)
    self.AmpSlider:SetValue(100)
    self.AmpSlider:SetDecimals(0)
    self.AmpSlider:Dock(TOP)

    self.PhaseSlider = vgui.Create("HackNumSlider", self)
    self.PhaseSlider:SetText("Phase")
    self.PhaseSlider:SetMin(0)
    self.PhaseSlider:SetMax(math.pi*2)
    self.PhaseSlider:SetDecimals(2)
    self.PhaseSlider:Dock(TOP)

    self.Progress = 0
    self.Completed = false
end

function PANEL:SetParentFrame(frame) self.ParentFrame = frame end
function PANEL:SetHackTime(t) self.hackTime = math.max(0, t) end
function PANEL:SetEntity(ent) self.ent = ent end
function PANEL:SetDifficulty(d) self.difficulty = d end

local function CalculateMatch(target, player)
    local totalDiff = 0
    for i = 1, points do
        local x = i / points * 2 * math.pi
        local targetY = target.amplitude * math.sin(target.frequency * x + target.phase)
        local playerY = player.amplitude * math.sin(player.frequency * x + player.phase)
        totalDiff = totalDiff + math.abs(targetY - playerY)
    end
    local maxDiff = points * (target.amplitude + player.amplitude)
    return math.Clamp(1 - totalDiff / maxDiff, 0, 1)
end

function PANEL:Think()
    if self.Completed then return end
    self.PlayerWave.frequency = self.FreqSlider:GetValue()
    self.PlayerWave.amplitude = self.AmpSlider:GetValue()
    self.PlayerWave.phase = self.PhaseSlider:GetValue()

    self.Progress = CalculateMatch(self.TargetWave, self.PlayerWave)

    if self.Progress >= 0.85 then
        self.Completed = true
        surface.PlaySound("buttons/button9.wav")

        -- Show "Well Done" popup
        local popup = vgui.Create("HackPopup")
        popup:SetHeaderTitle("WELL DONE!")
        popup:SetText("You have successfully aligned the signal.")
        popup.OnClose = function() 
            if self.ReportResult then
                self:ReportResult(true)
            end    
        end
        popup:SetAcceptButton("Continue", function()
            if self.ReportResult then
                self:ReportResult(true)
            end
        end)
        popup.DeclineButton:Remove()
    end
end

function PANEL:Paint(w, h)
    -- Draw waves
    local function DrawWave(wave, color, yOffset)
        surface.SetDrawColor(color)
        for i = 1, points-1 do
            local x1 = (i-1)/points * w
            local y1 = yOffset - wave.amplitude * math.sin(wave.frequency * (i-1)/points * 2*math.pi + wave.phase)
            local x2 = i/points * w
            local y2 = yOffset - wave.amplitude * math.sin(wave.frequency * i/points * 2*math.pi + wave.phase)
            surface.DrawLine(x1, y1, x2, y2)
        end
    end

    DrawWave(self.TargetWave, Color(200,50,50,255), h*0.5)
    DrawWave(self.PlayerWave, Color(50,200,50,255), h*0.8)

    -- Draw progress bar
    draw.RoundedBox(4, w*0.1, h*0.95, w*0.8, 20, Color(50,50,50,255))
    draw.RoundedBox(4, w*0.1, h*0.95, w*0.8 * self.Progress, 20, Color(50,200,50,255))
end

vgui.Register("HackMinigame_frequency", PANEL, "DPanel")
