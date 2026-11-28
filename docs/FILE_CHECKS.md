# File checks, ban list and Steam Cloud

> Applies to RePruning **v0.0.6**.

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

The ban is issued by the **engine ban system** (`banid` / `writeid` →
`addons/cstrike/banned.cfg`), not by the AMX Mod X ban list, so it needs a writable `banned.cfg`
and `exec banned.cfg` in `server.cfg` to be applied after a restart. On top of that the plugin
keeps its own ban list — see the next section.

## Ban list

The plugin keeps its own ban list in `addons/amxmodx/data/repruning_bans.txt` — the file is
created automatically on the first ban. The entries are stored as `steamid expiry_unix`.

- Every entry expires on its own — there is nothing to clean up by hand.
- Only individual SteamIDs reach the list. A session-only identifier (`uid_<userid>` — the key
  while the client's SteamID has not arrived yet) and shared pseudo-authids (`STEAM_ID_LAN`,
  `HLTV`) are never stored: a server restart or a reused userid must never make the plugin
  punish an innocent client. A flagged client without a SteamID is punished for the session
  only, and the log reports the skipped ban.
- Export and import — `amx_pruning_bans_export [file]` writes the active entries to
  `configs/<file>`, `amx_pruning_bans_import <file>` merges a file back: invalid and expired
  entries are skipped, `pruning_bans_ttl` and `pruning_bans_max` are applied.
- The immunity list `configs/pruning_immunity.cfg` (one SteamID per line) marks clients that are
  never auto-banned: a flagged client on the list is punished for the session only, nothing is
  persisted. Existing ban entries are not removed by immunity.
- Expired entries are removed on load and then every hour (`pruning_bans_cleanup 1`).
- A client on the list is kicked right after the authorization, before the map is even loaded.
- The list is capped at `pruning_bans_max` entries — the earliest-expiring entry is evicted
  first when the limit is reached.
- The ban length is limited by `pruning_bans_ttl` (hours), the ban itself is set by
  `pruning_files_bantime` (minutes).

Delete the file if you want to clear the list and let the banned clients back in.

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
