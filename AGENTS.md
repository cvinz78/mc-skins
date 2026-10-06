# AGENTS.md — Arbeitsregeln für Agenten & Mitwirkende

Projekt: **Midnight-Commander-Skins + Installer** (`/home/baba/mcs/`)
Diese Datei ist verbindlich für jede (automatische oder manuelle) Bearbeitung
des Projekts. Technischer Vollkontext mit Fehlerhistorie: siehe **TASK.md**.

## Dateien im Projekt

| Datei | Zweck |
|---|---|
| `mc-skins.sh` | Selbst-entpackender POSIX-Installer (bettet alle Skins ein) |
| `README.md` | Anwenderdokumentation für GitHub: Skins, Schnellstart, Installer-Referenz (seit 2026-10-06; interne Details stehen in TASK.md) |
| `LICENSE` | GNU GPL v3 (GitHub-Veröffentlichung) |
| `screenshots/` | Skin-Vorschau-PNGs für die README (Erzeugung: TASK.md §11.4) |
| `DESIGN.md` | Verbindliches Farbschema der Script-Ausgaben |
| `TASK.md` | **Lebendes Statusdokument**: aktueller Stand, Fehler, Lösungen; seit 2026-10-06 mit der alten README.md zusammengeführt (Voll-Dokumentation) |
| `SKILL.md` | Skill-Datei: Schnelleinstieg & Workflow zum Fortsetzen |
| `old/` | Backups des Scripts (vor JEDER Änderung, siehe Regel 1) und gesicherter alter Dokumente |
| `tmp/` | Bewährte Test-Scripts und Werkzeuge (Regel 10) |

Externe, vom Script verwaltete Dateien (nicht im Projektordner):
`~/.local/share/mc/skins/{DarkGreen,BlueMoon,Creamy}.ini`,
`~/.config/mc/filehighlight.ini`, `~/.config/mc/ini`.

---

## Verbindliche Regeln

### Regel 1 — Backup VOR jeder Änderung des Scripts
Bevor `mc-skins.sh` (oder eine eingebettete Datei in ihm) geändert wird,
MUST eine Sicherung im Projektordner unter `old/` angelegt werden:

```sh
mkdir -p old
cp -p mc-skins.sh "old/mc-skins_backup_$(date +%Y%m%d-%H%M).sh"
```
Wenn die Version ohne Ausführen des Scripts ermittelbar ist (z. B. per
`grep '^VERSION='`), SOLL der Dateiname sie enthalten:
`old/mc-skins_v1.1_20261005-2200.sh`.
Backups werden NICHT automatisch gelöscht.

### Regel 2 — Versionsnummer erhöhen
Jede Änderung am Script erhöht `VERSION="…"` im Script um **0.1**
(aktuelle Version steht immer oben im Script und in `TASK.md` §7).
Das Kommando `-r` erhöht die Version des NEU erzeugten Scripts automatisch
um 0.1 — das gilt nicht als manuelle Änderung am Quell-Script.

### Regel 3 — TASK.md aktuell halten
Nach jeder Änderung MUST der neue Stand in `TASK.md` eingetragen werden:
Versionshistorie (§7), neue/behobene Fehler (§4), neue Erkenntnisse (§3/§5).

### Regel 4 — Testpflicht vor Abschluss
`sh -n mc-skins.sh` (Syntax) und der Standard-Testlauf (siehe SKILL.md §Tests)
MÜSSEN fehlerfrei durchlaufen, bevor eine Änderung als fertig gilt.

### Regel 5 — Sprach- und Farbvorgaben
- Alle nutzerlesbaren Texte existieren **zweisprachig** (de/en, über `tr()`).
- Ausgabefarben folgen `DESIGN.md`; `-nc` und Pipe-Erkennung (`[ -t 1 ]`)
  dürfen nicht umgangen werden.
- Sprache auch via `LANG_MODE`-Variable oben im Script wählbar (Standard de).

### Regel 6 — MC-Technik respektieren (Häufige Fehlerquellen)
- Skin-Dateien (GKeyFile): Kommentare NUR als eigene `#`-Zeile, NIEMALS
  hinter einen Wert.
- Farben ausschließlich als Hexcodes `#rrggbb` (oder `#rgb`).
- `filehighlight.ini`: Reihenfolge = Priorität (erster Treffer gewinnt);
  `[regular]` mit `regexp=.*` bleibt IMMER letzte Gruppe; `[txtfiles]` immer
  vor `[doc]`.
