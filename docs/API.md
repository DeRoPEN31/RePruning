# API for other plugins

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
| `repruning_add_ban(authid, minutes)` | Adds the authid to the ban list, clamped by `pruning_bans_ttl`. |
| `repruning_remove_ban(authid)` | Removes the authid from the ban list immediately. |
| `repruning_get_identifier(id, identifier[], maxlen)` | Writes the identifier used by RePruning — the SteamID, or `uid_<userid>` when there is no SteamID yet. |
| `repruning_server_info(output[], maxlen)` | Writes the full server report — the same output as `pruning_info`. |

## Forwards

| Forward | Description |
| :------ | :---------- |
| `repruning_player_flagged(id, filename)` | Called when a client fails a file check — one call per mismatched file. |
| `repruning_player_banned(id, authid, minutes)` | Called when a client is added to the ban list. |
| `repruning_player_unbanned(authid)` | Called when a ban list entry disappears — expired or removed. |
