--[[-------------------------------------------------------------------------
  lua\zks_slicer_framework\core\sh_minigame_registry.lua
  SHARED
  Registry for managing hackable minigames
---------------------------------------------------------------------------]]

ZKSlicerFramework = ZKSlicerFramework or {}
ZKSlicerFramework.Minigames = ZKSlicerFramework.Minigames or {}
ZKSlicerFramework.Minigames.Stored = {}

-----------------------------------------------------------------------------
-- Registers a new minigame
-- @param name string Unique identifier for the minigame (e.g., "cipher")
-- @param data table Table containing minigame definition
--    - PanelClass (string): Client VGUI class name
--    - Name (string): Display name
--    - Description (string): Short description
-----------------------------------------------------------------------------
function ZKSlicerFramework.Minigames.Register(name, data)
    if not name or not data then return end
    ZKSlicerFramework.Minigames.Stored[name] = data
    print("[ZKSlicerFramework] Registered minigame: " .. name)
end

-----------------------------------------------------------------------------
-- Retrieves a minigame definition
-- @param name string Unique identifier
-- @return table|nil The minigame data or nil if not found
-----------------------------------------------------------------------------
function ZKSlicerFramework.Minigames.Get(name)
    return ZKSlicerFramework.Minigames.Stored[name]
end

-----------------------------------------------------------------------------
-- Returns all registered minigames
-- @return table Table of minigame definitions
-----------------------------------------------------------------------------
function ZKSlicerFramework.Minigames.GetAll()
    return ZKSlicerFramework.Minigames.Stored
end

-----------------------------------------------------------------------------
-- Returns a list of all minigame IDs (keys)
-- @return table List of strings
-----------------------------------------------------------------------------
function ZKSlicerFramework.Minigames.GetKeys()
    local keys = {}
    for k, v in pairs(ZKSlicerFramework.Minigames.Stored) do
        table.insert(keys, k)
    end
    return keys
end
