# Developer API Documentation

**ZK's Slicer Framework** is designed to be easily extensible. You can create custom hackable entities, add new minigames, and listen for hacking events using the provided hooks.

## 1. Hackable Entities

To create a new hackable entity, inherit from `sf_base_entity`.

```lua
AddCSLuaFile()

DEFINE_BASECLASS("sf_base_entity")

ENT.Type = "anim"
ENT.Base = "sf_base_entity"
ENT.PrintName = "My Custom Database"
ENT.Author = "You"
ENT.Category = "ZK's Slicer Framework"
ENT.Spawnable = true

if CLIENT then
    -- Optional: Set a specific display type for the 3D2D UI
    function ENT:Initialize()
        self:SetEType("Server") 
    end
end

if SERVER then
    function ENT:Initialize()
        BaseClass.Initialize(self)
        self:SetModel("models/props_combine/combine_interface001.mdl")
        -- Default settings
        self:SetDifficulty(2) 
        self:SetHackTime(15) 
    end

    -- Called when the hack is successfully completed
    function ENT:OnHackSuccess(ply)
        BaseClass.OnHackSuccess(self, ply)
        -- Custom logic here, e.g., give money, open a door, etc.
        ply:ChatPrint("You accessed the mainframe!")
        
        -- Example: Give an item
        -- ply:Give("weapon_crowbar")
    end

    -- Called when the hack fails (timer runs out or wrong input)
    function ENT:OnHackFailed(ply)
        BaseClass.OnHackFailed(self, ply)
        -- Custom logic here, e.g., sound alarm, damage player
        self:EmitSound("ambient/alarms/klaxon1.wav")
    end
    
    -- Optional: Custom hack conditions
    function ENT:CanHack(ply)
        if not BaseClass.CanHack(self, ply) then return false end
        -- Add extra checks here
        return true
    end
end
```

### Networked Variables (State)
The base entity uses several NetworkVars that you can access:
*   `Difficulty` (Int): 1-5, determines minigame complexity.
*   `HackTime` (Int): Seconds allowed to complete the hack.
*   `IsBeingHacked` (Bool): Current state.
*   `IsCompleted` (Bool): If the entity has been successfully hacked.
*   `IsDisabled` (Bool): If the entity is locked/unusable.
*   `LinkedEntity` (String): The ID/Name of a linked target entity.
*   `EType` (String): Display text for the UI (e.g., "Database", "Terminal").

---

## 2. Minigame Registry

You can register custom minigames that will appear in the framework.

### Step 1: Create the VGUI Panel
Create a VGUI panel that handles the minigame logic.

```lua
local PANEL = {}

function PANEL:Init()
    -- UI Setup
end

-- Required: Called by the framework to inject dependencies
function PANEL:SetParentFrame(frame) self.ParentFrame = frame end
function PANEL:SetHackTime(time) self.HackTime = time end
function PANEL:SetEntity(ent) self.Entity = ent end

-- Required: Setup the game based on difficulty (1-5)
function PANEL:SetDifficulty(difficulty)
    self.Difficulty = difficulty
    -- Generate puzzle...
end

-- Call this when the game is finished
-- result (bool): true for success, false for failure
function PANEL:ReportResult(result)
    -- This function is injected by the parent frame (cl_hacking.lua)
    -- You just need to call it when your game logic determines a win/loss.
    -- However, for safety, check if it exists or if the parent has it.
    -- The standard pattern in included minigames is:
    if self.ReportResultFunc then -- You might need to store the injected function if passed differently, 
                                  -- but standard usage relies on the parent checking the callback.
                                  -- WAIT: In the actual code, the parent assigns PANEL.ReportResult = function(bool) ...
                                  -- So you simply call:
         self:ReportResult(result) 
    end
end
```
*Note: The parent frame (`cl_hacking.lua`) assigns a `ReportResult` function to your panel instance. You must call `self:ReportResult(true)` on success or `self:ReportResult(false)` on failure.*

### Step 2: Register the Minigame
Use `ZKSlicerFramework.Minigames.Register` in a shared file (or client file).

```lua
ZKSlicerFramework.Minigames.Register("my_custom_game", {
    Name = "Memory Match",
    Description = "Match the pairs of symbols.",
    PanelClass = "HackMinigame_Memory" -- The VGUI class name you registered above
})
```

---

## 3. Hooks

The framework provides server-side hooks for global event listening.

| Hook Name | Arguments | Description |
| :--- | :--- | :--- |
| `ZKSF_OnStartHack` | `entity`, `player` | Called when a player begins hacking an entity. |
| `ZKSF_OnHackSuccess` | `entity`, `player` | Called immediately after a successful hack. |
| `ZKSF_OnHackFailed` | `entity`, `player` | Called when a hack fails. |

**Example:**
```lua
hook.Add("ZKSF_OnHackSuccess", "GlobalHackLogger", function(ent, ply)
    print(ply:Nick() .. " hacked " .. tostring(ent) .. "!")
end)
```

---

## 4. Networking Utilities

The framework uses a central table for network string names to ensure consistency.
Access them via `ZKSlicerFramework.NetUtils`.

*   `ZKSlicerFramework.NetUtils.OpenHackInterface`
*   `ZKSlicerFramework.NetUtils.OpenConfigInterface`
*   `ZKSlicerFramework.NetUtils.SyncEntConfig`
*   `ZKSlicerFramework.NetUtils.SendHackResult`

---

## 5. Configuration & Permissions

Admins can configure entities in-game. To control who can access these settings, you can override `ZKSlicerFramework.CanConfigure(ply)`.

*Currently, this defaults to Super Admins.*