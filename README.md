# PaTiTank

Kompakte Tankanzeige für den WoW-Forever-Client (Interface 16001): eigene Gesundheit, aktuelles Ziel und deine
Bedrohung auf diesem Ziel, dazu der Aggro-Kontroll-Monitor. Reine Anzeige – PaTiTank löst nichts aus,
wählt kein Ziel und spottet nicht.

## Funktionen
- Balken für die eigene Gesundheit und für deine Bedrohung auf das Ziel (0–100 %)
- Name des aktuellen Ziels
- **Aggro-Kontrolle**: „AGGRO 5 / 6 unter Kontrolle“ und bis zu 4 Warnzeilen „Gegner → wer ihn hat“
  (Rolle, sonst Name, sonst „anderer Spieler“). Rot = verloren, Gelb = knapp gehalten, Grau = unklar.
  „Unter Kontrolle“ zählt Gegner, die du hältst (auch knapp). Unklare Werte zählen nie als kontrolliert.
  Gegner kommen aus deinem Ziel, den sichtbaren Namensplaketten und den Zielen deiner Gruppe – Gegner ohne
  sichtbare Plakette, die niemand anvisiert, sieht das Addon nicht.
- Menü `•••`: Einstellungen, Sperren/Entsperren, Ein-/Ausklappen, Testmodus, Ausblenden
- Einstellungen: Sprache, Größe, Fenstersperre; Position wird gespeichert

## Befehle
`/pt`, `/patitank` — ohne Zusatz ein-/ausblenden; `show`, `hide`, `test`, `lock`, `unlock`, `reset` (Position),
`settings`, `debug`, `version`.

Gemeinsame Oberfläche: PaTiShared UI (eingebettet in `Shared/`, kein separates Addon nötig).