- `[Lines]`-Sektion darf nie entfernt werden (sonst keine Rahmen).
- Dialog-Rahmenfarbe = Dialog-Textfarbe (MC-intern, nicht trennbar).

### Regel 7 — Docker-Klone statt erneuter Downloads
- Für Distro-Tests (Ubuntu, Debian, Alpine …) Container herunterladen,
  EINMAL einrichten (Pakete installieren, Testbenutzer anlegen) und mit
  `docker commit` als Klon speichern (z. B. `mc-skins-ubuntu:24.04`).
  Danach ausschließlich mit den Klonen arbeiten — keine wiederholten
  Downloads/Installationsläufe.
- Vorhandene Klone: siehe TASK.md §10.
- Klone werden **nur auf ausdrückliche Nutzeranweisung** gelöscht —
  wenn der Nutzer „Projekt aufräumen" oder „Projekt abgeschlossen" sagt
  (`docker rmi <klon>`). Niemals eigenständig aufräumen oder löschen.

### Regel 8 — Test-Wiederholungen begrenzen
- Schlägt ein Test **zweimal hintereinander** fehl oder bricht er ab,
  wird er nicht mehr ausgeführt/wiederholt.
- Der ausgeschlossene Test wird sofort in **TASK.md** (Abschnitt
  „Ausgeschlossene Tests") notiert — mit Grund und Datum — damit
  künftige Läufe ihn überspringen.

### Regel 9 — Test-Timeouts
- Nach **2 Minuten** Laufzeit wird nachgesehen, ob ein Test noch läuft
  oder sich aufgehängt hat.
- Harte Obergrenze: **5 Minuten** pro Test (z. B. `timeout 300 …`).
  Hängende Tests werden abgebrochen und zählen als Fehlschlag
  (→ Regel 8: zweimal = Ausschluss).

### Regel 10 — Gute Test-Scripts behalten (tmp/)
- Funktionierende Test-Scripts werden **nicht gelöscht**, sondern im
  Projektordner unter `tmp/` gespeichert (`Pro/tmp/<name>.test.sh`) und
  bei künftigen Testläufen WIEDERVERWENDET statt neu geschrieben.
- Vorhandene Sammlung: siehe TASK.md §12.

### Regel 11 — Testreihen am Bruchpunkt fortsetzen
- Bricht eine Testreihe mit Fehlern ab, wird sie nach dem Fix **an der
  Abbruchstelle fortgesetzt** — nicht die ganze Reihe von vorn.
- Voraussetzung: Tests laufen in klar benannten Abschnitten (und werden
  als Script in `tmp/` geführt, siehe Regel 10), damit die Fortsetzungs-
  position eindeutig ist. Bereits bestandene Abschnitte vor dem Bruch
  werden nicht erneut ausgeführt, solange der Fix sie nicht betreffen
  kann.

### Regel 12 — Fehlende Tools: Nutzer fragen, nicht selbst installieren
- Werden für eine Aufgabe Werkzeuge benötigt, die auf dem System nicht
  installiert sind (z. B. Bild-/Terminal-Tools, Parser-Bibliotheken,
  Paketmanager), DARF der Agent sie NICHT eigenmächtig installieren
  (kein pacman/pip/im Hintergrund) und auch keine unangekündigten
  Ersatzlösungen bauen (z. B. Abhängigkeiten manuell von Hand
  herunterladen).
- Der Agent MUST stattdessen den Nutzer fragen, ob er die benötigten
  Tools installieren kann oder will, und erst nach dessen Zustimmung
  bzw. Entscheidung weiterarbeiten.

---

## Schnellkontext (Details in TASK.md)

- Drei Truecolor-Skins: DarkGreen (Anthrazit/Hellgrün), BlueMoon
  (Dunkelblau/Hellgelb), Creamy (Sand/Schwarz statt Hellgelb).
- Installer-Modi: *(ohne)* = alles installieren, `-i SKIN` = einzeln,
  `-a SKIN` = aktivieren, `-x [DIR]` = entpacken (inkl. Anleitung.txt +
  Manual.txt), `-r DIR` = neu verpacken (Version +0.1 automatisch),
  `-de`/`-en`, `-nc`, `-h`.
- Script ist umbenennbar (Hilfe/Anleitung nutzen `basename "$0"`).
- POSIX-Only: keine Bashisms; Arithmetik per awk; `[ ]` statt `[[ ]]`.
