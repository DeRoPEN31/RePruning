# RePruning

![Version](https://img.shields.io/badge/version-0.0.3--V1-blue)
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
- **File checks** — verify client files by MD5 against a server-side list, with kicks and temporary bans
- **Logging & status** — configurable log levels and a live status command
- **Localization** — nine languages for every message the plugin sends

Every feature is a separate switch, so you enable only what your server needs. Nothing in the
game DLLs has to be modified.

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

## Installation

1. Download the latest build from [Releases](https://github.com/DeRoPEN31/RePruning/releases)
   or from [deropen.fun](https://deropen.fun). The archive contains:

   ```
   addons/amxmodx/plugins/repruning.amxx        # compiled plugin — the only file the server needs
   addons/amxmodx/configs/pruning.cfg           # configuration, every option documented inline
   addons/amxmodx/configs/pruning_files.cfg     # list of client files for the MD5 check
   addons/amxmodx/data/repruning/<lang>/         # language files, one folder per language
   source/repruning.sma                         # plugin source — not needed on the server
   ```

2. Unpack the archive — it contains the `RePruning v0.0.3/` folder — and copy its contents into
   the game server folder, so that the plugin ends up in `addons/amxmodx/plugins/`, the configs
   in `addons/amxmodx/configs/` and the languages in `addons/amxmodx/data/repruning/`.
3. Add it to `addons/amxmodx/configs/plugins.ini`:

   ```ini
   repruning
   ```

4. Load the config from `server.cfg`, after the AMX Mod X plugins are started:

   ```cfg
   exec addons/amxmodx/configs/pruning.cfg
   ```

5. Restart the server.

## Repository layout

```
addons/amxmodx/configs/pruning.cfg       — configuration, every option documented inline
addons/amxmodx/configs/pruning_files.cfg — list of client files for the MD5 check
addons/amxmodx/data/repruning/<lang>/     — language files, one folder per language
source/repruning.sma                     — plugin source
```

## Commands

| Command | Access | Description |
| :------ | :----- | :---------- |
| `amx_pruning_status` | `ADMIN_CFG` | Show the current status of the plugin — enabled modules, uptime, rounds, file checks, mismatches, kicks, bans and errors. |

## Logging

All plugin events are written to `addons/amxmodx/logs/RePruning.log`. The detail level is set
with `pruning_log_level`:

| Level | What is logged |
| :---: | :------------- |
| `0` | Logging is off |
| `1` | Errors only |
| `2` | Errors and actions — kicks, bans, file checks (default) |
| `3` | Verbose — every event |

## Configuration

Every setting is a switch — `0` disables the feature, `1` enables it. All options live in
`addons/amxmodx/configs/pruning.cfg`, which ships with the release and documents every cvar
inline.

| Cvar | Default | Description |
| :--- | :-----: | :---------- |
| **Logging** | | |
| `pruning_log_level` | `2` | Detail level of `addons/amxmodx/logs/RePruning.log`: `0` — off, `1` — errors only, `2` — errors and actions (default), `3` — verbose. |
| **Localization** | | |
| `pruning_lang` | `us` | Language of the plugin messages — the code of the folder in `addons/amxmodx/data/repruning/`: `us`, `ru`, `ua`, `kz`, `de`, `dk`, `fr`, `pl`, `se`. |
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
| `pruning_files_fix` | `1` | Send the Steam Cloud / MD5 fix guide to a client with a mismatched file — a message in the chat and an in-game MOTD with the steps to restore the file. |
| `pruning_files_maxfails` | `3` | How many mismatches a client is allowed before it gets banned. `0` — never ban. |
| `pruning_files_bantime` | `30` | Duration of the temporary ban in minutes. `0` — kick only, without a ban. |

The bomb can be removed in two ways — `pruning_bomb_give` and `pruning_bomb_remove` — you can
enable either one of them or both at the same time.

The plugin also registers a read-only cvar `repruning_version` with the version of the build.

Settings are applied on plugin load — edit the config and restart the server to apply them.

## Languages

Every message the plugin sends — the MOTD fix guide, the kick reasons, the startup info — is
loaded from language files. The language is selected with the `pruning_lang` cvar:

```
pruning_lang "us"
```

The files live in `addons/amxmodx/data/repruning/<code>/repruning.txt` — one folder per
language:

| Code | Language | Code | Language |
| :--- | :------- | :--- | :------- |
| `us` | English | `ru` | Russian |
| `ua` | Ukrainian | `kz` | Kazakh |
| `de` | German | `pl` | Polish |
| `dk` | Danish | `se` | Swedish |
| `fr` | French | | |

Every file uses the same format — one `KEY = text` pair per line:

```
MOTD_HEAD = File failed the check: %s
KICK_BAN = file mismatch, banned %d min: %s
```

If a key is missing in the selected language, the plugin falls back to the English (`us`) file,
and if it is missing there as well, the key name itself is printed. To add your own language,
create a folder with the language code, copy the English file into it and translate the values.

## File checks

The plugin can verify the files of the client against a list of reference files on the server
using MD5 hashes.

1. Put a reference copy of every file you want to check into the game folder of the **server**
   itself, at the exact same path.
2. List the paths in `addons/amxmodx/configs/pruning_files.cfg`, one entry per line, in the
   `exactfile "path/to/file"` format. The paths are **relative to the `cstrike` folder**:

   ```
   exactfile "cl_dlls/client.dll"
   exactfile "models/v_m4a1.mdl"
   ```

3. Enable `pruning_files 1` and restart the server.

On a mismatch the event is written to `logs/RePruning.log`, and the player is kicked if
`pruning_files_kick 1` is set. After `pruning_files_maxfails` mismatches the player receives a
temporary ban for `pruning_files_bantime` minutes. With `pruning_files_fix 1` the client also
gets the fix guide in the chat and in an in-game MOTD.

Malformed entries, unknown commands and missing reference files are detected on startup and
written to the log — the check is skipped for those entries instead of failing silently.

Two details about the temporary ban: it is issued by the **engine ban system**
(`banid` / `writeid` → `addons/cstrike/banned.cfg`), not by the AMX Mod X ban list, so it needs
a writable `banned.cfg` and `exec banned.cfg` in `server.cfg` to be applied after a restart. On
top of that the plugin keeps its own memory of the banned clients — see the next section.

## Ban memory

The plugin remembers every client it banned for a file mismatch in
`addons/amxmodx/data/repruning_bans.txt` — the file is created automatically on the first ban.

The memory is loaded on startup, so the bans survive a restart of the server. A client that is in
the memory is kicked right after the authorization, with the reason
`RePruning: file mismatch ban (N min)`.

Delete the file if you want to clear the memory and let the banned clients back in.

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

With `pruning_files_fix 1` the plugin sends exactly these steps to a player with a mismatched
file — as a chat message and as an in-game MOTD, so the player can fix it without asking the
admin for help.

## Notes

- The plugin does not replace the stock cvars — it removes or disables the behaviour they
  control.
- `pruning_console` also silences the console output of other plugins. Keep it off if you rely
  on `client_print(id, print_console, ...)`.
- `pruning_files` can kick and ban players. Configure the file list first, then enable it.
- The ban counter is tracked per client by SteamID and user ID, so a reconnect does not reset
  it, and it is stored on disk as well — see the ban memory section.
- Keep a backup of `pruning.cfg` before editing — it is overwritten on every update.
- Report problems and request features in the [issue tracker](https://github.com/DeRoPEN31/RePruning/issues).

## Links

- Website — [deropen.fun](https://deropen.fun)
- Repository — [github.com/DeRoPEN31/RePruning](https://github.com/DeRoPEN31/RePruning)
- Telegram — [DeRoPEN_DEv](https://t.me/DeRoPEN_DEv)

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
- [Telegram](https://t.me/DeRoPEN_DEv) — quick questions and personal support

**Want to see more of my work?**

- [deropen.fun](https://deropen.fun) — my website with all plugins and projects
- [github.com/DeRoPEN31](https://github.com/DeRoPEN31) — all of my repositories

Sharing the plugin with other server owners is just as welcome as a star.
