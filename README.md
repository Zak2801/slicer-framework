# ZK’s Slicer Framework — Advanced Hacking & Interaction System

A modular, extensible hacking + interaction system for Garry’s Mod servers.  
Turn ordinary props and entities into immersive, hackable gameplay elements with configurable difficulty, minigames, and logic linking.

> ⚠ **BETA NOTICE**  
> This framework is currently in active development. Expect occasional bugs or experimental features.  
> Please report issues or suggest improvements!

---

## ✨ Features

### 🔐 Hackable Entities

- Supports multiple hacking minigames
- Difficulty scaling (tiers + manual tuning)
- Adjustable timers and dynamic challenge options
- Planned: additional minigames and expanded logic

### 🛠️ Admin Configuration Panel

- Configure hacking difficulty and time per entity
- Choose Tier 1–3 presets or fine-tune manually
- Change entity model directly via the **Q-menu → Options** panel

### 🔗 Link Tool

- Create logic connections between controllers and target props
- Visualize existing links in real time
- Remove or reassign connections instantly

### 🎨 Custom VGUI System

- Themed UI for hacking minigames and configuration
- Clean, expandable panel structure

### 🧩 Modular Design

- Built to integrate with:
  - StarWarsRP
  - DarkRP
  - Sandbox
  - Custom gamemodes
- Easy to extend with custom hackable entities or minigames

---

## 🧰 Included Tools

- **Hackable Link Toolgun** — connect controllers to entities
- **Entity Config Tool** — adjust hacking parameters & difficulty
- **Hacking Interface** — immersive minigame popup

---

## 🎮 Use Cases

- Create mission objectives requiring hacking
- Add interactive gameplay depth to RP, PvE, or event systems
- Tie hacking into puzzles, doors, consoles, and scripted sequences
- Build full hacking-based progression systems

---

## 📦 Installation

1. Place the addon into `garrysmod/addons/`
2. Restart the server
3. Configure models, permissions, and defaults:
   - **Q-Menu → Options → ZK’s Slicer Framework**

---

## 📝 Developer Information

Developers can:

- Create new hackable entity types
- Extend the hacking UI and minigames
- Use hooks to react to:
  - OnHackStart
  - OnHackSuccess
  - OnHackFailed
  - OnLinkCreated / OnLinkRemoved

Documentation is available inside the **docs/** folder.

---

## 📄 License

This project uses a **Custom Server-Use License**:

- ✔ You **may modify** the addon to use on your own server
- ❌ You **may NOT redistribute** modified versions
- ✔ You may share unmodified versions (linking to the original repo/workshop)

See **LICENSE.txt** for full terms.

---

## 🤝 Contributing

Bug reports, feature suggestions, and improvements are welcome.  
Please open an issue or contact me directly.
