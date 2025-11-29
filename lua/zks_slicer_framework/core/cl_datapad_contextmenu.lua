-- ====================================================================================
-- Datapad C-Menu Icon System (uses Sandbox DIconLayout method)
-- ====================================================================================

local hasDatapad = false

-- net message updates “hasDatapad”
timer.Simple(1, function()
    net.Receive(ZKSlicerFramework.NetUtils.UpdateDatapadState, function()
        hasDatapad = net.ReadBool()
        hook.Run("ZKSF_DatapadStateUpdated")
    end)
end)


-- ---------------------------------------------------------
-- FIND THE DIconLayout INSIDE THE CONTEXT MENU
-- ---------------------------------------------------------
local function GetContextMenuIconLayout()
    if not IsValid(g_ContextMenu) then return end

    for i = 0, g_ContextMenu:ChildCount() - 1 do
        local child = g_ContextMenu:GetChild(i)

        if IsValid(child) and child:GetName() == "DIconLayout" then
            return child
        end
    end
end


-- ---------------------------------------------------------
-- CREATE THE ICON
-- ---------------------------------------------------------
local function CreateDatapadButton(iconLayout)
    if not IsValid(iconLayout) then return end

    local icon = iconLayout:Add("DButton")
    icon:SetSize(70, 70)
    icon:SetText("")  -- icon only

    icon.Paint = function(s, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Material("vgui/datapad.png"))
        surface.DrawTexturedRect(16, 16, w - 16, h - 16 - 8)
        
        -- Draw text
        draw.SimpleTextOutlined(
            "Datapad",
            "Trebuchet18",
            w / 2 + 16/2,
            h - 4,
            Color(255,255,255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER,
            .8,
            Color(0, 0, 0)
        )
    end

    icon.DoClick = function()
        RunConsoleCommand("say", "!dropdatapad")
    end

    icon:SetName("ZKSF_DatapadIcon")
end


-- ---------------------------------------------------------
-- REMOVE THE ICON
-- ---------------------------------------------------------
local function RemoveDatapadButton(iconLayout)
    if not IsValid(iconLayout) then return end

    for i = 0, iconLayout:ChildCount() - 1 do
        local child = iconLayout:GetChild(i)

        if IsValid(child) and child:GetName() == "ZKSF_DatapadIcon" then
            child:Remove()
        end
    end
end


-- ---------------------------------------------------------
-- UPDATE THE C-MENU ON OPEN
-- ---------------------------------------------------------
hook.Add("OnContextMenuOpen", "ZKSF_ContextMenuDatapad", function()
    local layout = GetContextMenuIconLayout()
    if not IsValid(layout) then return end

    if hasDatapad then
        CreateDatapadButton(layout)
    else
        RemoveDatapadButton(layout)
    end

    layout:InvalidateLayout(true)
end)


-- remove the icon when C closes
hook.Add("OnContextMenuClose", "ZKSF_ContextMenuDatapad_Cleanup", function()
    local layout = GetContextMenuIconLayout()
    if not IsValid(layout) then return end

    RemoveDatapadButton(layout)
end)


-- react when server updates datapad state
hook.Add("ZKSF_DatapadStateUpdated", "ZKSF_RebuildContextMenu", function()
    if g_ContextMenu and g_ContextMenu:IsVisible() then
        hook.Run("OnContextMenuClose")
        hook.Run("OnContextMenuOpen")
    end
end)
