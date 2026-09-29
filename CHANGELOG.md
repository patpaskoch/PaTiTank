# Changelog

Format: `## [Unreleased]` / `## [x.y.z] - YYYY-MM-DD` with Added, Changed, Fixed, Removed, Known Issues.
History before this file: `git log`.

## [Unreleased]
### Added
- PaTiShared window with ••• menu (Settings, Lock/Unlock, Collapse/Expand, Test Mode, Hide), settings modal
  (language, scale, lock), `/pt settings, reset, debug, version`; `/pt` alone shows/hides the window.
- English texts, German translation.
- Aggro control monitor: "AGGRO x / y under control" plus up to 4 rows for enemies you lost (with the holder's
  role, else name, else "other player"), barely hold, or cannot read. Enemies come from your target, visible
  nameplates and your party's targets. Unreadable (secret) threat data shows as "unclear", never as controlled.
  Scans are event driven and coalesced (0.1 s); in combat a 1 s fallback rescan catches changes no event reports.
  Test mode shows 6 enemies: 4 held, 1 barely held, 1 on the healer. `/pt debug` shows which aggro APIs exist.
- Tests for the collapsed state (default, migration keeps a saved value, restore defaults expands).
### Changed
- AddOns list description in English with a German translation (`## Notes-deDE`); README rewritten for players
  (features, installation, first steps, commands, known limitations).
- New PaTiShared look instead of the legacy panel (gear, chevron, close button).
- Only your own UNIT_HEALTH/UNIT_MAXHEALTH updates the health bar (before: every unit's health event redrew everything).
- Settings in PaTiTankDB get a schema; the 0.1.0 position and lock state are kept.
### Fixed
- The addon did not load: the TOC listed both Lua files on one line with a literal `` `r`n `` between them.
- Target name and threat value are no longer concatenated/compared, so restricted (secret) values cannot cause errors.
- Saving defaults into the saved variables on every login (`x = x or -330`) is gone.
### Removed
- `PaTiSharedPanel.lua` (legacy shared panel global).
### Known Issues
- Not tested in game yet (threat values, layout, secret values in combat, the whole aggro monitor).
- Aggro: enemies without a visible nameplate that nobody in your group targets are not seen. Clicking a row does
  not target the enemy, and nameplates are not highlighted (see PaTiAdmin FOLLOW_UPS F16/F17).
