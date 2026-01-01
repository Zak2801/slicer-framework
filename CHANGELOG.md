# Changelog

## [Framework Update] - Minigame Registry & Hooks

### Added
- **Minigame Registry (`sh_minigame_registry.lua`)**: A new shared module to register and manage minigames dynamically.
- **Hooks**:
    - `ZKSF_OnStartHack(entity, ply)`
    - `ZKSF_OnHackSuccess(entity, ply)`
    - `ZKSF_OnHackFailed(entity, ply)`
    - These hooks are now triggered by the base entity, allowing global event handling for all framework entities.

### Changed
- **Minigame Loading**: `sf_controller_entity` now dynamically loads all registered minigames instead of using a hardcoded list.
- **UI Logic**: `cl_hacking.lua` now queries the registry to find the correct VGUI panel for a minigame type.
- **Entity Validation**: `sv_net_manager.lua` now uses a robust `ent.IsZKSlicerEntity` check instead of fragile class name string matching.
- **Minigame Files**: All minigame files (`cl_cipher_minigame`, `cl_frequency_minigame`, etc.) now register themselves with `ZKSlicerFramework.Minigames.Register`.

### Developer Notes
- To add a new minigame, simply create the client-side file and call `ZKSlicerFramework.Minigames.Register("my_game", { ... })` at the bottom. No other file edits are needed.
- Custom entities should inherit from `sf_base_entity` to automatically get the `IsZKSlicerEntity` property and hook integration.
