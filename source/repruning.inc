//Name: RePruning v0.0.4
//Author: DeRoPEN_DEv
//Platform: ReHLDS
//Mandatory: ReHLDS 3.15.0.896-dev + ReAPI v5.29.0.359-dev + Metamod-R 1.3.0.149 + AMXModX 1.10+ + ReGameDLL 5.30.0.814-dev
//Description: Public API include for RePruning — natives and forwards for other plugins
//Reminder: #include <repruning.inc> after <amxmodx>; the library name is "repruning"
//Sites: github.com/DeRoPEN31 and deropen.fun

#if defined _repruning_included
    #endinput
#endif
#define _repruning_included

// Runtime dependency: a plugin that includes this file only loads when the repruning core
// plugin is present (put pruning_info.amxx / your plugin AFTER repruning.amxx in plugins.ini).
#pragma library "repruning"

// Called when a client fails a file check (one call per mismatched file).
forward repruning_player_flagged(id, const filename[]);

// Called when a client is added to the autonomous ban list (minutes = ban length before clamp).
forward repruning_player_banned(id, const authid[], const minutes);

// Called when a ban list entry disappears: auto-expired on connect/cleanup or removed via repruning_remove_ban.
forward repruning_player_unbanned(const authid[]);

// 1 if the client has at least one file mismatch recorded this session, else 0.
native repruning_is_flagged(id);

// Number of file mismatches recorded for the client this session (0 = clean).
native repruning_get_mismatches(id);

// 1 if the authid has an active ban list entry right now (expired entries are purged automatically), else 0.
native repruning_is_banned(const authid[]);

// Adds the authid to the autonomous ban list for minutes (clamped by pruning_bans_ttl).
// Returns 1 on success, 0 on invalid authid/minutes or when pruning_bans is 0.
native repruning_add_ban(const authid[], const minutes);

// Removes the authid from the ban list immediately. Returns 1 if an entry was removed, else 0.
native repruning_remove_ban(const authid[]);

// Writes the client identifier used by RePruning (SteamID, or uid_<userid> when no SteamID is
// available yet) into identifier[]. Returns 1 on success, 0 on invalid or unconnected client.
native repruning_get_identifier(id, identifier[], const maxlen);

// Writes the full server report (the pruning_info output, multi-line, ^n-separated) into output[].
// Returns 1 on success. This is what the optional pruning_info.amxx plugin prints.
native repruning_server_info(output[], const maxlen);
