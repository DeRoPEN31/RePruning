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
// Only an individual SteamID (STEAM_0:...) is accepted: session-only identifiers (uid_<userid>)
// and shared authids (STEAM_ID_LAN, HLTV) never persist — a restart or a reused userid would
// otherwise punish innocent clients. Returns 1 on success, 0 on a rejected authid/minutes or
// when pruning_bans is 0.
native repruning_add_ban(const authid[], const minutes);

// Removes the authid from the ban list immediately. Returns 1 if an entry was removed, else 0.
native repruning_remove_ban(const authid[]);

// Writes the client identifier used by RePruning (SteamID, or uid_<userid> when no SteamID is
// available yet) into identifier[]. Returns 1 on success, 0 on invalid or unconnected client.
native repruning_get_identifier(id, identifier[], const maxlen);

// Writes the full server report (the pruning_info output, multi-line, ^n-separated) into output[].
// Returns 1 on success. This is what the optional pruning_info.amxx plugin prints.
// DISPLAY ONLY: the text is human-oriented and partly localized — parse repruning_server_data()
// instead. Module and mode states are plain cvars (pruning_*) — read them with cvar natives.
native repruning_server_info(output[], const maxlen);

// Runtime counters for repruning_get_stat().
enum RePruningStat
{
    RePruningStat_Mismatches  = 0,   // total file mismatches recorded this uptime
    RePruningStat_Kicks,             // total kicks issued (mismatch kick + ban kick)
    RePruningStat_Bans,              // total bans issued by the file-check path
    RePruningStat_Errors,            // errors logged this uptime
    RePruningStat_BanListHits,       // clients rejected on connect by the ban list
    RePruningStat_BansExpired,       // ban list entries expired/removed automatically
    RePruningStat_BansInvalid,       // invalid ban list entries dropped (load + live)
    RePruningStat_FileChecks         // active file checks (exactfile entries)
};

// Uptime counter of the plugin, one of RePruningStat_*.
native repruning_get_stat(RePruningStat:stat);

// Number of entries currently in the ban list.
native repruning_get_ban_count();

// Unix time when the active ban list entry for authid expires, 0 = no active entry. Only
// individual SteamIDs are accepted (see repruning_add_ban).
native repruning_get_ban_expiry(const authid[]);

// Machine-readable server state — one "key=value" pair per line, ^n-separated, English keys
// only: api, version, map, log_level, lang, lang_count, lang_keys, file_checks, clients,
// ban_entries, ban_hits, ban_expired, ban_invalid, mismatch_total, kick_total, ban_total,
// errors. The first line is always "api=N" — check it and stop if N is above what you know.
// Returns 1 on success, 0 when the buffer is too small for the full data (the buffer is left
// untouched then). This is the programmatic counterpart of repruning_server_info().
native repruning_server_data(output[], const maxlen);
