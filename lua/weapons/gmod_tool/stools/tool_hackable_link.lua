-- =====================================================================================
-- Tool Information
-- =====================================================================================
TOOL.Category = "ZK's Slicer Framework"
TOOL.Name = "Hackable Link Tool"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
}

-- Localization
if CLIENT then
    language.Add("tool.tool_hackable_link.name", "Setup Hackable Link")
    language.Add("tool.tool_hackable_link.desc", "Tool for linking hackable controllers to devices.")
    language.Add("tool.tool_hackable_link.left", "Link/Unlink Controller")
    language.Add("tool.tool_hackable_link.right", "Link/Unlink Prop")
end

-- =====================================================================================
-- Shared Framework Table
-- =====================================================================================
ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.NetUtils = ZKSlicerFramework.NetUtils or {}
ZKSlicerFramework.Functions = ZKSlicerFramework.Functions or {}

local MAX_JSON_LEN = 512

-- =====================================================================================
-- Helper functions
-- =====================================================================================
local function IsController(ent)
    if not IsValid(ent) then return false end
    return ent.BaseClass and ent.BaseClass.ClassName == "sf_base_entity"
end

local function GetLinkedEntities(ent)
    local data = ent:GetLinkedEntity() and ent:GetLinkedEntity() or "[]"
    local ok, tbl = pcall(util.JSONToTable, data)
    if ok and istable(tbl) then return tbl end
    return {}
end

local function SetLinkedEntities(ent, tbl)
    local json = util.TableToJSON(tbl or {})
    if #json > MAX_JSON_LEN then
        print("[LinkTool] WARNING: Linked entity data exceeds 512 chars! Truncating.")
        json = string.sub(json, 1, MAX_JSON_LEN)
    end
    ent:SetLinkedEntity(json)
end

local function FindEntityByCreationID(id)
    for _, ent in ipairs(ents.GetAll()) do
        if ent:GetCreationID() == id then
            return ent
        end
    end
    return nil
end

-- =====================================================================================
-- Cached lookup system for linked entities
-- =====================================================================================
local LinkedCache = {}

function ZKSlicerFramework.Functions.UpdateLinkedCache(controller, linkedIDs)
    if not IsValid(controller) then return end
    LinkedCache[controller] = {}

    for _, id in ipairs(linkedIDs) do
        for _, ent in ipairs(ents.FindByClass("*")) do
            if ent:GetCreationID() == id then
                table.insert(LinkedCache[controller], ent)
                break
            end
        end
    end
end

hook.Add("EntityRemoved", "ZKSlicer_LinkCacheCleaner", function(ent)
    if SERVER then return end
    for ctrl, entsTbl in pairs(LinkedCache) do
        for i, linkedEnt in ipairs(entsTbl) do
            if linkedEnt == ent then
                table.remove(entsTbl, i)
                break
            end
        end
    end
end)

-- =====================================================================================
-- TOOL LOGIC
-- =====================================================================================

function TOOL:Deploy()
    self.Controller = nil
end

------------------------------------------------------------------------------------
-- LEFT CLICK → Select controller
------------------------------------------------------------------------------------
function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not IsValid(ent) or not IsController(ent) then return false end

    self.Controller = ent
    if CLIENT then
        notification.AddLegacy("Selected controller: " .. tostring(ent:GetClass()), NOTIFY_GENERIC, 3)
        surface.PlaySound("buttons/button14.wav")
    end

    return true
end

------------------------------------------------------------------------------------
-- RIGHT CLICK → Link/unlink target
------------------------------------------------------------------------------------
function TOOL:RightClick(trace)
    local ent = trace.Entity
    if !IsValid(ent) or !self.Controller or ent == self.Controller then return false end
    if !IsValid(self.Controller) then return false end

    local linked = GetLinkedEntities(self.Controller)
    local idx = table.KeyFromValue(linked, ent:GetCreationID())

    if idx then
        -- unlink
        if IsController(ent) then
            ent:SetIsDisabled(false)
        end
        table.remove(linked, idx)
        if CLIENT then
            notification.AddLegacy("Unlinked entity: " .. tostring(ent:GetClass()), NOTIFY_ERROR, 2)
            surface.PlaySound("buttons/button10.wav")
        end
    else
        -- link
        if IsController(ent) then
            ent:SetIsDisabled(true)
        end
        table.insert(linked, ent:GetCreationID())
        if CLIENT then
            notification.AddLegacy("Linked entity: " .. tostring(ent:GetClass()), NOTIFY_HINT, 2)
            surface.PlaySound("buttons/button15.wav")
        end
    end

    if SERVER then
        SetLinkedEntities(self.Controller, linked)
    else
        ZKSlicerFramework.Functions.UpdateLinkedCache(self.Controller, linked)
    end

    return true
end

------------------------------------------------------------------------------------
-- DRAW HUD / BEAMS
------------------------------------------------------------------------------------
function TOOL:DrawHUD()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    local tr = ply:GetEyeTrace()

    cam.Start3D(EyePos(), EyeAngles())
        render.SetColorMaterial()

        -- draw current aim marker
        render.DrawSphere(tr.HitPos, 2, 8, 8, Color(0, 255, 0, 80))

        if IsValid(self.Controller) then
        local cpos = self.Controller:GetPos()
        render.DrawSphere(cpos, 4, 8, 8, Color(255, 255, 100, 100))

        local linked = LinkedCache[self.Controller]
        if linked then
            for _, target in ipairs(linked) do
                if IsValid(target) then
                    local color = Color(80, 160, 255, 180)
                    render.DrawBeam(cpos, target:GetPos(), 3, 0, 1, color)
                    render.DrawSphere(target:GetPos(), 3, 8, 8, Color(80, 160, 255, 100))
                end
            end
        end
    end
    cam.End3D()
end

------------------------------------------------------------------------------------
-- TOOL SCREEN UI
------------------------------------------------------------------------------------
function TOOL:DrawToolScreen(width, height)
	surface.SetDrawColor(Color(15, 40, 15))
	surface.DrawRect(0, 0, width, height)

	draw.SimpleText("Hackable Link Tool", "DermaLarge", width/2, height/8, Color(200,200,200), TEXT_ALIGN_CENTER)

	local ctrl = self.Controller
	if IsValid(ctrl) then
		draw.SimpleText("Controller: " .. ctrl:GetClass(), "DermaDefault", width/2, height/3, Color(150,255,150), TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("No controller selected", "DermaDefault", width/2, height/3, Color(255,150,150), TEXT_ALIGN_CENTER)
	end

	draw.SimpleText("Left-click: Select Controller", "DermaDefault", width/2, height * 0.65, Color(200,200,200), TEXT_ALIGN_CENTER)
	draw.SimpleText("Right-click: Link / Unlink Prop", "DermaDefault", width/2, height * 0.75, Color(200,200,200), TEXT_ALIGN_CENTER)
end
