# Changelog

Format: `## [Unreleased]` / `## [x.y.z] - YYYY-MM-DD` with Added, Changed, Fixed, Removed, Known Issues.
History before this file: `git log`.

## [Unreleased]
### Added
- PaTiShared window with ••• menu (Settings, Lock/Unlock, Collapse/Expand, Test Mode, Hide), settings modal
  (language, scale, lock), `/pt settings, reset, debug, version`; `/pt` alone shows/hides the window.
- English texts, German translation.
### Changed
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
- Not tested in game yet (threat values, layout, secret values in combat).
