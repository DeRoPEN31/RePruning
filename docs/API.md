# API for other plugins

> Applies to RePruning **v0.0.6**.

The core plugin exposes a library called `repruning`. Put `repruning.inc` into
`addons/amxmodx/scripting/include/` and include it after `<amxmodx>`:

```cpp
#include <amxmodx>
#include <repruning>
```

Because of `#pragma library "repruning"` the plugin that includes the file only loads when the
core plugin is present — it refuses to load instead of half-working. Put such plugins AFTER
`repruning.amxx` in `plugins.ini`.

## Natives

| Native | Description |
| :----- | :---------- |
| `repruning_is_flagged(id)` | `1` if the client has at least one file mismatch recorded this session, else `0`. |
| `repruning_get_mismatches(id)` | Number of file mismatches recorded for the client this session. |
| `repruning_is_banned(authid)` | `1` if the authid has an active ban list entry right now. |
| `repruning_add_ban(authid, minutes)` | Adds the authid to the ban list, clamped by `pruning_bans_ttl`. Only individual SteamIDs are accepted — `uid_<userid>` and shared authids (`STEAM_ID_LAN`) return `0`. |
| `repruning_remove_ban(authid)` | Removes the authid from the ban list immediately. |
| `repruning_get_identifier(id, identifier[], maxlen)` | Writes the identifier used by RePruning — the SteamID, or `uid_<userid>` when there is no SteamID yet. |
| `repruning_server_info(output[], maxlen)` | Writes the full server report — the same output as `pruning_info`. Display only: the text is human-oriented and partly localized. |
| `repruning_server_data(output[], maxlen)` | Machine-readable server state — `key=value` lines, English keys only, first line is `api=N` (check it before parsing). Returns `1` on success, `0` when the buffer is too small. Use this instead of `repruning_server_info` for parsing. |
| `repruning_get_ban_expiry(authid)` | Unix time when the active ban entry for the authid expires, `0` = no active entry. Only individual SteamIDs are accepted. |
| `repruning_get_ban_count()` | Number of entries currently in the ban list. |
| `repruning_get_stat(stat)` | Uptime counter, one of `RePruningStat_*`: mismatches, kicks, bans, errors, ban list hits, expired and invalid entries, active file checks. |
| `repruning_is_immune(authid)` | `1` if the authid is on the immunity list (`configs/pruning_immunity.cfg`) — such clients are never auto-banned by the file-check system, else `0`. |

Module and mode states are plain cvars (`pruning_*`) — read them with cvar natives if you need
them; the natives above expose only the internal runtime state.

## Forwards

| Forward | Description |
| :------ | :---------- |
| `repruning_player_flagged(id, filename)` | Called when a client fails a file check — one call per mismatched file. |
| `repruning_player_banned(id, authid, minutes)` | Called when a client is added to the ban list. |
| `repruning_player_unbanned(authid)` | Called when a ban list entry disappears — expired or removed. |
