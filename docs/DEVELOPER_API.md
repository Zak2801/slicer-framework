# 📘 ZK's Slicer Framework — Developer API Documentation

**Version:** 1.0  
**Author:** Zaktak  
**Audience:** Developers integrating their own hacking entities, datapads, minigames, or permission systems.

---

# Overview

ZK’s Slicer Framework provides a modular hacking system that other addons can hook into.  
This document describes the APIs, hooks, entity extension points, network messages, and optional integrations.

---

# Hook Reference

These hooks allow third-party addons to react to hacking events.

---

## `ZKSF_StartHack`

**Called when any Slicer Framework entity begins a hack attempt.**

```lua
hook.Add("ZKSF_StartHack", "MyAddon_ListenStart", function(ent, ply)
    -- ent : sf_base_entity or derived entity
    -- ply : Player starting the hack
end)
```

Arguments
| Name | Type | Description |
| ---- | ------ | -------------------------- |
| ent | Entity | The entity being hacked |
| ply | Player | Player who started hacking |

## `ZKSF_HackSuccess`

**Called when a hack completes successfully (Called before linked entites are removed).**

```lua
hook.Add("ZKSF_HackSuccess", "MyAddon_ListenStart", function(ent, ply, tblEnts)
    -- ent : sf_base_entity or derived entity
    -- ply : Player starting the hack
end)
```

Arguments
| Name | Type | Description |
| ---- | ------ | -------------------------- |
| ent | Entity | The entity being hacked |
| ply | Player | Player who started hacking |
| tblEnts | table or nil | table with the Datapad or Linked Entites or nil (before removal) |

## `ZKSF_HackFailed`

**Called when a hack fails.**

```lua
hook.Add("ZKSF_HackFailed", "MyAddon_ListenStart", function(ent, ply, linkedEnts)
    -- ent : sf_base_entity or derived entity
    -- ply : Player starting the hack
end)
```

Arguments
| Name | Type | Description |
| ---- | ------ | -------------------------- |
| ent | Entity | The entity being hacked |
| ply | Player | Player who started hacking |

# Extending Hackable Entities

Creating your own hackable entity is easy.
Simply inherit from sf_base_entity:

DEFINE_BASECLASS("sf_base_entity")

ENT.Type = "anim"
ENT.Base = "sf_base_entity"
ENT.PrintName = "My Custom Hackable"

## `ENT:CanHack(ply)`

Called before hacking begins.
Return false to block the hack.

function ENT:CanHack(ply)
if not BaseClass.CanHack(self, ply) then return false end
return ply:IsSuperAdmin()
end

## `ENT:OnHackSuccess(ply)`

Called when the hack finished successfully.

function ENT:OnHackSuccess(ply)
print("Hack Complete!", ply)
end

## `ENT:OnHackFailed(ply)`

Called when the hack fails.

function ENT:OnHackFailed(ply)
print("Hack failed!", ply)
end

## `ENT:OpenConfigMenu(ply)`

Called when an admin tries to open the config panel on the entity
(usually reload + use or right-click in your tools)

function ENT:OpenConfigMenu(ply)
-- open your custom VGUI
end

# Network Messages

You may send framework UI panels using:

Identifier Purpose
ZKSF.OpenHackInterface Opens the hacking UI
ZKSF.OpenConfigInterface Opens the admin config UI

Example:

net.Start(ZKSlicerFramework.NetUtils.OpenHackInterface)
net.WriteEntity(self)
net.Send(ply)

# Permission API

Check whether a player can configure Slicer entities:

if ZKSlicerFramework.CanConfigure(ply) then
-- allow configuration
end
