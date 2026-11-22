# Repository layout and plugins

## Repository layout

```
addons/amxmodx/configs/pruning.cfg                — main configuration
addons/amxmodx/configs/pruning_baning.cfg         — file checks and the ban system
addons/amxmodx/configs/pruning_files.cfg          — list of client files for the MD5 check
addons/amxmodx/configs/pruning_mode_settings.cfg  — active mode selector
addons/amxmodx/configs/pruning_mode_*.cfg         — mode presets
addons/amxmodx/data/repruning/<lang>/             — language files, one folder per language
source/repruning.sma                             — core plugin source
source/pruning_mode_settings.sma                  — mode presets source
source/pruning_info.sma                          — status report plugin source
source/repruning.inc                             — public API for other plugins
```

## Plugins

| Plugin | File | Required | Description |
| :----- | :--- | :------: | :---------- |
| RePruning | `repruning.amxx` | yes | The core plugin — all the pruning modules, the file checks, the ban list and the public API. |
| RePruning Mode Settings | `pruning_mode_settings.amxx` | no | Applies a ready preset for ZM, DeathRun, CSDM, DM, Pub or Lasers with one cvar. |
| RePruning Info | `pruning_info.amxx` | no | Adds the `pruning_info` / `amx_pruning_status` command with the full server report. |

The load order in `plugins.ini` matters — `repruning` first, the optional plugins after it. The
mode plugin applies its preset on `plugin_cfg`, so it has to be loaded after the core one.
