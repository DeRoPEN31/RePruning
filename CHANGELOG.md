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

[Unreleased]: https://github.com/DeRoPEN31/RePruning/compare/0.0.3...HEAD
[0.0.3]: https://github.com/DeRoPEN31/RePruning/releases/tag/0.0.3
[0.0.2-alpha]: https://github.com/DeRoPEN31/RePruning/releases/tag/0.0.2
[0.0.1-alpha]: https://github.com/DeRoPEN31/RePruning/releases/tag/0.0.1

- Nothing yet.

[Unreleased]: https://github.com/DeRoPEN31/RePruning/compare/0.0.2...HEAD
[0.0.2-alpha]: https://github.com/DeRoPEN31/RePruning/releases/tag/0.0.2
[0.0.1-alpha]: https://github.com/DeRoPEN31/RePruning/releases/tag/0.0.1
