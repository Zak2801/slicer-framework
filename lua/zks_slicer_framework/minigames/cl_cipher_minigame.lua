--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\minigames\cl_cipher_minigame.lua
  CLIENT
  Cipher minigame panel where users decode shifted text
---------------------------------------------------------------------------]]

local PANEL = {}

local wordPool = {
    "node","access","delta","omega","sector","vector","matrix",
    "ion","core","data","signal","pulse","system","shift","input"
}

-----------------------------------------------------------------------------
-- Shifts a character backwards by "shift" for decoding
-- @param ch string Character to shift
-- @param shift number Amount to shift
-- @return string Shifted character
-----------------------------------------------------------------------------
local function ShiftChar(ch, shift)
    local byte = string.byte(ch)
    if byte >= string.byte("a") and byte <= string.byte("z") then
        return string.char((byte - string.byte("a") - shift) % 26 + string.byte("a"))
    end
    return ch
end

-----------------------------------------------------------------------------
-- Decode an entire word using shift
-- @param encoded string The encoded word
-- @param shift number The shift amount
-- @return string Decoded word
-----------------------------------------------------------------------------
local function DecodeWord(encoded, shift)
    local decoded = ""
    for i = 1, #encoded do
        decoded = decoded .. ShiftChar(encoded:sub(i,i), shift)
    end
    return decoded
end

-----------------------------------------------------------------------------
-- Initialize the panel
-----------------------------------------------------------------------------
function PANEL:Init()
    self:SetKeyboardInputEnabled(true)
    self:SetMouseInputEnabled(false)
    self:SetFocusTopLevel(true)
    self:RequestFocus()

    self.Completed = false
    self.ResultReported = false
    self.InputText = ""

    -- Map keys A-Z
    self.LetterMap = {}
    for i = 0, 25 do
        self.LetterMap[KEY_A + i] = string.char(string.byte("a") + i)
    end

    self.Label = vgui.Create("DLabel", self)
    self.Label:SetText("DECODE THE CIPHER")
    self.Label:SetFont("ZKSlicerFramework.UI.PrimarySmall")
    self.Label:SetContentAlignment(5)
    self.Label:Dock(TOP)
    self.Label:DockMargin(0, 6, 0, 6)
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
end

-----------------------------------------------------------------------------
-- Set the target entity
-- @param ent Entity The hackable entity
-----------------------------------------------------------------------------
function PANEL:SetEntity(ent)
    self.ent = ent
end

-----------------------------------------------------------------------------
-- Set the difficulty level and generate the puzzle
-- @param d number Difficulty level
-----------------------------------------------------------------------------
function PANEL:SetDifficulty(d)
    self.difficulty = d or 1
    local minLen = math.Clamp(3 + d, 4, 10)
    local valid = {}
    for _, w in ipairs(wordPool) do
        if #w >= minLen then table.insert(valid, w) end
    end

    -- Choose word and shift
    self.Word = string.lower(valid[math.random(#valid)] or "data")
    self.Shift = math.random(3,12)
    self.Encoded = DecodeWord(self.Word, self.Shift) -- encoded by shifting backwards
end

-----------------------------------------------------------------------------
-- Handle key presses
-- @param key number Key code
-----------------------------------------------------------------------------
function PANEL:OnKeyCodePressed(key)
    if self.Completed or self.ResultReported then return end

    if key == KEY_BACKSPACE then
        self.InputText = self.InputText:sub(1,#self.InputText-1)
        return
    end

    if key == KEY_ENTER or key == KEY_PAD_ENTER then
        self:CheckSubmission()
        return
    end

    local ch = self.LetterMap[key]
    if ch then
        self.InputText = self.InputText .. ch
    end
end

-----------------------------------------------------------------------------
-- Validate the user's input
-----------------------------------------------------------------------------
function PANEL:CheckSubmission()
    if self.InputText == self.Word then
        self.Completed = true
        surface.PlaySound("buttons/button9.wav")

        local popup = vgui.Create("HackPopup")
        popup:SetHeaderTitle("SUCCESS")
        popup:SetText("Cipher decoded!")
        popup:SetAcceptButton("Continue", function()
            if self.ReportResult then
                self:ReportResult(true)
                self.ResultReported = true
            end
        end)
        if popup.DeclineButton then popup.DeclineButton:Remove() end
    else
        self.InputText = ""
        surface.PlaySound("buttons/button10.wav")
    end
end

-----------------------------------------------------------------------------
-- Helper to draw centered text
-- @param text string Text to draw
-- @param font string Font name
-- @param x number X coordinate
-- @param y number Y coordinate
-- @param col Color Text color
-----------------------------------------------------------------------------
local function DrawCenteredText(text, font, x, y, col)
    draw.SimpleText(text, font, x, y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-----------------------------------------------------------------------------
-- Paint the minigame
-- @param w number Width
-- @param h number Height
-----------------------------------------------------------------------------
function PANEL:Paint(w,h)
    surface.SetDrawColor(25,40,60,200)
    surface.DrawRect(0,0,w,h)

    local centerY = h * 0.35

    DrawCenteredText("CIPHER (Shift "..self.Shift.."):", "ZKSlicerFramework.UI.PrimarySmall", w/2, centerY - 60, Color(200,200,200))
    DrawCenteredText(string.upper(self.Encoded) or "-----", "ZKSlicerFramework.UI.Primary", w/2, centerY - 20, Color(255,180,50))

    DrawCenteredText("DECODE:", "ZKSlicerFramework.UI.PrimarySmall", w/2, centerY + 30, Color(200,200,200))

    local col = Color(230,230,230)
    if self.InputText ~= "" then
        if self.Word:sub(1,#self.InputText) ~= self.InputText then
            col = Color(255,100,100)
        end
    end

    DrawCenteredText(self.InputText == "" and "_" or string.upper(self.InputText), "ZKSlicerFramework.UI.Primary", w/2, centerY + 70, col)
    DrawCenteredText("[ENTER] Submit   |   [BACKSPACE] Delete", "ZKSlicerFramework.UI.SecondarySmall", w/2, h-30, Color(160,160,160))
end

vgui.Register("HackMinigame_cipher", PANEL, "DPanel")