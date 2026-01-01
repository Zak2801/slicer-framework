--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\minigames\cl_sequence_minigame.lua
  CLIENT
  Sequence memory/reaction minigame
---------------------------------------------------------------------------]]

local PANEL = {}

local arrowIcons = {
    up = Material("vgui/hack_arrows/up.png", "noclamp smooth"),
    down = Material("vgui/hack_arrows/down.png", "noclamp smooth"),
    left = Material("vgui/hack_arrows/left.png", "noclamp smooth"),
    right = Material("vgui/hack_arrows/right.png", "noclamp smooth"),
}

local directions = {"up", "down", "left", "right"}
local keyMap = {
    [KEY_W] = "up",
    [KEY_S] = "down",
    [KEY_A] = "left",
    [KEY_D] = "right",
    [KEY_UP] = "up",
    [KEY_DOWN] = "down",
    [KEY_LEFT] = "left",
    [KEY_RIGHT] = "right"
}

-----------------------------------------------------------------------------
-- Initialize the panel
-----------------------------------------------------------------------------
function PANEL:Init()
    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(false)
    self:SetFocusTopLevel(true)
    self:RequestFocus()

    self.Label = vgui.Create("DLabel", self)
    self.Label:SetText("FOLLOW EACH SEQUENCE")
    self.Label:SetFont("ZKSlicerFramework.UI.PrimarySmall")
    self.Label:SetContentAlignment(5)
    self.Label:Dock(TOP)
    self.Label:DockMargin(0, 4, 0, 0)
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
    self.hackTime = math.max(0, t)
end

-----------------------------------------------------------------------------
-- Set the target entity
-- @param ent Entity The hackable entity
-----------------------------------------------------------------------------
function PANEL:SetEntity(ent)
    self.ent = ent
end

-----------------------------------------------------------------------------
-- Set the difficulty level and generate sequences
-- @param d number Difficulty level
-----------------------------------------------------------------------------
function PANEL:SetDifficulty(d) 
    self.difficulty = d 
    local difficulty = self.difficulty or 1

    self.Completed = false
    self.ResultReported = false

    self.TotalNodes = math.Clamp(math.floor(3 + difficulty * 2), 3, 10)
    self.MinSeqLen = 3
    self.MaxSeqLen = 6
    self.CurrentNode = 1
    self.Nodes = {}

    -- generate nodes with random sequences
    for i = 1, self.TotalNodes do
        local seqLen = math.random(self.MinSeqLen, self.MaxSeqLen)
        local seq = {}
        for j = 1, seqLen do
            local dir = table.Random(directions)
            table.insert(seq, dir)
        end

        table.insert(self.Nodes, {
            Sequence = seq,
            Progress = 1,
            Completed = false
        })
    end
end

-----------------------------------------------------------------------------
-- Get the current active node
-- @return table Node data
-----------------------------------------------------------------------------
function PANEL:GetCurrentNode()
    return self.Nodes[self.CurrentNode]
end

-----------------------------------------------------------------------------
-- Handle key presses
-- @param key number Key code
-----------------------------------------------------------------------------
function PANEL:OnKeyCodePressed(key)
    if self.Completed or self.ResultReported then return end
    local node = self:GetCurrentNode()
    if not node then return end

    local inputDir = keyMap[key]
    if not inputDir then return end

    local expected = node.Sequence[node.Progress]

    if inputDir == expected then
        surface.PlaySound("buttons/button9.wav")
        node.Progress = node.Progress + 1

        -- completed this node?
        if node.Progress > #node.Sequence then
            node.Completed = true
            self.CurrentNode = self.CurrentNode + 1

            -- all nodes done?
            if self.CurrentNode > self.TotalNodes then
                self.Completed = true
                -- Show "Well Done" popup
                local popup = vgui.Create("HackPopup")
                popup:SetHeaderTitle("WELL DONE!")
                popup:SetText("You followed each sequence correctly.")
                popup:SetAcceptButton("Continue", function()
                    if self.ReportResult then
                        self:ReportResult(true)
                        self.ResultReported = true
                    end
                end)
                if popup.DeclineButton then popup.DeclineButton:Remove() end
                return
            end
        end
    else
        surface.PlaySound("buttons/button10.wav")

        -- RESET: back to first node
        self.CurrentNode = 1
        self.ResultReported = false

        -- reset all nodes progress and completion
        for i, n in ipairs(self.Nodes) do
            n.Progress = 1
            n.Completed = false
        end
    end
