# ZK's Slicer Framework

A modular, extensible hacking and interaction system for Garry's Mod. Turn ordinary props into immersive gameplay elements with configurable minigames, difficulty scaling, and logic linking.

## ✨ Features

- **Hackable Entities:** Pre-configured entities like Datapads, Controllers, and Databases.
- **Minigame System:** Includes immersive hacking minigames (e.g., Cipher) with difficulty scaling.
- **Admin Configuration:** In-game configuration panel for every entity. Adjust hack time, difficulty, and visual models on the fly.
- **Logic Linking:** Use the **Hackable Link Tool** to connect "Controller" entities to other objects (like doors or lights) to trigger actions upon a successful hack.
- **Developer Friendly:** Easy to extend with new entities and custom minigames using a standardized API.

## 📦 Installation

1.  Download the addon.
2.  Extract the `zks_slicer_framework` folder into your server's `garrysmod/addons/` directory.
3.  Restart the server.

## 🎮 Usage

### For Players

1.  Equip the **Slicer** weapon (found under Weapons > ZK's Slicer Framework).
2.  Approach a hackable entity (e.g., a Datapad or Database).
3.  Press **Primary Fire** (Left Click) or **Use** (E) to begin the hack.
4.  Complete the minigame before the timer runs out.

### For Admins

- **Configuration:** Press `Use` (Without the "Slicer" in hand) on any Slicer Framework entity to open the configuration menu. You can change the difficulty, hack duration, and even the entity's model (via Q menu).
- **Linking:** Use the **Hackable Link Tool** (Tools > ZK's Slicer Framework) to connect a Controller entity to a target.
  1.  Left-click the **Controller**.
  2.  Left-click the **Target** (e.g., a fading door button or light).
  3.  When the Controller is hacked, it will interact with the Target.

## 🛠️ Developer Documentation

Full developer documentation, including how to create custom entities and register new minigames, can be found in [docs/DEVELOPER_API.md](docs/DEVELOPER_API.md).

## 📄 License

This project is licensed for use on your own servers.

- **You may:** Modify the code for your specific server needs.
- **You may not:** Redistribute this addon or modified versions of it as your own work.

See `LICENSE.txt` for details.
