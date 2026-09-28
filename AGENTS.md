# AGENTS.md — PaTiTank

**Read the suite rules first: [`../../PaTiAdmin/AGENTS.md`](../../PaTiAdmin/AGENTS.md).** They apply here in full.
Addon facts: `../../PaTiAdmin/docs/ARCHITECTURE.md` · open issues: `../../PaTiAdmin/docs/FOLLOW_UPS.md`.

## This addon
- Purpose: own health, current target and your threat on it, for a tank. Display only.
- Files: `Logic.lua` (settings, threat value; pure, tested) · `PaTiTank.lua` (window, paint, settings, commands, events) ·
  `Locales/` · `Shared/` (PaTiShared, synced — never edit).
- SavedVariables: `PaTiTankDB` (per character), schema 1: x, y (+ point/relativePoint once dragged), locked, collapsed, scale, language.
- Secure / combat-sensitive: none — no secure frames, so window, collapse and test mode also work in combat. Keep it that way.
- Secret values: health, max health, target name and threat go straight to widgets; `Logic.ThreatValue` checks before clamping.
- Hot path: `UNIT_HEALTH` fires for every unit — only `player` repaints.
- Slash commands: `/pt`, `/patitank`.

## Checks
`bash ../../PaTiAdmin/tools/check.sh .` before every commit. Manual WoW tests: `../../PaTiAdmin/docs/TESTING.md`.
