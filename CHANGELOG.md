# Changelog

All notable changes to RePruning are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Nothing yet.

### Fixed

- Nothing yet.

### Changed

- Nothing yet.

### Removed

- Nothing yet.

## [0.0.4] — 2026-11-22

### Added

- Public API — `repruning.inc` with 7 natives (`repruning_is_flagged`, `repruning_get_mismatches`,
  `repruning_is_banned`, `repruning_add_ban`, `repruning_remove_ban`, `repruning_get_identifier`,
  `repruning_server_info`) and 3 forwards (`repruning_player_flagged`, `repruning_player_banned`,
  `repruning_player_unbanned`), so other plugins can read the state of the plugin, manage the ban
  list and react to the bans. Because of `#pragma library "repruning"` a plugin that uses the API
  only loads when the core plugin is present.
- Autonomous ban list — `pruning_bans`, `pruning_bans_ttl`, `pruning_bans_cleanup` and
  `pruning_bans_max`: the entries expire on their own, are cleaned up automatically and the
  list is capped.
- Ban file validation and conversion — malformed and expired entries in `repruning_bans.txt` are
  dropped with a log report; the 0.0.3 format (`steamid minutes added_unix`) converts to the new
  `steamid expiry_unix` format automatically, no manual editing.
- Loud warning when file checks are enabled — switching `pruning_files` to `1` prints a prominent
  multi-line warning to the server console and the log, so the kick/ban switch is never enabled
  by accident.
- Cvar validation — `pruning_files_maxfails`, `pruning_files_bantime`, `pruning_bans_ttl` and
  `pruning_bans_max` are checked on range and clamped.
- Game mode presets — `pruning_mode_settings.amxx` applies a ready set of modules for ZM,
  DeathRun, CSDM, DM, Pub or Lasers with one cvar. Six presets ship with the release, and any
  own preset can be added as `configs/pruning_mode_<name>.cfg`.
- Identifier system — `pruningid` shows your own identifier, `pruning_ids` prints the table of
  all connected players (uid, identifier, name, status). The identifier is the SteamID, or
  `uid_<userid>` when there is no SteamID yet — the same key the plugin uses for mismatch
  tracking and bans. Controlled by `pruning_ids`.
- `pruning_info.amxx` — a standalone status command (`pruning_info` / `amx_pruning_status`)
  that only reads the state, without hooks and tasks.
- `pruninginfo` chat command — what is removed on this server, your file-check status and your
  identifier.
- `amx_pruning_reload` — reload of `pruning.cfg`, `pruning_baning.cfg`, the languages and the
  ban list.
- `BAN_REJECT` language key — the connect-time rejection reason with the auto-expiry date,
  translated into all nine languages.
- The configuration is split into `pruning.cfg` (modules, logging, language) and
  `pruning_baning.cfg` (file checks, bans, identifiers).

### Changed

- The ban list stores the absolute expiry time (`steamid expiry_unix`) instead of the ban
  length, so the entries can expire on their own.
- The mode presets are read from `configs/pruning_mode_settings.cfg`, and the available presets
  are discovered automatically in `configs/`.
- The `amx_pruning_status` command moved to the optional `pruning_info.amxx` plugin.
- The documentation is split — the README now holds only the description, download, installation
  and credits; the configuration, commands, modes, file checks, languages, API and repository
  structure moved to the topic files in `docs/`.
- The version of the build is reported as `0.0.4`.

### Fixed

- The dropped weapons are now removed immediately on the drop event, instead of waiting for the
  next background pass.

### Removed

- Nothing.

## [0.0.3] — 2026-11-19
### Added

- Localization — every message of the plugin is now loaded from language files in
  `addons/amxmodx/data/repruning/<code>/repruning.txt`, the language is selected with the
  `pruning_lang` cvar.
- Nine languages shipped with the release — `us`, `ru`, `ua`, `kz`, `de`, `dk`, `fr`, `pl`, `se`.
- Fallback to the English file when a key is missing in the selected language, and to the key
  name when it is missing everywhere.
- Ban memory — the banned clients are stored in `addons/amxmodx/data/repruning_bans.txt`, survive
  a restart of the server and are kicked right after the authorization.
- Drop cleanup on demand — the dropped weapons are removed immediately on the drop event,
  instead of waiting for the next background pass.

### Changed

- The platform of the plugin is ReHLDS.
- The version of the build is reported as `v0.0.3 V1`.

### Fixed

- The mixed Russian / English MOTD is gone — every text now comes from the language file.

### Removed

- Nothing.

## [0.0.2-alpha] — 2026-11-17

### Added

- Logging system with configurable levels (`pruning_log_level`), written to `addons/amxmodx/logs/RePruning.log`.
- `amx_pruning_status` command — status of the plugin, enabled modules, uptime, rounds, file checks, mismatches, kicks, bans and errors.
- File mismatch tracking per client by SteamID and user ID.
- Automatic temporary bans for repeated mismatches (`pruning_files_maxfails`, `pruning_files_bantime`).
- Steam Cloud / MD5 fix guide sent to clients with mismatched files — chat message and in-game MOTD (`pruning_files_fix`).
- Validation of `pruning_files.cfg` — malformed entries, unknown commands and missing reference files are detected and logged.
- Runtime statistics — file checks, connected clients, rounds, mismatches, kicks, bans and errors.

### Changed

- File integrity checking has been significantly expanded.
- `pruning_files.cfg` now expects paths relative to the `cstrike` folder.
- File-check errors are logged instead of failing silently.
- Startup output now includes the current map, the log level and the active file checks.

### Fixed

- Missing `pruning.cfg` is handled correctly.
- Invalid entries in `pruning_files.cfg` are skipped and reported.
- Missing reference files during the MD5 check no longer break the check.
- Steam Cloud / MD5 troubleshooting for clients with mismatched files.
- Various internal cleanup and stability improvements.

### Removed

- Nothing.

## [0.0.1-alpha] — 2026-11-16

### Added

- Buying & money — block buying, remove buy zones, zero and hide the money.
- Bomb & plant zones — remove bomb spots, block the C4 handover, remove C4 entities.
- HUD icons — hide the bomb, buy zone, defuse kit, flashlight and night vision icons.
- Radio & sounds — block the radio menu and voice lines, optionally keep round-win sounds.
- Hostages & VIP — remove hostages, disable the VIP logic.
- Effects & decals — hide blood, impact smoke, sparks, debris and wall decals.
- Corpses — hide the bodies of dead players.
- Dropped weapons — clean up dropped guns and defuse kits.
- Console & hints — silence noisy console messages and HUD hint popups.
- File checks — verify client files by MD5 against a server-side list.
- `pruning.cfg` with all options documented inline.
- `pruning_files.cfg` — template for the client file check list.

### Fixed

- Nothing yet — first alpha release.

### Changed

- Nothing yet.

### Removed

- Nothing yet.

[Unreleased]: https://github.com/DeRoPEN31/RePruning/compare/0.0.4...HEAD
[0.0.4]: https://github.com/DeRoPEN31/RePruning/releases/tag/v0.0.4
[0.0.3]: https://github.com/DeRoPEN31/RePruning/releases/tag/0.0.3
[0.0.2-alpha]: https://github.com/DeRoPEN31/RePruning/releases/tag/0.0.2
[0.0.1-alpha]: https://github.com/DeRoPEN31/RePruning/releases/tag/0.0.1

