# AGENTS.md — PaTiTank

**Read the suite rules first: [`../../PaTiAdmin/AGENTS.md`](../../PaTiAdmin/AGENTS.md).** They apply here in full
(independence, combat lockdown, no automation, localization, tests, Definition of Done, VALIDATION output).
Addon facts: `../../PaTiAdmin/docs/ARCHITECTURE.md` · open issues: `../../PaTiAdmin/docs/FOLLOW_UPS.md`.

## This addon
- Purpose: own health, current target and threat on it, for a tank.
- SavedVariables: `PaTiTankDB` (per character): x, y, locked.
- Secure / combat-sensitive: none (no secure frames).
- Slash commands: `/pt`, `/patitank` — test, show, hide, lock, unlock.
- Uses the legacy `PaTiSharedPanel.lua` (FOLLOW_UPS F6) — do not extend it; new chrome comes from PaTiShared.

## Checks
`bash ../../PaTiAdmin/tools/check.sh .` before every commit. Manual WoW tests: `../../PaTiAdmin/docs/TESTING.md`.
