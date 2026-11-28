# Game modes

> Applies to RePruning **v0.0.6**.

The mode plugin (`pruning_mode_settings.amxx`) applies a preset with a single cvar. Set it in
`addons/amxmodx/configs/pruning_mode_settings.cfg`:

```
pruning_mode "zm"
```

| Preset | Description |
| :----- | :---------- |
| `zm` | ZM (zombie) mode — no buy, full cleanup, plugin console messages kept. |
| `deathrun` | DeathRun mode — no buy, no C4, no corpses, cleanup on. |
| `csdm` | CSDM mode — no buy (menu servers), full cleanup. |
| `dm` | Classic DM mode — buy allowed, cleanup on. |
| `pub` | Public classic server — all modules off (vanilla). |
| `lasers` | ZM with push / lasers — blood and decals kept for visibility. |
| `custom` | No preset is applied — manage `pruning.cfg` by hand. |

Every preset is a normal config file with the same cvars, so any of them can be edited or
replaced. To add your own preset, create `configs/pruning_mode_<name>.cfg` with the cvars you
need and set `pruning_mode "<name>"` — the name may contain lowercase letters, digits and
underscores only.

The preset is applied on plugin startup, so the mode plugin must load after the core one. To
re-read the selector and re-apply the mode without a restart, use `amx_pruning_mode_reload`;
`amx_pruning_mode` shows the active mode and the available presets.

## Auto mode by map prefix

With `pruning_mode_auto 1` (the default) the mode plugin checks the map name on startup: when the
map starts with a known prefix, the matching preset is applied for that map instead of the static
`pruning_mode`. Built-in prefixes: `ze_` / `zm_` → `zm`, `dr_` / `deathrun_` → `deathrun`,
`dm_` → `dm`, `csdm_` → `csdm`, `de_` / `cs_` / `fy_` / `as_` → `pub`.

Own rules go to `configs/pruning_mode_settings.cfg` — the longest matching prefix wins, and rules
from the file override the built-ins of the same length:

```
pruning_mode "pub"    // applied when no prefix matches (or pruning_mode_auto 0)
pruning_mode_auto 1   // 0 = always use pruning_mode
map ze_ zm            // ze_lila_pustynya -> the zm preset
map de_ pub           // de_dust2 -> the pub preset
```

`pruning_mode_settings.cfg` is parsed by the plugin and accepts only `pruning_mode`,
`pruning_mode_auto` and `map` commands — other cvars belong to `pruning.cfg` /
`pruning_baning.cfg`. The mode is chosen on plugin startup and on `amx_pruning_mode_reload`;
`amx_pruning_mode` shows the auto state and the number of loaded map rules.
