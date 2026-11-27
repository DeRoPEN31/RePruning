# RePruning

![Version](https://img.shields.io/badge/version-0.0.5-blue)
![Game](https://img.shields.io/badge/game-Counter--Strike%201.6-orange)
![Platform](https://img.shields.io/badge/platform-ReAPI%20%7C%20ReHLDS%20%7C%20ReGameDLL-informational)
![License](https://img.shields.io/badge/license-MIT-green)

A plugin for removing, cleaning up, or disabling various features on Counter-Strike 1.6 servers.
Instead of shipping a separate plugin for every small change, RePruning gives server owners a
single config where every feature is its own `0/1` switch — nothing in the game DLLs has to be
modified.

> **Reminder:** use `0` to disable the feature and `1` to enable it.

## Features

- **Buying & money** — block buying, remove buy zones, hide money
- **Bomb & plant zones** — remove bomb spots and C4 entities
- **HUD icons** — hide bomb, buy zone, defuse kit, flashlight and night vision icons
- **Radio & sounds** — block the radio menu and voice lines, optionally keep round-win sounds
- **Hostages & VIP** — remove hostages, disable VIP logic
- **Effects & decals** — hide blood, impact smoke, sparks, debris and wall decals
- **Corpses** — hide dead bodies
- **Dropped weapons** — clean up dropped guns and defuse kits
- **Console & hints** — silence noisy console messages and HUD hint popups
- **File checks** — verify client files by MD5 against a server-side list, with kicks and temporary bans
- **Autonomous ban list** — bans expire on their own, entries are cleaned up automatically
- **Game modes** — apply a ready preset for ZM, DeathRun, CSDM, DM, Pub or Lasers with one cvar
- **Localization** — nine languages for every message the plugin sends
- **Public API** — natives and forwards so other plugins can read the state and manage bans

## Requirements

| Component    | Version            | Required |
| :----------- | :----------------- | :------: |
| AMX Mod X    | 1.10+              |    yes   |
| Metamod-r    | 1.3.0.149          |    yes   |
| ReHLDS       | 3.15.0.896-dev     |    yes   |
| ReGameDLL    | 5.30.0.814-dev     |    yes   |
| ReAPI        | 5.29.0.359-dev     |    yes   |

The plugin targets the Re* stack — ReHLDS with ReGameDLL and ReAPI. It works through ReAPI
hooks and does not initialise on a stock engine.

## Download

- [Releases](https://github.com/DeRoPEN31/RePruning/releases) — the latest build
- [dev.deropen.fun](https://dev.deropen.fun) — the project website with all plugins

## Installation

1. Download the latest build from [Releases](https://github.com/DeRoPEN31/RePruning/releases)
   or from [dev.deropen.fun](https://dev.deropen.fun). The archive contains:

   ```
   addons/amxmodx/plugins/repruning.amxx             # core plugin — the only required one
   addons/amxmodx/plugins/pruning_mode_settings.amxx # mode presets (optional)
   addons/amxmodx/plugins/pruning_info.amxx          # status report command (optional)
   addons/amxmodx/configs/pruning.cfg                # main configuration
   addons/amxmodx/configs/pruning_baning.cfg         # file checks and ban system
   addons/amxmodx/configs/pruning_files.cfg          # list of client files for the MD5 check
   addons/amxmodx/configs/pruning_mode_settings.cfg  # active mode selector
   addons/amxmodx/configs/pruning_mode_*.cfg         # mode presets
   addons/amxmodx/data/repruning/<lang>/             # language files, one folder per language
   source/                                           # plugin source — not needed on the server
   ```

2. Unpack the archive — it contains the `RePruning_v0.0.5/` folder — and copy its contents into
   the game server folder, so that the plugins end up in `addons/amxmodx/plugins/`, the configs
   in `addons/amxmodx/configs/` and the languages in `addons/amxmodx/data/repruning/`.
3. Add the plugins to `addons/amxmodx/configs/plugins.ini` — the order matters:

   ```ini
   repruning
   pruning_mode_settings
   pruning_info
   ```

4. Load the configuration from `server.cfg`, after the AMX Mod X plugins are started:

   ```cfg
   exec addons/amxmodx/configs/pruning.cfg
   exec addons/amxmodx/configs/pruning_baning.cfg
   ```

5. Restart the server.

## Documentation

Everything else lives in the topic files:

| Doc | What is inside |
| :-- | :------------- |
| [docs/CONFIGURATION.md](docs/CONFIGURATION.md) | All cvars, the config files, logging and important notes. |
| [docs/COMMANDS.md](docs/COMMANDS.md) | Every command with its access flag. |
| [docs/MODES.md](docs/MODES.md) | Game-mode presets and custom presets. |
| [docs/FILE_CHECKS.md](docs/FILE_CHECKS.md) | MD5 file checks, the ban list and the Steam Cloud fix guide. |
| [docs/LANGUAGES.md](docs/LANGUAGES.md) | Language files and how to add a language. |
| [docs/API.md](docs/API.md) | Natives and forwards for other plugins. |
| [docs/STRUCTURE.md](docs/STRUCTURE.md) | Repository layout and the plugin files. |

## Links

- Website — [dev.deropen.fun](https://dev.deropen.fun)
- Repository — [github.com/DeRoPEN31/RePruning](https://github.com/DeRoPEN31/RePruning)
- Telegram — [DeRoPEN_DEv](https://t.me/DeRoPEN_DEv)

## Support & credits

If RePruning is useful for your server, a **star** on GitHub helps other server owners find it —
and keeps the project going.

[![Stars](https://img.shields.io/github/stars/DeRoPEN31/RePruning?style=social)](https://github.com/DeRoPEN31/RePruning/stargazers)
[![Forks](https://img.shields.io/github/forks/DeRoPEN31/RePruning?style=social)](https://github.com/DeRoPEN31/RePruning/network/members)
[![Issues](https://img.shields.io/github/issues/DeRoPEN31/RePruning?style=social)](https://github.com/DeRoPEN31/RePruning/issues)

**Found a bug, or something that does not behave the way it should?** Please report it — bug
reports, false positives and ideas are all welcome, and every one of them is read:

- [Issue tracker](https://github.com/DeRoPEN31/RePruning/issues) — bugs, false positives and feature requests
- [Telegram](https://t.me/DeRoPEN_DEv) — quick questions and personal support

**Want to see more of my work?**

- [dev.deropen.fun](https://dev.deropen.fun) — my website with all plugins and projects
- [github.com/DeRoPEN31](https://github.com/DeRoPEN31) — all of my repositories

Sharing the plugin with other server owners is just as welcome as a star.

## License

Released under the [MIT License](LICENSE). Copyright © 2026 DeRoPEN_DEv.
