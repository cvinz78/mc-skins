# TASK.md — Projekt-Dokumentation & Verlauf: Midnight-Commander-Skins & Installer

Projektordner: `/home/baba/mcs/` · Script-Version: **1.5** · Stand: 2026-10-06

> **Hinweis zur Entstehung:** Diese Datei fasst seit 2026-10-06 die bisher
> getrennten Dokumente `TASK.md` (Verlauf/Fehlerhistorie) und `README.md`
> (Einstieg/Referenz) **in einem internen Statusdokument** zusammen. Die
> anwenderfreundliche GitHub-Beschreibung steht separat in `README.md`
> (mit Skin-Screenshots unter `screenshots/`). Die Originaldateien liegen
> unter `old/` (Backups vom 2026-10-06).

---

## 1. Projektübersicht

Entstanden sind drei Midnight-Commander-Skins (Truecolor, LS_COLORS-basiert)
sowie ein selbst-entpackendes POSIX-Installations-Script:

| Skin | Hintergrund | Rahmen | Besonderheit |
|---|---|---|---|
| **DarkGreen** | Anthrazit `#26262b` | Hellgrün `#00ff00` | normale Dateien Hellblau `#00b2ff` |
| **BlueMoon** | Dunkelblau `#101a33` | Hellgelb `#ffff00` | Dialoge gelb (MC-Zwang) |
| **Creamy** | Sand `#b29f77` | Schwarz `#000000` | **Hellgelb wurde durch Schwarz ersetzt** (Anforderung), normale Dateien Dunkelblau `#00008b` |

Gemeinsames LS_COLORS-Mapping (User-Vorgabe):
`di=93, fi=01;94, ex=92 (später „hell lila" #cc66ff), ln=96, *.txt=91, *.sh=92, *.py=92`

Das Script (`mc-skins.sh`, ursprünglich `install_mc_skins.sh`, umbenennbar)
bettet alle Dateien als Heredocs ein und kann: installieren, einzelne Skins
installieren (`-i`), aktivieren (`-a`), entpacken (`-x`, inkl. `Anleitung.txt`
+ `Manual.txt`), neu verpacken (`-r`, automatische Versionserhöhung),
zweisprachig (`-de`/`-en`, `LANG_MODE`), farblos (`-nc`) und zeigt Hilfe
(`-h`) mit dynamischem Script-Namen.

Design der Script-Ausgaben folgt `DESIGN.md`: Überschriften Hell Cyan,
Normaltext Hell Gelb, Fehler Hell Rot, Datei-/Befehlsangaben **Hell Lila**,
alles andere Hell Grün.

**Lizenz:** GNU GPL v3 (Datei `LICENSE`), aufgenommen 2026-10-06 für die
GitHub-Veröffentlichung. Skin-Screenshots für die GitHub-Vorschau liegen
unter `screenshots/` (Erzeugung: siehe §11.4).

## 2. Schnellstart (Anwender)

```sh
./mc-skins.sh              # alle drei Skins installieren
./mc-skins.sh -a Creamy    # einen aktivieren (MC danach neu starten!)
```
Oder im MC: **F9 → Optionen → Aussehen → Skin wählen**, dann
**F9 → Optionen → Konfiguration speichern**.
Zum Testen ohne ini-Änderung: `mc -S Creamy`.

**Voraussetzungen:** MC ≥ 4.8.19 (Truecolor), Terminal mit
`COLORTERM=truecolor`. Installiert wird Benutzer-weise nach
`~/.local/share/mc/skins/` und `~/.config/mc/` — **nicht mit sudo!**
Getestet mit MC 4.8.30–4.8.33 (S-Lang) auf Arch und Ubuntu/Debian;
Alpine (busybox ash) konstruktiv berücksichtigt.

## 3. Installer-Referenz / Feature-Matrix (mc-skins.sh v1.5)

