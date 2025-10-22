<!-- Banner -->
<p align="center">
  <img src="https://cdn.discordapp.com/attachments/1426848169567719455/1430210420523425822/liquid_container_banner.png" alt="Liquid Container Wars Banner" width="720"/>
</p>

<h1 align="center">📦 Liquid Container Wars | FiveM Script</h1>

<p align="center">
  <a href="https://docs.qbcore.org/"><img src="https://img.shields.io/badge/Framework-QBCore%20%7C%20ESX-blue?style=for-the-badge"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"></a>
  <img src="https://img.shields.io/badge/Status-Stable-success?style=for-the-badge">
  <img src="https://img.shields.io/badge/Language-Lua-orange?style=for-the-badge">
</p>

<p align="center">
  Dynamic PVP event system where players and gangs fight for control of <b>Merryweather</b> supply containers.<br>
  Featuring AI guards, randomized rewards, and a dark-tech themed <b>laptop interface</b> to start wars.
</p>

## ✨ Features

- ✅ **Fully Synced Global Container**
  - Only one container spawns globally (server-side)
  - All players see the same object and event  
- 🔫 **Dynamic NPC Guards**
  - Customizable Merryweather AI that attacks all players
  - Configurable weapons, accuracy, and health  
- 💰 **Smart Reward System**
  - Randomized cash & item rewards (server-side only, anti-exploit)
  - Adjustable drop chances & amounts in `Config.Reward`  
- 💻 **Laptop NUI Interface**
  - Dark-themed “Merry Weather Servers” UI
  - Randomized war zone selection and reward preview  
- 🎯 **qb-target Integration**
  - Interact directly with the container using `qb-target`
- 🧠 **Optimized & Secure**
  - Anti-spam cooldowns, entity sync protection
  - Event-safe cleanup and resource shutdown handling


## ⚙️ Installation

### 1. Download or Clone

```bash
git clone https://github.com/nm1-Dev/liquid_container.git
````

Place the folder inside your server’s `resources/[liquid]` directory:

```
resources/[liquid]/liquid_container
```

---

### 2. Add to Server Config

```cfg
ensure liquid_container
```

---

### 3. Configure Settings

Edit your `config.lua` file:

```lua
Config.Container.Model = "prop_container_01a"
Config.Container.Locations = {
    [1] = {
        id = 1,
        name = "Merryweather Dock",
        coord = vector4(2223.769, 5604.547, 54.719, 108.38),
        radius = 150.0,
        showBlip = true,
        npc = {
            [1] = {
                pos = vector4(2223.769, 5604.547, 54.719, 108.38),
                ped = 'g_f_y_vagos_01',
                weapon = 'WEAPON_PISTOL_MK2',
                health = 3000,
                accuracy = 60,
                alertness = 3,
                aggressiveness = 3,
            },
        },
    },
}
```

---

### 4. Configure Rewards

```lua
Config.Reward = {
    items = {
        enabled = true,
        list = {
            { item = "pistol_ammo", chance = 100, amount = { min = 1, max = 1 } },
            { item = "sandwich", chance = 50, amount = { min = 1, max = 2 } },
        },
    },
    money = {
        enabled = true,
        type = "cash",
        min = 50,
        max = 200,
    },
}
```

---

## 💻 Usage

### 🧠 Start the Event via Laptop

Interact with the **Merryweather laptop** in-game:

> “Boot up System” → Randomize war zone → Start Container War
---

## 🔧 Dependencies

| Resource                                                                                                 | Description                |
| -------------------------------------------------------------------------------------------------------- | -------------------------- |
| [QBCore Framework](https://github.com/qbcore-framework) | Main framework             |
| [qb-target](https://github.com/qbcore-framework/qb-target)                                               | Container interaction      |
| [interact](https://github.com/)                                                                          | Laptop trigger interaction |
| [chat](https://docs.fivem.net/docs/resources/chat/)                                                      | For Merryweather alerts    |

---

## 🧠 How It Works

1. A player boots the laptop to start the event.
2. The server spawns a **global networked container** shared by all players.
3. **AI guards** spawn around it and attack anyone nearby.
4. The first player to open the container receives randomized rewards.
5. Once looted, the container can’t be reopened (safe cooldown).
---

## 🧑‍💻 Credits

* **Script developed by:** [Liquid Developments](https://liquid-devs.com)
* **Created & maintained by:** Nmsh
* **Tested & tuned by:** Liquid QA Team
* **Discord:** [Join our community](https://discord.gg/xkZ7GR5ge6)

---

## 📜 License

Released **under the MIT License** — free to use and modify with proper credit.

> © 2025 **Liquid Developments**
> All rights reserved. Redistribution without permission is prohibited.

---

## 🌐 Links

* 🛒 **Store:** [liquid-devs.com](https://liquid-devs.com)
* 💬 **Discord:** [discord.gg/xkZ7GR5ge6](https://discord.gg/xkZ7GR5ge6)
* 📦 **GitHub:** [github.com/nm1-Dev/liquid_container](https://github.com/nm1-Dev/liquid_container)

---

<p align="center">
  <sub>Made with ⚙️ and ❤️ by <b>Liquid Developments</b> | for FiveM RP servers.</sub>
</p>

---