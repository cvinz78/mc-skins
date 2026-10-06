---
name: mc-skins-installer
description: Warten und weiterentwickeln des Midnight-Commander-Skin-Projekts in /home/baba/Pro (drei Truecolor-Skins DarkGreen/BlueMoon/Creamy + selbst-entpackendes POSIX-Installations-Script mc-skins.sh). Use when editing mc-skins.sh, the skin files, filehighlight.ini, TASK.md or when the user asks for new installer options, skin colours, or bugfixes.
---

# Midnight-Commander-Skin-Projekt fortsetzen

## Setup / Kontext laden

1. `TASK.md` lesen — lebendes Statusdokument: aktueller Stand, Versionshistorie,
   alle gefundenen/behobenen Fehler, Techniken (§3–§5).
2. `AGENTS.md` lesen — verbindliche Regeln (Backup, Version, Tests).
3. `DESIGN.md` — Farbschema der Script-Ausgaben (Cyan/Gelb/Rot/Lila/Grün).

## Projektdateien

- `mc-skins.sh` — POSIX-Installer, bettet alles ein:
  `emit_DarkGreen()`, `emit_BlueMoon()`, `emit_Creamy()`,
  `emit_filehighlight()`, `emit_Anleitung()` (de), `emit_Manual()` (en)
  — Skins/Anleitungen werden DIREKT in diesen Funktionen gepflegt.
- Externe Ziele bei Installation: `~/.local/share/mc/skins/*.ini`,
  `~/.config/mc/filehighlight.ini`, `~/.config/mc/ini`.
- Live-Skins zum Vergleich: `~/.local/share/mc/skins/` (identischer Inhalt).

## Workflow für JEDE Änderung (Reihenfolge einhalten!)

1. **Backup:** `mkdir -p old && cp -p mc-skins.sh "old/mc-skins_v<VERSION>_$(date +%Y%m%d-%H%M).sh"` — Pflicht, siehe AGENTS.md Regel 1.
2. Ändern — dabei beachten:
   - `VERSION` um **0.1** erhöhen (oben im Script; aktuell in TASK.md §7).
   - Neue Nutzer-Texte IMMER zweisprachig: de/en in `tr()` (Schlüssel-Muster:
     `msgf <key> [args…]`, Formatstrings mit `%s`).
   - Skin-Dateien: Hexcodes `#rrggbb`; Kommentare nur als eigene `#`-Zeile
     (NIEMALS hinter Werten); Farb-Legende im Kopf pflegen; Farbvermerk-
     Kommentar ÜBER jeder Farbzeile.
   - `filehighlight.ini`: `[txtfiles]` vor `[doc]`, `[regular]`
     (`regexp=.*`) bleibt LETZTE Gruppe.
   - `[Lines]`-Sektion nie entfernen; Dialog-Rahmen = Dialog-Textfarbe
     (MC-intern nicht trennbar).
   - Neue Optionen: in `usage()` (de/en) und in beiden Manuals
     (`emit_Anleitung`, `emit_Manual`) dokumentieren; Parsing in der
     `while`-Schleife im Hauptprogramm.
3. **Tests** (alle müssen grün sein; Regeln 8/9 aus AGENTS.md beachten:
   nach 2 Minuten auf Hängen prüfen, max. 5 Minuten pro Test
   (`timeout 300 …`), ein zweimal hintereinander fehlgeschlagener Test
   wird NICHT wiederholt, sondern in TASK.md „Ausgeschlossene Tests"
   notiert):
   ```sh
   sh -n mc-skins.sh                                     # Syntax
   sh mc-skins.sh -h && sh mc-skins.sh -en -h            # Hilfe beidseitig
   rm -rf /tmp/t && mkdir /tmp/t
   env -u XDG_CONFIG_HOME -u XDG_DATA_HOME HOME=/tmp/t \
       sh mc-skins.sh                                    # Vollinstallation
   diff /tmp/t/.local/share/mc/skins/Creamy.ini \
        ~/.local/share/mc/skins/Creamy.ini               # Inhalt identisch
   env -u XDG_CONFIG_HOME -u XDG_DATA_HOME HOME=/tmp/t \
       sh mc-skins.sh -i BlueMoon                        # Einzelskin
   sh mc-skins.sh -x /tmp/t/x                            # Entpacken (6 Dateien)
   sh mc-skins.sh -r /tmp/t/x                            # Repack, Version +0.1
   sh -n /tmp/t/x/mc-skins-installer.sh                  # neu erzeugtes Script
   sh mc-skins.sh -nc -h                                 # farblos
   ```
4. **Skin-Render-Check** (bei Skin-Änderungen): skin lädt ohne Fehlerdialog:
   ```sh
   script -qec "timeout 1 mc -S Creamy" /dev/null 2>&1 | grep -c "nicht parsen"   # 0 erwartet
   ```
   Bei Bedarf SGR-Sequenzen dekodieren (`cat -v`, Muster `38;2;R;G;B`) und
   gegen die Hexwerte prüfen. Distro-Tests laufen in den Docker-Klonen
   (TASK.md §10, z. B. `mc-skins-ubuntu:24.04`) — Klone nur auf
   Nutzeranweisung löschen (AGENTS.md Regel 7).
   **Fertige Test-Scripts wiederverwenden** statt neue zu schreiben:
   `Pro/tmp/*.test.sh` (Liste in TASK.md §12; Aufruf mit Start-Abschnitt
   `A|B|C|D` für Fortsetzung am Bruchpunkt, AGENTS.md Regeln 10/11).
5. **TASK.md aktualisieren:** Version (§7), neue Erkenntnisse/Fehler (§3–§5).
   TASK.md ist immer der aktuelle Stand — niemand soll raten müssen.

## Wichtige MC-Erkenntnisse (Kurzfassung, Details TASK.md §3)

- MC liest kein `LS_COLORS` — Mapping über Skin + `filehighlight.ini`.
- `[Lines]` = Rahmenzeichen; ohne sie zeichnet MC gar keine Rahmen.
- Panel-Rahmen = `[core] _default_`; normale Dateien werden über die
  Auffang-Gruppe `[regular]` (`regexp=.*`, letzter Eintrag) blau gefärbt,
  damit die Rahmenfarbe frei bleibt.
- Dialog-Rahmen = Dialog-Text (`FRAME_COLOR_NORMAL = DLG_COLOR_NORMAL`).
- Reihenfolge in `filehighlight.ini` = Priorität (erster Treffer gewinnt).
- GKeyFile: Kommentare nur eigene `#`-Zeilen, nie hinter Werten.
- Truecolor: `#rrggbb` ab MC 4.8.19 mit `COLORTERM=truecolor`; Verifikation
  über SGR `38;2;R;G;B` in der MC-Ausgabe.

## Bekannte Fallstricke (vollständige Liste TASK.md §4)

- `set -eu`: Variablen immer `${VAR:-default}`, `shift` nur nach Größe prüfen.
- `-r` in eigenem Ordner: Script liest sich über Tempkopie (`SELF_COPY`),
  nicht direkt von `$0` (Umleitung leert die Datei).
- Beim Patchen von Shell-/Python-Texten: Escapes und Leerzeichen des
  Originals zuerst verifizieren (`grep`), dann mit `assert` patchen.
- Test-Pipes mit `head` können Scripts per SIGPIPE früh abbrechen —
  Testergebnisse verfälschen.