| Option | Funktion |
|---|---|
| *(ohne)* | Alle drei Skins + `filehighlight.ini` installieren (Backup bestehender Dateien) |
| `-i SKIN` | Nur einen Skin installieren (DarkGreen, BlueMoon, Creamy; `filehighlight.ini` falls fehlend) |
| `-a SKIN` | Skin in `~/.config/mc/ini` aktivieren (Backup, Warnungen bei laufendem MC / sudo, Neustart-Hinweis) |
| `-x [DIR]` | Eingebettete Dateien entpacken: 3 Skins + `filehighlight.ini` + `Anleitung.txt` (de) + `Manual.txt` (en). Default: `./mc-skins` |
| `-r DIR` | Überarbeitete Dateien aus DIR in ein NEUES Installer-Script verpacken (Ausgabe `DIR/mc-skins-installer.sh`, Version automatisch +0.1, Tempkopie-Schutz) |
| `-de` / `-en` | Ausgabesprache (Standard de; dauerhaft auch via `LANG_MODE` oben im Script) |
| `-nc` | Script-Ausgaben ohne Farben (ältere Terminals; automatisch auch bei Pipe) |
| `-h` | Hilfe (farbig nach DESIGN.md, mit aktuellem Script-Namen und Version) |

Das Script ist **beliebig umbenennbar** — Hilfe und Anleitung nutzen
automatisch den aktuellen Namen (`basename "$0"`).

## 4. Die Skins im Detail

