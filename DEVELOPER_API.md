# 📘 ZK's Slicer Framework — Developer API Documentation

**Version:** 1.0  
**Author:** Zaktak  
**Audience:** Developers integrating their own hacking entities, datapads, minigames, or permission systems.

---

# 📂 Overview

ZK’s Slicer Framework provides a modular hacking system that other addons can hook into.  
This document describes the APIs, hooks, entity extension points, network messages, and optional integrations.

---

# 🔌 1. Hook Reference

These hooks allow third-party addons to react to hacking events.

---

## 🔵 `ZKSF_StartHack`

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

## 🔵 `ZKSF_HackSuccess`

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

## 🔵 `ZKSF_HackFailed`

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
