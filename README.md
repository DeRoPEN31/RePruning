# RePruning

![Version](https://img.shields.io/badge/version-0.0.1--Alpha-blue)
![Game](https://img.shields.io/badge/game-Counter--Strike%201.6-orange)
![Platform](https://img.shields.io/badge/platform-ReAPI%20%7C%20ReHLDS%20%7C%20ReGameDLL-informational)
![License](https://img.shields.io/badge/license-MIT-green)

A plugin for removing, cleaning up, or disabling various features on Counter-Strike 1.6 servers.

> **Reminder:** use `0` to disable the feature and `1` to enable it.

---

## Features

RePruning gives server owners a single place to strip stock Counter-Strike 1.6 behaviour they do
not want, instead of shipping a separate plugin for every small change.

- **Buying & money** — block buying, remove buy zones, hide money
- **Bomb & plant zones** — remove bomb spots and C4 entities
- **HUD icons** — hide bomb, buy zone, defuse kit, flashlight and night vision icons
- **Radio & sounds** — block the radio menu and voice lines, optionally keep round-win sounds
- **Hostages & VIP** — remove hostages, disable VIP logic
- **Effects & decals** — hide blood, impact smoke, sparks, debris and wall decals
- **Corpses** — hide dead bodies
- **Dropped weapons** — clean up dropped guns and defuse kits
- **Console & hints** — silence noisy console messages and HUD hint popups
- **File checks** — verify client files by MD5 against a server-side list

Every feature is a separate switch, so you enable only what your server needs. Nothing in the
game DLLs has to be modified.

## Requirements

| Component    | Version | Required |
| :----------- | :------ | :------: |
| AMX Mod X    | 1.10+   |    yes   |
| Metamod-r    | 1.3+    |    yes   |
| ReHLDS       | 3.x     |    yes   |
| ReGameDLL    | 5.x     |    yes   |
| ReAPI        | 5.x     |    yes   |

Install the modules above before loading RePruning — the plugin works through ReAPI hooks and
will not initialise on a stock engine.

## Installation

1. Download the latest build from [Releases](https://github.com/DeRoPEN31/RePruning/releases)
   or from [deropen.fun](https://deropen.fun).
2. Copy the module into your plugins folder:

   ```
   addons/amxmodx/plugins/repruning.amxx - compiled plugin code
   addons/amxmodx/scripting/repruning.sma - main plugin code
   ```

3. Add it to `addons/amxmodx/configs/plugins.ini`:

   ```ini
   RePruning
   ```

4. Copy `RePruning.cfg` and `pruning_files.cfg` to `addons/amxmodx/configs/`, then load the
   config from `server.cfg`, after the AMX Mod X plugins are started:

   ```cfg
   exec addons/amxmodx/configs/RePruning.cfg
   ```

5. Restart the server.

## Configuration

Every setting is a switch — `0` disables the feature, `1` enables it. All options live in
`addons/amxmodx/configs/RePruning.cfg`, which ships with the release and documents every cvar
inline.

| Cvar | Default | Description |
| :--- | :-----: | :---------- |
| **Buying & money** | | |
| `pruning_buy` | `1` | Block buying: the `B` menu, all weapon / armour / grenade commands, autobuy and rebuy. A player cannot buy anything. |
| `pruning_buyzone_remove` | `1` | Remove buy zones (`func_buyzone`) from the map. The `$` icon disappears from the HUD as well. |
| `pruning_money` | `1` | Zero the money on spawn, block all money awards (frags, bonuses) and hide the money from the HUD. |
| **Bomb & plant zones** | | |
| `pruning_plantzone` | `1` | Remove bomb spots (`func_bomb_target` / `info_bomb_target`) from the map. There is physically nowhere to plant the bomb, and the spot icon disappears. |
| `pruning_bomb_give` | `1` | Method 1 — block the C4 from being given to terrorists, both on round start and on respawn. |
| `pruning_bomb_remove` | `1` | Method 2 — remove C4 entities every round: the C4 in the inventory, the dropped backpack (`w_backpack`) and the planted bomb (`w_c4`). |
| **HUD icons** | | |
| `pruning_icons` | `1` | Hide HUD icons: portable bomb, buy zone `$`, defuse kit, flashlight and night vision. The equipment itself keeps working. |
| **Radio & sounds** | | |
| `pruning_radio` | `1` | Block radio commands: the radio menu (`radio1/2/3`) and all voice lines ("Go go go!", "Fire in the hole!", "Bomb has been planted", etc.). |
| `pruning_radio_winsounds` | `1` | Keep the round-win sounds (`terwin` / `ctwin` / `rounddraw`). Set to `0` to remove them as well. Works only together with `pruning_radio 1`. |
| **Hostages & VIP** | | |
| `pruning_hostages` | `1` | Remove hostages and their rescue zones at the start of every round. For `cs_` maps. |
| `pruning_vip` | `1` | Disable the VIP logic: no VIP is assigned and the evacuation zones are removed. For `as_` maps. |
| **Effects & decals** | | |
| `pruning_effects` | `1` | Hide blood and blood sprites, bullet impact smoke, sparks, armour ricochets and debris — cleaner screen, less traffic. Gameplay effects are not touched: HE and C4 explosions, smoke grenades, etc. still work. |
| `pruning_decals` | `1` | Do not draw bullet holes and blood decals on walls. On DM / ZM maps the walls stop filling up with holes. |
| **Corpses** | | |
| `pruning_corpses` | `1` | Do not show the bodies of dead players. The `ClCorpse` message is simply not sent, so no entity is created and the player disappears instantly on death. |
| **Dropped weapons** | | |
| `pruning_dropweapons` | `1` | Remove the weapons that drop on death or with the `G` key (`weaponbox`), and the dropped defuse kit (`item_thighpack`). Cleaned by a background pass every 2 seconds. The C4 backpack (`w_backpack`) is not touched, so bomb plugins keep working. |
| **Console & hints** | | |
| `pruning_console` | `1` | Block the game messages that flood the client console ("The game is round-based...", "Scoring will not start until both teams have players", "Teams are unbalanced", etc.). **This also blocks the console messages of other plugins** — that is the price of a clean console. |
| `pruning_hints` | `1` | Block the popup hints of the game (`HudText` / `HudTextPro` / `HudTextArgs`): "#Hint_press_buy", "#Spec_Duck", buy hints and other popup texts that cannot be disabled with a stock cvar. Chat and centre messages are not affected. |
| **File checks (MD5)** | | |
| `pruning_files` | `0` | Enable the client file check against the list in `configs/pruning_files.cfg`. **Disabled by default** — enable it consciously and only after setting up the file list. |
| `pruning_files_kick` | `1` | Kick the client on a hash mismatch (the engine usually blocks it on its own, this cvar is a safety net). Set to `0` to only write to `logs/`. |

The bomb can be removed in two ways — `pruning_bomb_give` and `pruning_bomb_remove` — you can
enable either one of them or both at the same time.

Settings are applied on plugin load — edit the config and restart the server to apply them.

## File checks

The plugin can verify the files of the client against a list of reference files on the server
using MD5 hashes.

1. Put a reference copy of every file you want to check into the game folder of the **server**
   itself, at the exact same path.
2. List the paths in `addons/amxmodx/configs/pruning_files.cfg`, one path per line, relative to
   the game directory.
3. Enable `pruning_files 1` and restart the server.

On a mismatch the event is written to `logs/`, and the player is kicked if
`pruning_files_kick 1` is set.

This is how modified and injected client files are caught — including the auto-executed files
such as `autoexec.cfg` or `userconfig.cfg`. Keep in mind that a server cannot clean a player's
computer, and Steam Cloud can restore the blocked files — see the next section.

## Steam Cloud

Steam Cloud can bring back files that the server has already blocked, so a player who synced
them before will keep getting them. The server is not able to clean the machine of a player,
this has to be done on the client side:

1. Open Steam → **Settings** → **Downloads** → **Steam Cloud**.
2. Uncheck **Enable Steam Cloud synchronization for applications that support it**, or uncheck
   **Counter-Strike** in the list of applications.
3. If the file was synced earlier, delete its cloud copy: go to
   `Steam/steamapps/userdata/<SteamID>/10/remote/` and delete the matching folder, then start
   the game — Steam will download the clean version again.
4. Restart the game and rejoin the server. The hash check passes now.

`10` is the Steam application ID of Counter-Strike (CS 1.6).

## Notes

- The plugin does not replace the stock cvars — it removes or disables the behaviour they
  control.
- `pruning_console` also silences the console output of other plugins. Keep it off if you rely
  on `client_print(id, print_console, ...)`.
- `pruning_files` can kick players. Configure the file list first, then enable it.
- Keep a backup of `RePruning.cfg` before editing — it is overwritten on every update.
- Report problems and request features in the [issue tracker](https://github.com/DeRoPEN31/RePruning/issues).

## Links

- Website — [deropen.fun](https://deropen.fun)
- Repository — [github.com/DeRoPEN31/RePruning](https://github.com/DeRoPEN31/RePruning)
- Telegram — [твой_ник](https://t.me/%D1%82%D0%B2%D0%BE%D0%B9_%D0%BD%D0%B8%D0%BA)

## License

Released under the [MIT License](LICENSE). Copyright © 2026 DeRoPEN_DEv.

---

## Support

If RePruning is useful for your server, a **star** on GitHub helps other server owners find it —
and keeps the project going.

[![Stars](https://img.shields.io/github/stars/DeRoPEN31/RePruning?style=social)](https://github.com/DeRoPEN31/RePruning/stargazers)
[![Forks](https://img.shields.io/github/forks/DeRoPEN31/RePruning?style=social)](https://github.com/DeRoPEN31/RePruning/network/members)
[![Issues](https://img.shields.io/github/issues/DeRoPEN31/RePruning?style=social)](https://github.com/DeRoPEN31/RePruning/issues)

**Found a bug, or something that does not behave the way it should?** Please report it — bug
reports, false positives and ideas are all welcome, and every one of them is read:

- [Issue tracker](https://github.com/DeRoPEN31/RePruning/issues) — bugs, false positives and feature requests
- [Telegram](https://t.me/%D1%82%D0%B2%D0%BE%D0%B9_%D0%BD%D0%B8%D0%BA) — quick questions and personal support

**Want to see more of my work?**

- [deropen.fun](https://deropen.fun) — my website with all plugins and projects
- [github.com/DeRoPEN31](https://github.com/DeRoPEN31) — all of my repositories

Sharing the plugin with other server owners is just as welcome as a star.