**Farben anpassen:** Hexcodes `#rrggbb` direkt in den Skin-Dateien ändern —
jede Farbzeile hat einen erklärenden Kommentar darüber, im Skin-Kopf steht
eine zentrale Legende. Wichtig: KEINE Kommentare hinter Wertzeilen
(GKeyFile liest sie als Teil des Wertes). Ausführlich: `Anleitung.txt`
(Abschnitt „FARBEN ANPASSEN") bzw. `Manual.txt`.

Gemeinsames Datei-Mapping (LS_COLORS-nachempfunden), umgesetzt über
`~/.config/mc/filehighlight.ini` (Gruppenreihenfolge = Priorität, erster
Treffer gewinnt; `[regular]` mit `regexp=.*` als letzte Gruppe färbt
normale Dateien und entkoppelt sie von der Rahmenfarbe):

| Typ | DarkGreen / BlueMoon | Creamy | Gruppe |
|---|---|---|---|
| Verzeichnisse | Hellgelb `#ffff00` | Schwarz `#000000` | `directory` |
| Normale Dateien | Hellblau `#00b2ff` | Dunkelblau `#00008b` | `regular` (letzte Gruppe) |
| Ausführbar | Hell Lila `#cc66ff` | wie links | `executable` |
| Symlinks | Hellcyan `#00ffff` | wie links | `symlink` |
| `*.txt` | Hellrot `#ff3333` | wie links | `txtfiles` (erste Gruppe) |
| `*.sh` / `*.py` | Hellgrün `#00ff00` | wie links | `source` |
| Archive / Devices | Magenta `#ff55ff` | wie links | `archive` / `device` / `special` |
| Dokumente | Weiß `#e8e8e8` | wie links | `doc` |
| Datenbanken | Hellrot `#ff3333` | wie links | `database` |

Panel-Auswahl: Schwarz auf Hellgrün (alle Skins). Markierte Dateien: fett.

## 5. Chronologie

1. **Skin-Wunsch:** LS_COLORS-Farben auf Schwarz, Normaltext Hellgrün.
   Recherche: MC 4.8.33 steuert Dateityp-Farben über `[filehighlight]`
   (Skin) + `filehighlight.ini` (Gruppen) → Skin `neongreen.ini` gebaut.
2. **Farb-Legende** auf Wunsch ergänzt; Kommentare wegen GKeyFile **über**
   statt hinter die Zeilen.
3. **Anthrazit statt Schwarz + Hexcodes** (`#rrggbb` statt `colorN`),
   Blau heller (`#00b2ff`), pro Zeile Farbvermerk-Kommentar.
4. **Ausführbare Dateien → Hell Lila** (`#cc66ff`).
5. **Umbenennung** in `DarkGreen` (auch der `skin=`-Eintrag in der ini).
6. **BlueMoon** (dunkelblauer Hintergrund) als Kopie mit Farb-Tausch.
7. **Unsichtbare Rahmen** gemeldet → Ursache: fehlende `[Lines]`-Sektion
   → Rahmenfarben über `_default_` + Auffang-Gruppe `regular`
   (`regexp=.*`) entkoppelt; Dialog-Rahmen = Dialog-Textfarbe (MC-Zwang).
8. **Creamy** (Sand) — zuerst zu hell, dann zu dunkel, final
   Mittelton `#b29f77`; Hellgelb→Schwarz; `*.sh`-Blau → Dunkelblau.
9. **Menü-/Buttonleisten-Lesbarkeit:** Creamy schwarz, BlueMoon
   Hellgelb, DarkGreen Hellgrün (`menuinactive` + `button`).
10. **Installer-Script** (POSIX, Alpine/Dash/Bash-kompatibel) mit
    eingebetteten Dateien.
11. **Anleitung.txt** (4 Distros: Arch, Ubuntu, Debian, Alpine).
12. **Umbenennbar + `-r` Repack** mit automatischer Versionskette.
13. **`-i` Einzelskin-Installation.**
14. **Zweisprachigkeit** (`-de` Standard / `-en`, `LANG_MODE`-Variable,
    englisches `Manual.txt`).
15. **DESIGN.md** auf Script-Ausgaben angewendet + **`-nc`** (farblos).
16. **2026-10-06:** GitHub-Vorbereitung — `LICENSE` (GPL-3.0), neue
    anwenderfreundliche `README.md`, Skin-Screenshots unter `screenshots/`
    (echte MC-Renderläufe via PTY, siehe §11.4), diese zusammengeführte
    `TASK.md`; `AGENTS.md` um Regel 12 (fehlende Tools nachfragen) ergänzt.

## 6. Technische Erkenntnisse (Midnight Commander)

1. **MC liest `LS_COLORS` nicht.** Skin-Farben + `filehighlight.ini`
   bilden das Mapping manuell nach.
2. **Skin-Sektionen (MC 4.8.33):** `[core]` (Panel + Basis), `[dialog]`,
   `[filehighlight]`, `[menu]`, `[editor]`, `[viewer]`, `[diffviewer]`,
   `[Lines]`. Ältere `[panelcontents]`-Sektion existiert nicht mehr —
   normale Dateien erben die Vordergrundfarbe von `[core] _default_`.
3. **`[Lines]` = Rahmenzeichen.** Fehlt die Sektion, zeichnet MC
   schlicht KEINE Rahmen (0 Box-Zeichen statt Fallback) — die Ränder
   sind dann unsichtbar, egal welche Farbe. (Verifiziert: Default-Skin
   308 Box-Zeichen vs. eigener Skin 0.)
4. **Panel-Rahmenfarbe = `core _default_`** (Quellcode `panel.c`:
   `tty_draw_box` nach `tty_setcolor(NORMAL_COLOR)`).
5. **Dialog-Rahmenfarbe = Dialog-Textfarbe** (Quellcode `frame.h`:
   `FRAME_COLOR_NORMAL = DLG_COLOR_NORMAL`, also `dnormal`).
   Getrennte Farben für Rahmen und Dialogtext sind nicht möglich.
6. **Datei-Endungsfärbung** über `~/.config/mc/filehighlight.ini`
   (ersetzt die Systemdatei!), Gruppen = Sektionsnamen im Skin-
   Abschnitt `[filehighlight]`. **Reihenfolge = Priorität, erster
   Treffer gewinnt** (Kommentar in der Systemdatei: hardlink zuletzt
   = „lowest precedence").
7. **Truecolor:** MC 4.8.19+ (S-Lang) versteht `#rrggbb` direkt;
   Voraussetzung: `COLORTERM=truecolor`. Test-Ausgabe: `38;2;R;G;B`.
8. **ini-Parser (GKeyFile):** Kommentare nur als eigene Zeile mit `#`
   am Zeilenanfang. Ein Kommentar HINTER einem Wert wird Teil des
   Wertes und zerstört den Skin („Kann Skin nicht parsen").
9. **MC-Ausgabe verifizieren:** Escape-Sequenzen mit `cat -v` sichtbar
   machen und SGR-Codes dekodieren (`48;2;38;38;43` = `#26262b`).

## 7. Entdeckte & behobene Fehler

| # | Fehler | Ursache | Lösung |
|---|---|---|---|
| 1 | „Kann Skin nicht parsen" | `;`-Kommentare — GKeyFile kennt nur `#` | Alle Kommentare auf `#`-Zeilen umgestellt |
| 2 | Unsichtbare Ränder in Dialogen/Panels | `[Lines]` fehlte → keine Rahmenzeichen | `[Lines]`-Sektion aus default.ini übernommen |
| 3 | Rahmenfarbe nicht separat einstellbar | Panel: `NORMAL_COLOR`; Dialog: `dnormal` | Panels: Auffang-Gruppe `[regular]` mit `regexp=.*` färbt normale Dateien blau → `_default_` frei für Rahmenfarbe. Dialoge: Textfarbe = Rahmenfarbe (dokumentierte Einschränkung) |
| 4 | `*.txt` wäre von doc-Gruppe verschluckt | Reihenfolge | Eigene `[txtfiles]`-Gruppe ganz an den Anfang der `filehighlight.ini` |
| 5 | `-x`-Test ohne Ausgabe bei 2. Lauf | Test-Artefakt: `head -4` schloss Pipe → SIGPIPE tötete Script vor filehighlight.ini | Kein Script-Fehler; Test korrigiert |
| 6 | Neonfarben auf hellem Sand unlesbar | Hintergrund zu hell | Erst dunklere Palette, dann (dunklerer Sand) Rückkehr zu Neon + Schwarz-Tausch |
| 7 | Graue Schrift in Menü-/Buttonleiste | `menuinactive`/`button` auf Grau | Creamy: Schwarz, BlueMoon: Hellgelb, DarkGreen: Hellgrün |
| 8 | `emit_Anleitung` fehlte („Kommando nicht gefunden") | Generator hatte Funktion vergessen | Funktion ergänzt |
| 9 | `-r` überschrieb sich selbst → leeres Script | `> "$OUT"` leert `$0`, wenn OUT == Script-Pfad, bevor awk liest | `SELF_COPY`-Tempkopie, awk liest Kopie |
| 10 | `-nc`: `%s`-Platzhalter leer | Farbloser Zweig nutzte `printf '%s' "$F"` statt Format-Expansion | Einheitlich `printf "$F\n" "$@"`, Farben nur drumherum |
| 11 | `NC ist nicht gesetzt` unter `set -u` | Innere Prüfung `[ "$NC" = 1 ]` bei ungesetzter Variable | `${NC:-0}` |
| 12 | `-x` ohne Verzeichnis brach ab („shift außerhalb des Bereichs") | Options-Schleife shifte ein zweites Mal bei fehlendem Argument | Argument nur bei `[ $# -gt 1 ]` übernehmen |
| 13 | Python-Generierung: String-Konkatenation kaputt | falsche Quote-Mischung | Platzhalter `__D_LINE__` + Assertion |
| 14 | Patches „griffen nicht" | Suchmuster (Backslash-Escapes, doppelte Leerzeichen) passten nicht | Erst `grep`/`sed` Originaltext verifizieren, dann mit `assert` patchen |
| 15 | `-h` wendete DESIGN.md-Farbschema nicht an | `usage()` gab reinen Text aus; `-h` lief zudem VOR der Farbentscheidung | Neue `colorize_help()`-Funktion (awk, wrapt die Heredoc-Ausgabe: Titel/„Aufruf:"=Cyan, Optionszeilen=Lila, Erklärungen=Gelb, Hinweise=Grün); `-h` setzt nur noch `ACTION="help"`, Ausführung nach der Farbentscheidung im `case` |
| 16 | `-nc -h` war trotzdem farbig | Bei `COLOR=0` waren nur `col_of` neutral, aber die Farbkonstanten blieben gefüllt und `colorize_help` erhielt sie direkt | Im `COLOR=0`-Zweig werden alle Farbkonstanten auf `""` gesetzt |
| 17 | Bericht „`-a` aktiviert den Skin nicht" (Lubuntu) | Docker-End-to-End-Test (Ubuntu 24.04, mc 4.8.30, S-Lang): ini-Eintrag und Truecolor-Rendering funktionieren korrekt. Wahrscheinlichste Ursachen beim Nutzer: Script per **sudo** ausgeführt (Skins/ini landen in `/root`), **MC lief während `-a`** (überschreibt `skin=` beim Beenden), oder Terminal ohne `COLORTERM=truecolor` (Farben quantisiert) | Gegenmaßnahmen im Script: sudo/root-Warnung (v1.4), Warnung bei laufendem MC (v1.3), Neustart-Hinweis nach `-a` (v1.4/v1.5) |
| 18 | `tr()`-Zweige `sudo_warn`/`act_restart`/`mc_running` gaben `%s`-Argumente leer aus | Bei späteren Ergänzungen fehlte das Durchreich-Muster `printf '%s' 'Text'` (printf ohne Argument verbraucht `%s` sofort) | Alle 6 Zeilen nachgerüstet (v1.5); Regel: JEDER `tr()`-Zweig muss `printf '%s' 'Text'` verwenden |
| 19 | Testaufnahmen im Docker-Container zeigten 0 Bytes | `timeout 1 mc` ohne `--foreground` nimmt MC den Terminal-Zugriff (Prozessgruppe) | In PTY-Tests immer `timeout --foreground` verwenden |

## 8. Tricks & Arbeitstechniken

1. **Farbrollen entkoppeln:** MC kennt keine „normale Datei"-Farbgruppe
   → Trick: Gruppe mit `regexp=.*` als LETZTE in `filehighlight.ini`
   fängt alle regulären Dateien; typbasierte Gruppen (directory, symlink
   …) kommen zuerst und gewinnen.
2. **Farbtausch:** Jede Farbe = Hexcode; pro Sektion genau ein Vorkommen
   → global tauschbar per `sed -i 's/#ALT/#NEU/g'`. Tipp steht im Skin-Kopf.
3. **Verifikation statt Vermutung:** MC-Ausgabe per `script -qec` (PTY)
   sammeln, SGR-Sequenzen mit grep dekodieren und gegen die gewünschten
   Hexwerte prüfen; Box-Zeichen (U+2500–U+257F) zählen für Rahmen.
4. **PTY-Fallen beim Testen:** Ohne `TIOCSWINSZ` (0×0-Fenster) und ohne
   `LANG` verhielt sich MC anders als im echten Terminal — Ergebnisse
   nur mit nachgebauter Terminal-Umgebung vertrauenswürdig.
5. **Selbst-Modifikation sicher:** Beim Repacken liest das Script seine
   eigene Struktur über eindeutige Marker (`emit_DarkGreen() {`,
   `#  Hilfsfunktionen`) mit awk — plus Tempkopie gegen Selbst-Leeren.
6. **Versionskette ohne Bash-Arithmetik:** `awk -v v="$VERSION" 'BEGIN
   { printf "%.1f", v + 0.1 }'` (POSIX, 0.9+0.1=1.0 statt Float-Rauschen).
7. **Heredoc-Technik:** Eingebettete Dateien in `emit_*()`-Funktionen
   mit quoted delimiter (`<<'__MC_SKIN_EOF__'`), damit `$`, Backticks
   und Backslashes literal bleiben; Script generierbar/selbst-modifizierbar.
8. **Dynamischer Script-Name:** `SELF=$(basename "$0")` in Hilfe und
   Anleitung-Kopfzeile → Umbenennen ohne Codeänderung.
9. **Texte extern halten:** Übersetzungen in einer `tr()`-Funktion mit
   Schlüsseln; `msgf` expandiert Formatstrings — Achtung: Texte mit
   `printf '%s' '…'` durchreichen, sonst verschluckt printf das `%s`.
10. **Farb-Auto-Off:** ANSI-Farben der Script-Ausgaben nur bei `[ -t 1 ]`
    (Terminal) — Logs bleiben sauber; `-nc` erzwingt farblos.
11. **Reihenfolge-Prinzip filehighlight.ini:** „erster Treffer gewinnt"
    — spezialisierte Gruppen (txtfiles) vor allgemeinen (doc), catch-all
    (regular) zuletzt.
12. **Screenshots ohne X-Server (2026-10-06):** MC in Python-PTY starten
    (`pty.fork` + `TIOCSWINSZ` 120×34, `TERM=xterm-256color`,
    `COLORTERM=truecolor`, `LANG=C.UTF-8`), Rohausgabe aufnehmen und mit
    `pyte` (Terminal-Emulation) + `Pillow` (Zeichnen, FreeMono, 2×)
    in PNG rendern — `tmp/mcshot-capture.py` + `tmp/mcshot-render.py`.
    Zeichentreu verifiziert gegen die Skin-Hexwerte.

## 9. Projektdateien

```
/home/baba/mcs/
├── mc-skins.sh      Installer v1.5 (Skins eingebettet als emit_*()-Funktionen)
├── README.md        GitHub-Anwenderdokumentation (mit Screenshot-Vorschau)
├── LICENSE          GNU GPL v3 (seit 2026-10-06)
├── screenshots/     Skin-Vorschauen: darkgreen.png, bluemoon.png, creamy.png
├── AGENTS.md        verbindliche Arbeitsregeln (PFLICHTLEKTÜRE vor Änderungen)
├── SKILL.md         Workflow zum Fortsetzen: Backup → Ändern → Tests → TASK.md
├── TASK.md          diese Datei: lebendes Statusdokument + Voll-Dokumentation
├── DESIGN.md        Farbschema der Script-Ausgaben (Cyan/Gelb/Rot/Lila/Grün)
├── old/             Backups: Script (Regel 1) + gesicherte alte Dokumente
└── tmp/             bewährte Test-/Werkzeug-Scripts (*.test.sh, *.py)
```

Externe, vom Script verwaltete Dateien (nicht im Projektordner):
`~/.local/share/mc/skins/{DarkGreen,BlueMoon,Creamy}.ini`,
`~/.config/mc/filehighlight.ini`, `~/.config/mc/ini`.

## 10. Für Agenten/Entwicklung: Wie das Projekt fortgesetzt wird

**Vor der Arbeit lesen:** `AGENTS.md` (Regeln 1–12), `SKILL.md`
(Workflow), diese `TASK.md` (Stand + Fehlerhistorie §6–§8).

Die fünf eisernen Regeln (Details in AGENTS.md):

1. **Backup vor jeder Script-Änderung** nach `old/`
   (`cp -p mc-skins.sh old/mc-skins_v<VER>_<Datum>.sh`).
2. **Versionsnummer +0.1** pro Änderung (`VERSION=` oben im Script;
   `-r` erhöht bei Neuverpackung automatisch).
3. **TASK.md nach jeder Änderung aktualisieren** (Version, Fehler,
   Erkenntnisse) — TASK.md ist immer der aktuelle Stand.
4. **Testpflicht** vor Abschluss — die fertigen Tests wiederverwenden
   (siehe §11).
5. **Test-Disziplin:** nach 2 Minuten auf Hängen prüfen, max. 5 Minuten
   pro Test; zweimal hintereinander fehlgeschlagen = Test ausschließen
   und in §11 notieren; Testreihe nach Fix am Bruchpunkt fortsetzen.
6. **Neu (Regel 12):** Fehlende System-Tools NICHT eigenmächtig
   installieren oder umgehen — den Nutzer fragen, ob er sie installieren
   kann/will (2026-10-06 ergänzt, ausgelöst durch die Screenshot-Tools
   python-pillow/python-pyte).

**Docker-Klone** (nur auf Nutzeranweisung löschen — „Projekt aufräumen" /
„Projekt abgeschlossen"): siehe §12.

**Technische Grundlagen** (vollständig in §6): MC liest kein LS_COLORS;
Dateifarben über Skin-`[filehighlight]` + `filehighlight.ini`;
`[Lines]` = Rahmenzeichen (ohne sie keine Rahmen!); Panel-Rahmenfarbe =
`[core] _default_`; Dialog-Rahmen = Dialog-Textfarbe; Truecolor-Verifikation
per SGR `38;2;R;G;B`.

## 11. Tests

### 11.1 Standard-Testlauf (Pflicht vor Abschluss, AGENTS.md Regel 4)

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

### 11.2 Skin-Render-Check (bei Skin-Änderungen)

```sh
script -qec "timeout --foreground 1 mc -S Creamy" /dev/null 2>&1 \
    | grep -c "nicht parsen"     # 0 erwartet
```
Bei Bedarf SGR-Sequenzen dekodieren (`cat -v`, Muster `38;2;R;G;B`) und
gegen die Hexwerte prüfen.

### 11.3 Bewährte Test-Scripts (tmp/, Regel 10)

Wiederverwenden statt neu schreiben; Aufruf mit Start-Abschnitt
(`A|B|C|D`) für Fortsetzung am Bruchpunkt (Regel 11):

| Script | Umfang |
|---|---|
| `tmp/test-local-standards.test.sh [A|B|C|D]` | A: Syntax+Hilfe (de/en) · B: Vollinstallation Fake-HOME + Diff · C: `-i` + `-x` · D: Repack-Kette |
| `tmp/test-ubuntu-fullchain.test.sh [A|B|C]` | Im Klon `mc-skins-ubuntu:24.04`: A: Installation als tester · B: `-a Creamy` · C: MC rendert Creamy Truecolor (SGR-Check) |
| `tmp/mcshot-capture.py` | PTY-Aufnahme der MC-Hauptansicht pro Skin (Rohbytes, 120×34, Truecolor) |
| `tmp/mcshot-render.py` | Rendert die Rohaufnahmen nach `screenshots/*.png` (pyte + Pillow, FreeMono, 2×) |

### 11.4 Screenshot-Pipeline (seit 2026-10-06)

Voraussetzungen: `python-pillow`, `python-pyte` (Arch-Repos; gemäß
AGENTS.md Regel 12 auf Nutzerzustimmung installiert). Ablauf:

1. Fake-HOME + Showcase-Ordner mit repräsentativen Dateien anlegen
   (Verzeichnisse, Symlink, `*.txt`, `*.sh`/`*.py` teils ausführbar,
   `*.png`, `*.jpg`, `*.zip`, `*.pdf`, `*.sql`) — Farben demonstrieren.
2. `HOME=<fake> sh mc-skins.sh -nc` (Skins per Script installieren).
3. `python3 tmp/mcshot-capture.py` → `raw_<Skin>.bin` (je ~2,5 s PTY).
4. `python3 tmp/mcshot-render.py` → `screenshots/*.png` (2160×1224).
5. Visuell prüfen: Rahmenfarbe, Menüleiste, Datei-Farbgebung, Auswahlbalken.

### 11.5 Ausgeschlossene Tests (Regel 8)

Tests, die zweimal hintereinander fehlgeschlagen/abgebrochen sind und
deshalb NICHT mehr wiederholt werden:

*(aktuell keine — die Liste wird bei Bedarf hier eingetragen: Testname,
Grund, Datum)*

Test-Timeouts gelten gemäß AGENTS.md Regel 9: Nach 2 Minuten Laufzeit
Status prüfen (läuft/hängt), harte Obergrenze 5 Minuten pro Test
(`timeout 300`).

## 12. Docker-Testklone

Für Distro-Tests (Arch ≠ Ubuntu ≠ Alpine) werden Container-Images als
**Klone** vorgehalten, damit apt-Downloads und Setup nicht bei jedem Test
neu laufen:

- `mc-skins-ubuntu:24.04` — Ubuntu 24.04 + mc 4.8.30 (S-Lang) + Testbenutzer
  `tester` (Passwort-los per `su tester -c`). Einsatz:
  `docker run --rm -v /home/baba/mcs:/proj:ro mc-skins-ubuntu:24.04 bash /pfad/zum/test.sh`
- Der Alpine-Klon folgt bei Bedarf nach demselben Muster.

**Löschregel:** Die Klone werden NUR auf ausdrückliche Nutzeranweisung
entfernt („Projekt aufräumen" oder „Projekt abgeschlossen" → `docker rmi
mc-skins-ubuntu:24.04`).

**Status 2026-10-05 (Projekt abgeschlossen):** Klone entfernt
(`mc-skins-ubuntu:24.04`, Base-Image `ubuntu:24.04`). Bei Fortsetzung auf
einem anderen Rechner Klon neu aufbauen:
`docker run -d --name build ubuntu:24.04 sleep infinity && docker exec build
bash -c "apt-get update && apt-get install -y mc util-linux && useradd -m tester"
&& docker commit build mc-skins-ubuntu:24.04` — `old/` wird bei der ersten
Änderung automatisch wieder angelegt (AGENTS.md Regel 1).

Test-Hinweis: In PTY-Tests innerhalb von Containern `timeout --foreground`
verwenden (siehe Fehler 19) und immer als Testbenutzer (`su tester -c`)
statt als root testen — sudo-Szenarien gezielt mit `SUDO_USER=… sh mc-skins.sh …`
simulieren.

## 13. Bekannte Einschränkungen

- Truecolor nötig für die Original-Skinfarben (`COLORTERM=truecolor`);
  ältere Terminals brauchen die `-nc`-Variante nur für die Script-Ausgabe,
  nicht für die Skins selbst (Hexfarben werden vom Terminal quantisiert
  bzw. falsch angezeigt).
- Dialog-Rahmenfarbe = Dialog-Textfarbe (MC-intern nicht trennbar).
- `-a` aktiviert logisch genau einen Skin (MC zeigt immer nur einen an) —
  kein Fehler, sondern MC-Verhalten.
- Getestet unter Arch (bash als `sh`); Alpine (busybox ash)/dash wurden
  konstruktiv berücksichtigt (POSIX-only, `awk` statt Bash-Arithmetik),
  aber nicht nativ ausgeführt.
- Symlinks mit `*.txt`-Endung erscheinen rot (nicht cyan): `[txtfiles]`
  steht in `filehighlight.ini` bewusst vor `[symlink]` — erster Treffer
  gewinnt (Design-Entscheidung, LS_COLORS-Verhalten).

## 14. Fehlerbehebung (Kurzzeiger für Anwender)

| Symptom | Siehe |
|---|---|
| Skin wird nicht sichtbar / alte Farben | MC neu starten; lief MC während `-a`? Script per sudo? → Script warnt jetzt |
| „Kann Skin nicht parsen" | Kommentar hinter Wertzeile? Datei unvollständig? |
| Alles grau/16-Farben | `COLORTERM=truecolor` gesetzt? Terminal fähig? |
| Dateien alle gleichfarbig | `~/.config/mc/filehighlight.ini` fehlt oder Panel-Option „Dateien hervorheben" aus |
| Skin nicht gefunden | `ls ~/.local/share/mc/skins/` — Name exakt (Groß-/Kleinschreibung) |

Details und weitere Fälle: `Anleitung.txt`/`Manual.txt` (entpackbar per
`-x`, Abschnitt „FEHLERBEHEBUNG") und §7 dieser Datei.

## 15. Versionshistorie mc-skins.sh

- **0.7** — Start der Nummerierung (DarkGreen)
- **0.8** — `-i` Einzelskin-Installation
- **0.9** — zweisprachig (de/en, `LANG_MODE`, `Manual.txt`)
- **1.0** — DESIGN.md-Farben + `-nc`
- **1.1** — `-x`-Fix (SIGPIPE-Testartefakt behoben)
- **1.2** — Hilfe farbig nach DESIGN.md; `-h` wird erst nach der
  Farbentscheidung ausgeführt; Farbkonstanten werden bei `-nc`/Pipe geleert
- **1.3** — Warnung bei laufendem MC in `-a`
- **1.4** — sudo/root-Warnung + Neustart-Hinweis nach `-a`
- **1.5** — Fix: `tr()`-Zweige ohne `printf '%s'`-Durchreich-Muster durften
  keine `%s`-Argumente mehr; Neustart-Hinweis auch bei neu angelegter ini;
  Ubuntu-Verifikation per Docker-Klon

*(Änderungen an Dokumenten/Screenshots ändern die Script-Version nicht —
nur Änderungen an `mc-skins.sh`, siehe AGENTS.md Regel 2.)*

## 16. Dokumentationshistorie

- **2026-10-05:** `TASK.md` + `README.md` angelegt; `AGENTS.md` (Regeln 1–11)
  und `SKILL.md` für die Projektübernahme eingerichtet.
- **2026-10-06:** GitHub-Vorbereitung: `LICENSE` (GPL-3.0) ergänzt; neue
  anwenderorientierte `README.md` (mit `screenshots/`-Vorschau); bisherige
  `TASK.md`+`README.md` zu dieser Datei zusammengeführt (Originale in
  `old/`); `AGENTS.md` um Regel 12 erweitert; Screenshot-Pipeline in
  `tmp/` hinterlegt (§11.3/§11.4).
