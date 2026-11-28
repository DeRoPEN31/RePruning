# Configuration

> Applies to RePruning **v0.0.6**.

Every setting is a switch — `0` disables the feature, `1` enables it. The options are split
between two files:

| File | What it holds |
| :--- | :------------ |
| `pruning.cfg` | The module switches, the logging level and the language. |
| `pruning_baning.cfg` | The file checks, the autonomous ban list and the identifier system. |

## Logging

All plugin events are written to `addons/amxmodx/logs/RePruning.log`. The detail level is set
with `pruning_log_level`:

| Level | What is logged |
| :---: | :------------- |
| `0` | Logging is off |
| `1` | Errors only |
| `2` | Errors and actions — kicks, bans, file checks (default) |
| `3` | Verbose — every event |

## Cvars

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
| `pruning_dropweapons` | `1` | Remove the weapons that drop on death or with the `G` key (`weaponbox`), and the dropped defuse kit (`item_thighpack`). Cleaned on the drop event and by a background pass every 2 seconds. The C4 backpack (`w_backpack`) is not touched, so bomb plugins keep working. |
| **Console & hints** | | |
| `pruning_console` | `1` | Block the game messages that flood the client console ("The game is round-based...", "Scoring will not start until both teams have players", "Teams are unbalanced", etc.). **This also blocks the console messages of other plugins** — that is the price of a clean console. |
| `pruning_hints` | `1` | Block the popup hints of the game (`HudText` / `HudTextPro` / `HudTextArgs`): "#Hint_press_buy", "#Spec_Duck", buy hints and other popup texts that cannot be disabled with a stock cvar. Chat and centre messages are not affected. |
| **File checks** | | |
| `pruning_files` | `0` | Enable the client file check against the list in `configs/pruning_files.cfg`. **Disabled by default** — enable it consciously and only after setting up the file list. |
| `pruning_files_kick` | `1` | Kick the client on a hash mismatch (the engine usually blocks it on its own, this cvar is a safety net). Set to `0` to only write to `logs/`. |
| `pruning_files_fix` | `1` | Send the Steam Cloud / MD5 fix guide to a client with a mismatched file — a message in the chat and an in-game MOTD with the steps to restore the file. |
| `pruning_files_maxfails` | `3` | How many mismatches a client is allowed before it gets banned. `0` — never ban. |
| `pruning_files_bantime` | `30` | Duration of the temporary ban in minutes. `0` — kick only, without a ban. |
| **Autonomous ban list** | | |
| `pruning_bans` | `1` | Master switch of the ban list — the clients on it are rejected on connect. `0` — the list is not used. |
| `pruning_bans_ttl` | `720` | Maximum ban length in **hours** — a longer ban is clamped to this value. `0` — unlimited. Valid range: 0–87600. |
| `pruning_bans_cleanup` | `1` | Remove the expired entries automatically — on load and every hour. `0` — manual only. |
| `pruning_bans_max` | `500` | Hard limit of the ban list entries — the earliest-expiring entry is evicted first. Valid range: 1–10000. |
| **Identifiers** | | |
| `pruning_ids` | `1` | Identifier system — `pruningid` shows your own ID, `pruning_ids` prints the table of all connected players. `0` — off. |
| **Modes** | | |
| `pruning_mode` | `""` | Active mode preset, set in `configs/pruning_mode_settings.cfg`. Belongs to the mode plugin. |
| `pruning_mode_auto` | `1` | Auto mode by map prefix — when the map starts with a known prefix (`ze_`, `zm_`, `dr_`, ...), its preset is applied. `0` — always use `pruning_mode`. See Game modes. |

The plugin also registers the read-only cvars `repruning_version` and `repruning_mode_version`
with the version of the build.

The bomb can be removed in two ways — `pruning_bomb_give` and `pruning_bomb_remove` — you can
enable either one of them or both at the same time.

Settings are applied on plugin load — edit the config and restart the server to apply them, or
use `amx_pruning_reload` to apply them without a restart.

## Important notes

- The plugin does not replace the stock cvars — it removes or disables the behaviour they
  control.
- `pruning_console` also silences the console output of other plugins. Keep it off if you rely
  on `client_print(id, print_console, ...)`.
- `pruning_files` can kick and ban players. Configure the file list first, then enable it.
- The identifier of a client is the SteamID, or `uid_<userid>` for a client without one yet.
- `pruning.cfg` and `pruning_baning.cfg` survive plugin updates: the old file is read as is, and
  the options it does not contain keep their default values. `amx_pruning_upgrade` appends the
  missing options to the file (the original is saved as `.bak`). A missing config is generated
  with defaults — there is nothing to delete or back up by hand on an update.
- Report problems and request features in the [issue tracker](https://github.com/DeRoPEN31/RePruning/issues).
