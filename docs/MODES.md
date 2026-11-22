# Game modes

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
