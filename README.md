# PaTiTank

<img src="assets/icon-128.png" width="96" alt="PaTiTank icon">

A small tank HUD for World of Warcraft: Forever (Interface 16001): your health, your threat on your target and which
enemies you do not hold any more. Display only — it never targets or taunts.

> Status: 0.1.0, in development, not yet released. Not yet tested in game.

## Features
- Your health bar, your current target and your threat on it
- **Aggro control:** `AGGRO 5 / 6 under control` plus up to four rows for enemies that need you:
  red = lost, with who has it (role, else name, else "other player"), yellow = barely held, grey = unclear.
  Unreadable data is shown as "unclear", never as "under control"
- Enemies come from your target, visible nameplates and your party's targets
- **Numbered nameplates:** every problem row gets a number (`1 Kultist → Healer`), and the same number stands above
  that enemy's nameplate — red = lost, yellow = barely held, grey = unclear. Two enemies with the same name are told
  apart by their number. Click the nameplate with that number to target the enemy, then taunt yourself.
  PaTiTank never targets or taunts on its own
- A row without a number has no nameplate that can be named safely right now (e.g. the enemy is off screen) —
  PaTiTank shows no number rather than a wrong one
- ••• menu: Settings, Lock, Collapse, Test Mode, Hide. Settings: language, scale, lock.
  Languages: English, Deutsch (others fall back to English)

## Installation
1. Download the release zip (`PaTiTank-<version>.zip`).
2. Unpack it and copy the folder `PaTiTank` into `World of Warcraft/<client>/Interface/AddOns/`.
3. Start WoW and enable PaTiTank in the AddOns list.

## First steps
- `/pt test` shows the aggro display with six example enemies
- Turn on enemy nameplates (default key V) so PaTiTank sees more than your target
- `/pt` shows or hides the window
- A red row `1 Kultist → Healer` appears: click the nameplate showing a red "1" to target that enemy

## Settings
`/pt settings` or ••• → Settings: language, scale, window lock, numbers on nameplates on/off (off: no numbers at all).

## Commands
`/pt` or `/patitank` — alone: show/hide · `settings` · `test` · `show` · `hide` · `lock` · `unlock` · `reset` (position) ·
`debug` (also shows which threat APIs your client offers) · `version`

## Known limitations
- Enemies without a visible nameplate that nobody in your group targets are not seen.
- The rows in the panel are not clickable: WoW does not let an addon decide in combat which enemy a click targets.
  Click the numbered nameplate instead.
- Numbers need visible enemy nameplates; forbidden nameplates are left alone. Numbers 1–4 (the visible rows).
- The threat APIs are not yet confirmed in the Forever client.

## License
MIT — see [LICENSE](LICENSE). Copyright (c) 2026 Patrick Koch.