end

-----------------------------------------------------------------------------
-- Helper to draw a filled circle
-- @param x number X coordinate
-- @param y number Y coordinate
-- @param radius number Circle radius
-- @param color Color Circle color
-- @param segments number Number of segments (optional)
-----------------------------------------------------------------------------
local function DrawCircleFilled(x, y, radius, color, segments)
    local seg = segments or 32
    local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

-----------------------------------------------------------------------------
-- Paint the minigame
-- @param w number Width
-- @param h number Height
-----------------------------------------------------------------------------
function PANEL:Paint(w, h)
    local size = w * 0.05
    local padding = size * 1.5
    local usableWidth = w - (padding * 2)
    local spacing = (self.TotalNodes > 1) and (usableWidth / (self.TotalNodes - 1)) or 0

    local baseY = h * 0.4
    local verticalOffset = h * 0.08
    local bounceAmplitude = size * 0.08
    local bounceSpeed = 2
    local lineThickness = 6

    local positions = {}

    -- Calculate positions first
    for i = 1, self.TotalNodes do
        -- local node = self.Nodes[i] -- Unused
        local x = padding + (i - 1) * spacing
        local y = baseY + ((i % 2 == 0) and -verticalOffset or verticalOffset)
        positions[i] = { x = x, y = y }
    end

    -- Draw connection lines (now actually visible and thick)
    for i = 1, self.TotalNodes - 1 do
        local a, b = positions[i], positions[i + 1]

        -- Thicker line = draw multiple parallel lines
        surface.SetDrawColor(80, 80, 80, 255)
        for t = -math.floor(lineThickness / 2), math.floor(lineThickness / 2) do
            surface.DrawLine(a.x, a.y + t, b.x, b.y + t)
        end
    end

    -- Draw nodes
    for i = 1, self.TotalNodes do
        local node = self.Nodes[i]
        local x, y = positions[i].x, positions[i].y
        local col = Color(40, 40, 40, 255)
        local nodeSize = size / 2
        if node.Completed then
            col = Color(100, 200, 100, 255)
        elseif i == self.CurrentNode then
            col = Color(255, 180, 50, 255)
            nodeSize = nodeSize + math.sin(CurTime() * bounceSpeed) * bounceAmplitude
        end

        draw.NoTexture()
        surface.SetDrawColor(col)
        DrawCircleFilled(x, y, nodeSize, col)

        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawCircle(x, y, nodeSize + 1)

        -- Draw sequence for current node
        if i == self.CurrentNode then
            local seq = node.Sequence
            local total = #seq
            local miniSize = size * 1.1
            local startX = w / 2 - ((total * miniSize + (total - 1) * 4) / 2)
            local offsetY = h * 0.8 - miniSize / 2

            for j, dir in ipairs(seq) do
                local mat = arrowIcons[dir]
                surface.SetMaterial(mat)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(startX + (j - 1) * (miniSize + 4), offsetY, miniSize, miniSize)
                if j < node.Progress then
                    surface.SetDrawColor(0, 255, 0, 80)
                    surface.DrawRect(startX + (j - 1) * (miniSize + 4), offsetY, miniSize, miniSize)
                end
            end
        end
    end
end

vgui.Register("HackMinigame_sequence", PANEL, "DPanel")

ZKSlicerFramework.Minigames.Register("sequence", {
    Name = "Sequence Pattern",
    Description = "Follow the arrow pattern.",
    PanelClass = "HackMinigame_sequence"
})