# Commands

| Command | Access | Description |
| :------ | :----- | :---------- |
| `pruninginfo` | everyone | Chat command — what is removed on this server, your file-check status and your identifier. |
| `pruningid` | everyone | Show your own identifier. |
| `pruning_ids` | `ADMIN_BAN` | Identifier table of all connected players. |
| `amx_pruning_reload` | `ADMIN_CFG` | Reload `pruning.cfg`, `pruning_baning.cfg`, the languages and the ban list. |
| `amx_pruning_mode` | `ADMIN_CFG` | Show the active mode and the available presets. |
| `amx_pruning_mode_reload` | `ADMIN_CFG` | Re-read `pruning_mode_settings.cfg` and re-apply the mode. |
| `pruning_info` | `ADMIN_CFG` | Full server report — modules, file checks, ban list and validation. Needs `pruning_info.amxx`. |
| `amx_pruning_status` | `ADMIN_CFG` | Alias of `pruning_info`. Needs `pruning_info.amxx`. |

`pruning_info` and `amx_pruning_status` are provided by the optional `pruning_info.amxx` plugin —
add it to `plugins.ini` after `repruning`. The command only reads the server state: no hooks, no
tasks, nothing else — it is safe to enable or remove at any time.
