#!/bin/sh
# =====================================================================
#  Midnight-Commander-Skin-Installer (selbst-entpackend, umbenennbar)
#
#  Installiert die Skins DarkGreen, BlueMoon und Creamy inklusive der
#  benoetigten filehighlight.ini in die Benutzer-Konfiguration.
#
#  POSIX-Shell-Script (keine Bashisms) - laeuft unter Alpine Linux
#  (busybox ash), Debian/Ubuntu (dash) und Arch Linux (bash).
#
#  Voraussetzungen:  Midnight Commander >= 4.8.19 und ein Terminal
#  mit Truecolor (echo $COLORTERM sollte "truecolor" melden).
#
#  Das Script darf beliebig umbenannt werden; Hilfe (-h) und die
#  entpackte Anleitung.txt nennen automatisch den aktuellen Namen.
#
#  VERSIONEN: Die Versionsnummer steht in der Variable VERSION unten.
#  Sie muss bei JEDER Bearbeitung des Scripts um 0.1 erhoehen (bei
#  manueller Bearbeitung von Hand eintragen; das -r-Kommando erhoehrt
#  sie beim Neuverpacken automatisch).
# =====================================================================
set -eu

# ---------------------------------------------------------------------
#  SPRACHE / LANGUAGE:  hier dauerhaft umstellen - "de" oder "en"
#  (Per Aufruf ueberschreibbar mit den Schaltern -de bzw. -en.)
# ---------------------------------------------------------------------
LANG_MODE="de"

VERSION="1.5"

# ---------------------------------------------------------------------
#  Farbschema der Script-Ausgaben (siehe DESIGN.md):
#  Ueberschriften=Hell Cyan, Normaltext=Hell Gelb, Fehler=Hell Rot,
#  Datei-/Befehlsangaben=Hell Lila, alles andere=Hell Gruen.
#  Deaktivierbar mit -nc (fuer aeltere Terminals) bzw. automatisch,
#  wenn die Ausgabe kein Terminal ist.
# ---------------------------------------------------------------------
CYAN_H=$(printf '\033[1;96m')
YELLOW_H=$(printf '\033[1;93m')
RED_H=$(printf '\033[1;91m')
MAGENTA_L=$(printf '\033[1;35m')
GREEN_O=$(printf '\033[1;92m')
RESET=$(printf '\033[0m')
COLOR=1

SKINS="DarkGreen BlueMoon Creamy"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
SKIN_DIR="$DATA_DIR/mc/skins"
FH_FILE="$CFG_DIR/mc/filehighlight.ini"
MC_INI="$CFG_DIR/mc/ini"
D="__MC_SKIN_EOF__"

# Hilfe nach DESIGN.md einfaerben:
#   Zeile 1 + Abschnittsheader = Hell Cyan
#   Optionszeilen (2 Leerzeichen + Befehl) = Hell Lila
#   eingerueckte Erklaerungen = Hell Gelb
#   Rest (Hinweise) = Hell Gruen
# Bei COLOR=0 werden leere Farbargumente uebergeben -> reiner Text.
colorize_help() {
    awk -v C="$1" -v M="$2" -v Y="$3" -v G="$4" -v R="$5" '
        C == "" { print; next }
        NR == 1 { printf "%s%s%s\n", C, $0, R; next }
        /^Aufruf:/ || /^Usage:/ { printf "%s%s%s\n", C, $0, R; next }
        /^  [^ ]/ { printf "%s%s%s\n", M, $0, R; next }
        /^ / { printf "%s%s%s\n", Y, $0, R; next }
        $0 != "" { printf "%s%s%s\n", G, $0, R; next }
        { print }
    '
}

usage() {
    if [ "$LANG_MODE" = "en" ]; then
        cat <<USAGE_EN | colorize_help "$CYAN_H" "$MAGENTA_L" "$YELLOW_H" "$GREEN_O" "$RESET"
${SELF} - Version ${VERSION}
          Installer for the Midnight Commander skins
          DarkGreen, BlueMoon and Creamy

Usage:
  ${SELF}              Install all three skins
  ${SELF} -de          German output (default)
  ${SELF} -nc          No colours in the script output (for older
                       terminals; also automatic when the output is
                       not a terminal)
  ${SELF} -en          English output
  ${SELF} -x [DIR]     Extract the embedded files into DIR
                       (default: ./mc-skins), incl. Anleitung.txt and
                       Manual.txt
  ${SELF} -a SKIN      Activate a skin (DarkGreen | BlueMoon | Creamy)
  ${SELF} -i SKIN      Install only this single skin (filehighlight.ini
                       is installed too, if not yet present)
  ${SELF} -r DIR       Pack the edited files from DIR into a NEW
                       installer script. The folder must contain:
                       DarkGreen.ini, BlueMoon.ini, Creamy.ini,
                       filehighlight.ini - Anleitung.txt/Manual.txt
                       optional (otherwise the built-in version is
                       used). Output: DIR/mc-skins-installer.sh
  ${SELF} -h           This help

The script may be renamed freely; the help adapts automatically.
The language can also be set permanently in the variable LANG_MODE
at the top of this script.
USAGE_EN
    else
        cat <<USAGE_DE | colorize_help "$CYAN_H" "$MAGENTA_L" "$YELLOW_H" "$GREEN_O" "$RESET"
${SELF} - Version ${VERSION}
          Installer fuer die Midnight-Commander-Skins
          DarkGreen, BlueMoon und Creamy

Aufruf:
  ${SELF}              Alle drei Skins installieren
  ${SELF} -de          Ausgabe auf Deutsch (Standard)
  ${SELF} -nc          Ohne Farben in den Script-Ausgaben (fuer
                       aeltere Terminals; automatisch auch aktiv,
                       wenn die Ausgabe kein Terminal ist)
  ${SELF} -en          Ausgabe auf Englisch
  ${SELF} -x [DIR]     Eingebettete Dateien nach DIR entpacken
                       (Standard: ./mc-skins), inkl. Anleitung.txt
                       und Manual.txt
  ${SELF} -a SKIN      Skin aktivieren (DarkGreen | BlueMoon | Creamy)
  ${SELF} -i SKIN      Nur diesen einen Skin installieren (Datei-Farben
                       filehighlight.ini wird mit installiert, falls
                       noch nicht vorhanden)
  ${SELF} -r DIR       Ueberarbeitete Dateien aus DIR in ein NEUES
                       Installer-Script verpacken. Im Ordner muessen
                       liegen: DarkGreen.ini, BlueMoon.ini,
                       Creamy.ini, filehighlight.ini - Anleitung.txt/
                       Manual.txt optional (sonst wird die eingebaute
                       Version verwendet).
                       Ausgabe: DIR/mc-skins-installer.sh
  ${SELF} -h           Diese Hilfe

Das Script ist beliebig umbenennbar, die Hilfe passt sich an.
Die Sprache laesst sich auch dauerhaft in der Variable LANG_MODE
oben im Script einstellen.
USAGE_DE
    fi
    exit 0
}

msg() { printf '%s\n' "$*"; }

tr() {
    K="$1"
    if [ "$LANG_MODE" = "en" ]; then
        case "$K" in
            installing)   printf '%s' 'Installing Midnight Commander skins ...' ;;
            skin_dir)     printf '%s' '  Skin directory  : %s' ;;
            colors_dir)   printf '%s' '  File colours    : %s' ;;
            installed)    printf '%s' '  installed: %s' ;;
            fh_installed) printf '%s' '  installed: %s (needed for file colouring)' ;;
            fh_present)   printf '%s' '  present (left unchanged): %s' ;;
            backup)       printf '%s' '  Existing file backed up: %s' ;;
            done_head)    printf '%s' 'Done. Activate with:' ;;
            done_test)    printf '%s' '  mc -S DarkGreen        (or BlueMoon / Creamy, for testing)' ;;
            done_menu)    printf '%s' '  permanently: start mc -> F9 -> Options -> Appearance -> skin,' ;;
            done_menu2)   printf '%s' '             then F9 -> Options -> Save configuration' ;;
            done_a)       printf '%s' '  or call this script with -a SKIN (see -h).' ;;
            extracted)    printf '%s' '  extracted: %s' ;;
            packed_from)  printf '%s' 'Extracted from: %s (script version %s)' ;;
            manual_see)   printf '%s' 'Manual installation: see %s' ;;
            manual_short) printf '%s' '  (short version: skins -> %s, filehighlight.ini -> %s)' ;;
            delim_err)    printf '%s' 'Error: %s contains the internal delimiter pattern %s' ;;
            one_start)    printf '%s' 'Installing single skin: %s' ;;
            act_test)     printf '%s' 'Activate: mc -S %s (testing only)' ;;
            act_perm)     printf '%s' '            this script with -a %s (permanent)' ;;
            err_name_i)   printf '%s' 'Error: -i expects one of these names: %s' ;;
            err_name_a)   printf '%s' 'Error: -a expects one of these names: %s' ;;
            ini_created)  printf '%s' 'New %s created, skin=%s set.' ;;
            activated)    printf '%s' 'Activated: skin=%s in %s' ;;
            err_dir)      printf '%s' 'Error: directory %s does not exist.' ;;
            err_missing)  printf '%s' 'Error: %s missing - -r needs all four files.' ;;
            man_missing)  printf '%s' '  Manual missing in %s - using the built-in version.' ;;
            overwrite)    printf '%s' '  Overwriting existing %s' ;;
            repacked)     printf '%s' 'New installer script created: %s (version %s)' ;;
            repack_test)  printf '%s' 'Test: %s -h   or   %s -x /some/other/folder' ;;
            err_unknown)  printf '%s' 'Unknown option: %s' ;;
            nc_on)       printf '%s' 'Script output colours disabled (-nc).' ;;
            sudo_warn)   printf '%s' 'WARNING: script run via sudo/root - skins go to %s.\n            Run WITHOUT sudo for your own user account!' ;;
            act_restart) printf '%s' 'Restart MC so that skin %s takes effect.' ;;
            mc_running)  printf '%s' 'WARNING: MC is currently running - quit MC first,\n            otherwise it rewrites the old skin= on exit!' ;;
            *)            printf '%s' '' ;;
        esac
    else
        case "$K" in
            installing)   printf '%s' 'Installiere Midnight-Commander-Skins ...' ;;
            skin_dir)     printf '%s' '  Skin-Verzeichnis : %s' ;;
            colors_dir)   printf '%s' '  Datei-Farben     : %s' ;;
            installed)    printf '%s' '  installiert: %s' ;;
            fh_installed) printf '%s' '  installiert: %s (fuer die Datei-Faerbung noetig)' ;;
            fh_present)   printf '%s' '  vorhanden (unveraendert gelassen): %s' ;;
            backup)       printf '%s' '  Bestehende Datei gesichert: %s' ;;
            done_head)    printf '%s' 'Fertig. Aktivieren mit:' ;;
            done_test)    printf '%s' '  mc -S DarkGreen        (oder BlueMoon / Creamy, zum Testen)' ;;
            done_menu)    printf '%s' '  dauerhaft: mc oeffnen -> F9 -> Optionen -> Aussehen -> Skin,' ;;
            done_menu2)   printf '%s' '             dann F9 -> Optionen -> Konfiguration speichern' ;;
            done_a)       printf '%s' '  oder dieses Script mit -a SKIN aufrufen (siehe -h).' ;;
            extracted)    printf '%s' '  entpackt: %s' ;;
            packed_from)  printf '%s' 'Entpackt aus: %s (Script-Version %s)' ;;
            manual_see)   printf '%s' 'Manuelle Installation: siehe %s' ;;
            manual_short) printf '%s' '  (Kurzfassung: Skins -> %s, filehighlight.ini -> %s)' ;;
            delim_err)    printf '%s' 'Fehler: %s enthaelt das interne Begrenzer-Muster %s' ;;
            one_start)    printf '%s' 'Installiere einzelnen Skin: %s' ;;
            act_test)     printf '%s' 'Aktivieren: mc -S %s (nur zum Testen)' ;;
            act_perm)     printf '%s' '            dieses Script mit -a %s (dauerhaft)' ;;
            err_name_i)   printf '%s' 'Fehler: -i erwartet einen der Namen: %s' ;;
            err_name_a)   printf '%s' 'Fehler: -a erwartet einen der Namen: %s' ;;
            ini_created)  printf '%s' 'Neue %s angelegt, skin=%s gesetzt.' ;;
            activated)    printf '%s' 'Aktiviert: skin=%s in %s' ;;
            err_dir)      printf '%s' 'Fehler: Verzeichnis %s existiert nicht.' ;;
            err_missing)  printf '%s' 'Fehler: %s fehlt - -r braucht alle vier Dateien.' ;;
            man_missing)  printf '%s' '  Anleitung.txt fehlt in %s - verwende die eingebaute Version.' ;;
            overwrite)    printf '%s' '  Ueberschreibe bestehendes %s' ;;
            repacked)     printf '%s' 'Neues Installer-Script erzeugt: %s (Version %s)' ;;
            repack_test)  printf '%s' 'Test: %s -h   oder   %s -x /ein/anderer/ordner' ;;
            err_unknown)  printf '%s' 'Unbekannte Option: %s' ;;
            nc_on)       printf '%s' 'Farben der Script-Ausgaben deaktiviert (-nc).' ;;
            sudo_warn)   printf '%s' 'WARNUNG: Script per sudo/root ausgefuehrt - Skins landen in %s.\n            Fuer dein Benutzerkonto OHNE sudo ausfuehren!' ;;
            act_restart) printf '%s' 'MC (neu) starten, damit der Skin %s erscheint.' ;;
            mc_running)  printf '%s' 'WARNUNG: MC laeuft gerade - beende MC zuerst, sonst\n            schreibt es beim Beenden die alte skin= zurueck!' ;;
            *)            printf '%s' '' ;;
        esac
    fi
}

# Farb-Kategorie je Meldungsschluessel (DESIGN.md):
#   Hell Cyan = Ueberschriften, Hell Rot = Fehler/Warnungen,
#   Hell Lila = Datei-/Befehlsangaben, Hell Gelb = Normaltext,
#   Hell Gruen = alles andere
col_of() {
    K="$1"
    if [ "$COLOR" -ne 1 ]; then
        return
    fi
    case "$K" in
        delim_err|err_*|overwrite) printf '%s' "$RED_H" ;;
        installing|done_head|repacked) printf '%s' "$CYAN_H" ;;
        skin_dir|colors_dir|installed|fh_installed|fh_present|backup|packed_from|extracted|manual_see|manual_short|ini_created|activated) printf '%s' "$MAGENTA_L" ;;
        done_test|done_menu|done_menu2|done_a|act_test|act_perm|repack_test|man_missing) printf '%s' "$GREEN_O" ;;
        *) printf '%s' "$YELLOW_H" ;;
    esac
}

msgf() {
    K="$1"; shift
    F=$(tr "$K")
    C=$(col_of "$K")
    if [ -n "$C" ]; then
        printf '%s' "$C"
    fi
    printf "$F\n" "$@"
    if [ -n "$C" ]; then
        printf '%s' "$RESET"
    fi
}

emit_DarkGreen() {
    cat <<'__MC_SKIN_EOF__'
[skin]
    description = DarkGreen - Neongruen auf Anthrazit (LS_COLORS-Mapping, Truecolor)

# =====================================================================
#  FARB-Legende - alle Farben als Hexcode, beliebig austauschbar
#
#  >>> Farbe aendern = Hexcode an der jeweiligen Stelle ersetzen <<<
#  MC-Syntax: #rrggbb (Standard-HTML-Hexfarbe) oder kurz #rgb
#
#  ZENTRALE FARBEN:
#  -----------------------------------------------------------------
#  HINTERGRUND (Anthrazit) ............ #26262b
#  HELLGRUEN (normaler Text) .......... #00ff00
#  HELLLILA (ausfuehrbar, ex) ......... #cc66ff
#  HELLBLAU (normale Dateien fi=94) ... #00b2ff
#  HELLGELB (Verzeichnisse di=93) ..... #ffff00
#  HELLCYAN (Symlinks ln=96) .......... #00ffff
#  HELLROT (*.txt=91, Fehler) ......... #ff3333
#  MAGENTA (Devices, Archive) ......... #ff55ff
#  GRAU (deaktiviert, temp) ........... #909095
#  WEISS (doc, Hilfe-Links) ........... #e8e8e8
#  SCHWARZ (Text auf Auswahl) ......... #000000
#  ABGEDUNKELT (Schatten, Eingabefelder) #0e0e11
#
#  Wichtig: Keine Kommentare HINTER einen Wert schreiben (z. B.
#  "key = #00ff00    ; gruen") - der ini-Parser wuerde das als Teil
#  des Farbwerts lesen und den Skin zerstoeren. Farbvermerke stehen
#  deshalb immer in der Kommentarzeile UBER der jeweiligen Zeile.
#
#  Tipp: Ein Hexcode laesst sich mit Suchen&Ersetzen global tauschen,
#  z. B.:  sed -i 's/#26262b/#2a2a30/g' ~/.local/share/mc/skins/DarkGreen.ini
#
#  Voraussetzung: Terminal mit Truecolor (pruefen: echo $COLORTERM
#  sollte "truecolor" oder "24bit" melden - moderne Terminal-
#  Emulatoren tun das von Haus aus).
# =====================================================================

[Lines]
    horiz = ─
    vert = │
    lefttop = ┌
    righttop = ┐
    leftbottom = └
    rightbottom = ┘
    topmiddle = ┬
    bottommiddle = ┴
    leftmiddle = ├
    rightmiddle = ┤
    cross = ┼
    dhoriz = ─
    dvert = │
    dlefttop = ┌
    drighttop = ┐
    dleftbottom = └
    drightbottom = ┘
    dtopmiddle = ┬
    dbottommiddle = ┴
    dleftmiddle = ├
    drightmiddle = ┤

[core]
    # fg hellgruen (Rahmen/Umrandungen der Panels) | bg Anthrazit
    _default_ = #00ff00;#26262b
    # fg schwarz | bg hellgruen (Cursorbalken auf Auswahl)
    selected = #000000;#00ff00
    # fg helligelb (di=93) | bg Anthrazit, fett (markierte Dateien)
    marked = #ffff00;#26262b;bold
    # fg helligelb | bg hellgruen (markiert + Cursor)
    markselect = #ffff00;#00ff00;bold
    # fg hellgruen | bg abgedunkelt (Kopier-Fortschrittsbalken)
    gauge = #00ff00;#0e0e11
    # fg hellgruen | bg abgedunkelt (Eingabefelder)
    input = #00ff00;#0e0e11
    # fg grau | bg abgedunkelt (unveraenderte Eingabefelder)
    inputunchanged = #909095;#0e0e11
    # fg schwarz | bg grau (Markierung in Eingabefeldern)
    inputmark = #000000;#909095
    # fg grau | bg Anthrazit (deaktivierte Elemente)
    disabled = #909095;#26262b
    # fg schwarz | bg hellgruen (invertierte Anzeige)
    reverse = #000000;#00ff00
    # fg schwarz | bg helligelb (Befehlszeilen-Markierung)
    commandlinemark = #000000;#ffff00
    # fg hellgruen, fett | bg Anthrazit (Panel-Kopfzeile)
    header = #00ff00;#26262b;bold
    # fg grau | bg abgedunkelt (Schatten unter Fenstern)
    shadow = #50505a;#0e0e11
    inputhistory =
    commandhistory =

[dialog]
    # fg hellgruen | bg Anthrazit (Dialog-Grundfarbe, normaler Text)
    _default_ = #00ff00;#26262b
    # fg schwarz | bg hellgruen (fokussiertes Dialog-Element)
    dfocus = #000000;#00ff00
    # fg helligelb | bg Anthrazit (Hotkey-Taste, nicht fokussiert)
    dhotnormal = #ffff00;#26262b
    # fg schwarz | bg hellgruen, unterstrichen (Hotkey, fokussiert)
    dhotfocus = #000000;#00ff00;underline
    # fg hellcyan | bg Anthrazit (Dialog-Titel)
    dtitle = #00ffff;#26262b

[error]
    # fg weiss | bg dunkelrot (Fehlerfenster)
    _default_ = #ffffff;#a00000
    # fg schwarz | bg weiss (Fokus im Fehlerfenster)
    errdfocus = #000000;#e8e8e8
    # fg helligelb | bg dunkelrot (Hotkey, nicht fokussiert)
    errdhotnormal = #ffff00;#a00000
    # fg helligelb | bg weiss (Hotkey, fokussiert)
    errdhotfocus = #ffff00;#e8e8e8
    # fg helligelb | bg dunkelrot (Fehler-Titel)
    errdtitle = #ffff00;#a00000

# --- Dateitypen: 1:1-Mapping der LS_COLORS ---------------------------
# Reihenfolge in filehighlight.ini entscheidet: erster Treffer gewinnt.
[filehighlight]
    # *.txt = 91 -> hellrot
    txtfiles = #ff3333;
    # di = 93 -> helligelb (Verzeichnisse)
    directory = #ffff00;
    # ex -> hell lila (ausfuehrbare Dateien)
    executable = #cc66ff;
    # ln = 96 -> hellcyan (Symlinks)
    symlink = #00ffff;
    # defekter Symlink -> hellrot
    stalelink = #ff3333;
    # Geraetedateien -> magenta
    device = #ff55ff;
    # Spezialdateien (Sockets, FIFOs) -> magenta
    special = #ff55ff;
    # Core-Dumps -> hellrot
    core = #ff3333;
    # temporaere Dateien -> grau
    temp = #909095;
    # Archive -> magenta
    archive = #ff55ff;
    # Dokumente -> weiss
    doc = #e8e8e8;
    # *.sh und *.py = 92 -> hellgruen (Quelltexte)
    source = #00ff00;
    # Medien -> hellcyan
    media = #00ffff;
    # Grafiken -> hellcyan
    graph = #00ffff;
    # Datenbanken -> hellrot
    database = #ff3333;
    # normale Dateien (fi=94) -> hellblau (Auffanggruppe, siehe [regular]
    # in filehighlight.ini; dadurch bleiben Rahmen gruen, Dateien blau)
    regular = #00b2ff;

[menu]
    # fg hellgruen | bg Anthrazit (Menueleiste, normaler Text)
    _default_ = #00ff00;#26262b
    # fg schwarz | bg hellgruen (ausgewaehlter Menuepunkt)
    menusel = #000000;#00ff00
    # fg helligelb | bg Anthrazit (Hotkey-Buchstabe)
    menuhot = #ffff00;#26262b
    # fg schwarz | bg hellgruen, fett (Hotkey im ausgew. Punkt)
    menuhotsel = #000000;#00ff00;bold
    # fg hellgruen | bg Anthrazit (inaktives Menue - Links, Datei, Befehl ...)
    menuinactive = #00ff00;#26262b

[popupmenu]
    # fg hellgruen | bg Anthrazit (Popup-Menue, normaler Text)
    _default_ = #00ff00;#26262b
    # fg schwarz | bg hellgruen (ausgewaehlter Punkt)
    menusel = #000000;#00ff00
    # fg helligelb | bg Anthrazit (Popup-Titel)
    menutitle = #ffff00;#26262b

[buttonbar]
    # fg hellgruen, fett | bg Anthrazit (F1-F10 Ziffern)
    hotkey = #00ff00;#26262b;bold
    # fg hellgruen | bg Anthrazit (F1-F10 Beschriftung - Hilfe, Menue, Ansicht ...)
    button = #00ff00;#26262b

[statusbar]
    # fg hellgruen | bg Anthrazit (Statuszeile, normaler Text)
    _default_ = #00ff00;#26262b

[help]
    # fg hellgruen | bg Anthrazit (Hilfe, normaler Text)
    _default_ = #00ff00;#26262b
    # fg hellcyan | bg Anthrazit (kursiv betonter Text)
    helpitalic = #00ffff;#26262b
    # fg helligelb | bg Anthrazit (fett betonter Text)
    helpbold = #ffff00;#26262b
    # fg weiss, unterstrichen | bg Anthrazit (Verweise)
    helplink = #e8e8e8;#26262b;underline
    # fg schwarz | bg hellgruen (ausgewaehlter Verweis)
    helpslink = #000000;#00ff00
    # fg helligelb | bg Anthrazit (Hilfe-Titel)
    helptitle = #ffff00;#26262b

[editor]
    # fg hellgruen | bg Anthrazit (Editor, normaler Text)
    _default_ = #00ff00;#26262b
    # fg helligelb | bg Anthrazit (fetter Text im Editor)
    editbold = #ffff00;#26262b
    # fg schwarz | bg hellgruen (markierter Text)
    editmarked = #000000;#00ff00
    # fg grau | bg Anthrazit (Sichtbarmachung von Leerzeichen)
    editwhitespace = #50505a;#26262b
    # fg magenta | bg Anthrazit (nicht druckbare Zeichen)
    editnonprintable = #ff55ff;#26262b
    # fg grau | bg Anthrazit (Zeilenstatus-Spalte)
    editlinestate = #909095;#26262b
    # fg helligelb, unterstrichen | bg Anthrazit (Lesezeichen)
    bookmark = #ffff00;#26262b;underline
    # fg schwarz | bg hellgruen (gefundene Stelle)
    bookmarkfound = #000000;#00ff00
    # fg hellrot | bg Anthrazit (rechter Rand-Ueberlauf)
    editrightmargin = #ff3333;#26262b
    # fg hellgruen | bg Anthrazit (aktiver Rahmen)
    editframeactive = #00ff00;
    # fg helligelb | bg Anthrazit (Rahmen beim Verschieben)
    editframedrag = #ffff00;

[viewer]
    # fg hellgruen | bg Anthrazit (Viewer, normaler Text)
    _default_ = #00ff00;#26262b
    # fg helligelb, fett | bg Anthrazit (fetter Text)
    viewbold = #ffff00;#26262b;bold
    # fg hellcyan, unterstrichen | bg Anthrazit (unterstr. Text)
    viewunderline = #00ffff;#26262b;underline
    # fg schwarz | bg hellgruen (Auswahl im Viewer)
    viewselected = #000000;#00ff00

[diffviewer]
    # fg hellgruen | bg Anthrazit (hinzugefuegte Zeilen)
    added = #00ff00;#26262b
    # fg helligelb | bg Anthrazit (geaenderte Zeilen)
    changedline = #ffff00;#26262b
    # fg hellcyan | bg Anthrazit (neue Teilabschnitte)
    changednew = #00ffff;#26262b
    # fg hellcyan | bg Anthrazit (geaenderte Teilabschnitte)
    changed = #00ffff;#26262b
    # fg hellrot | bg Anthrazit (entfernte Zeilen)
    removed = #ff3333;#26262b
    # fg weiss | bg dunkelrot (Fehler)
    error = #ffffff;#a00000
__MC_SKIN_EOF__
}

emit_BlueMoon() {
    cat <<'__MC_SKIN_EOF__'
[skin]
    description = BlueMoon - Neongruen auf Dunkelblau (LS_COLORS-Mapping, Truecolor)

# =====================================================================
#  FARB-Legende - alle Farben als Hexcode, beliebig austauschbar
#
#  >>> Farbe aendern = Hexcode an der jeweiligen Stelle ersetzen <<<
#  MC-Syntax: #rrggbb (Standard-HTML-Hexfarbe) oder kurz #rgb
#
#  ZENTRALE FARBEN:
#  -----------------------------------------------------------------
#  HINTERGRUND (Dunkelblau) ............ #101a33
#  HELLGRUEN (normaler Text) .......... #00ff00
#  HELLLILA (ausfuehrbar, ex) ......... #cc66ff
#  HELLBLAU (normale Dateien fi=94) ... #00b2ff
#  HELLGELB (Verzeichnisse di=93) ..... #ffff00
#  HELLCYAN (Symlinks ln=96) .......... #00ffff
#  HELLROT (*.txt=91, Fehler) ......... #ff3333
#  MAGENTA (Devices, Archive) ......... #ff55ff
#  GRAU (deaktiviert, temp) ........... #909095
#  WEISS (doc, Hilfe-Links) ........... #e8e8e8
#  SCHWARZ (Text auf Auswahl) ......... #000000
#  ABGEDUNKELT (Schatten, Eingabefelder) #0a1224
#
#  Wichtig: Keine Kommentare HINTER einen Wert schreiben (z. B.
#  "key = #00ff00    ; gruen") - der ini-Parser wuerde das als Teil
#  des Farbwerts lesen und den Skin zerstoeren. Farbvermerke stehen
#  deshalb immer in der Kommentarzeile UBER der jeweiligen Zeile.
#
#  Tipp: Ein Hexcode laesst sich mit Suchen&Ersetzen global tauschen,
#  z. B.:  sed -i 's/#101a33/#2a2a30/g' ~/.local/share/mc/skins/BlueMoon.ini
#
#  Voraussetzung: Terminal mit Truecolor (pruefen: echo $COLORTERM
#  sollte "truecolor" oder "24bit" melden - moderne Terminal-
#  Emulatoren tun das von Haus aus).
# =====================================================================

[Lines]
    horiz = ─
    vert = │
    lefttop = ┌
    righttop = ┐
    leftbottom = └
    rightbottom = ┘
    topmiddle = ┬
    bottommiddle = ┴
    leftmiddle = ├
    rightmiddle = ┤
    cross = ┼
    dhoriz = ─
    dvert = │
    dlefttop = ┌
    drighttop = ┐
    dleftbottom = └
    drightbottom = ┘
    dtopmiddle = ┬
    dbottommiddle = ┴
    dleftmiddle = ├
    drightmiddle = ┤

[core]
    # fg hellgelb (Rahmen/Umrandungen der Panels) | bg Dunkelblau
    _default_ = #ffff00;#101a33
    # fg schwarz | bg hellgruen (Cursorbalken auf Auswahl)
    selected = #000000;#00ff00
    # fg helligelb (di=93) | bg Dunkelblau, fett (markierte Dateien)
    marked = #ffff00;#101a33;bold
    # fg helligelb | bg hellgruen (markiert + Cursor)
    markselect = #ffff00;#00ff00;bold
    # fg hellgruen | bg abgedunkelt (Kopier-Fortschrittsbalken)
    gauge = #00ff00;#0a1224
    # fg hellgruen | bg abgedunkelt (Eingabefelder)
    input = #00ff00;#0a1224
    # fg grau | bg abgedunkelt (unveraenderte Eingabefelder)
    inputunchanged = #909095;#0a1224
    # fg schwarz | bg grau (Markierung in Eingabefeldern)
    inputmark = #000000;#909095
    # fg grau | bg Dunkelblau (deaktivierte Elemente)
    disabled = #909095;#101a33
    # fg schwarz | bg hellgruen (invertierte Anzeige)
    reverse = #000000;#00ff00
    # fg schwarz | bg helligelb (Befehlszeilen-Markierung)
    commandlinemark = #000000;#ffff00
    # fg hellgruen, fett | bg Dunkelblau (Panel-Kopfzeile)
    header = #00ff00;#101a33;bold
    # fg grau | bg abgedunkelt (Schatten unter Fenstern)
    shadow = #50505a;#0a1224
    inputhistory =
    commandhistory =

[dialog]
    # fg hellgelb | bg Dunkelblau (Dialog-Rahmen und Dialog-Text - teilen
    # sich in MC zwangsweise eine Farbe, daher ist der ganze Dialog gelb)
    _default_ = #ffff00;#101a33
    # fg schwarz | bg hellgruen (fokussiertes Dialog-Element)
    dfocus = #000000;#00ff00
    # fg hellcyan | bg Dunkelblau (Hotkey-Taste, nicht fokussiert)
    dhotnormal = #00ffff;#101a33
    # fg schwarz | bg hellgruen, unterstrichen (Hotkey, fokussiert)
    dhotfocus = #000000;#00ff00;underline
    # fg hellcyan | bg Dunkelblau (Dialog-Titel)
    dtitle = #00ffff;#101a33

[error]
    # fg weiss | bg dunkelrot (Fehlerfenster)
    _default_ = #ffffff;#a00000
    # fg schwarz | bg weiss (Fokus im Fehlerfenster)
    errdfocus = #000000;#e8e8e8
    # fg helligelb | bg dunkelrot (Hotkey, nicht fokussiert)
    errdhotnormal = #ffff00;#a00000
    # fg helligelb | bg weiss (Hotkey, fokussiert)
    errdhotfocus = #ffff00;#e8e8e8
    # fg helligelb | bg dunkelrot (Fehler-Titel)
    errdtitle = #ffff00;#a00000

# --- Dateitypen: 1:1-Mapping der LS_COLORS ---------------------------
# Reihenfolge in filehighlight.ini entscheidet: erster Treffer gewinnt.
[filehighlight]
    # *.txt = 91 -> hellrot
    txtfiles = #ff3333;
    # di = 93 -> helligelb (Verzeichnisse)
    directory = #ffff00;
    # ex -> hell lila (ausfuehrbare Dateien)
    executable = #cc66ff;
    # ln = 96 -> hellcyan (Symlinks)
    symlink = #00ffff;
    # defekter Symlink -> hellrot
    stalelink = #ff3333;
    # Geraetedateien -> magenta
    device = #ff55ff;
    # Spezialdateien (Sockets, FIFOs) -> magenta
    special = #ff55ff;
    # Core-Dumps -> hellrot
    core = #ff3333;
    # temporaere Dateien -> grau
    temp = #909095;
    # Archive -> magenta
    archive = #ff55ff;
    # Dokumente -> weiss
    doc = #e8e8e8;
    # *.sh und *.py = 92 -> hellgruen (Quelltexte)
    source = #00ff00;
    # Medien -> hellcyan
    media = #00ffff;
    # Grafiken -> hellcyan
    graph = #00ffff;
    # Datenbanken -> hellrot
    database = #ff3333;
    # normale Dateien (fi=94) -> hellblau (Auffanggruppe, siehe [regular]
    # in filehighlight.ini; dadurch bleiben Rahmen gelb, Dateien blau)
    regular = #00b2ff;

[menu]
    # fg hellgruen | bg Dunkelblau (Menueleiste, normaler Text)
    _default_ = #00ff00;#101a33
    # fg schwarz | bg hellgruen (ausgewaehlter Menuepunkt)
    menusel = #000000;#00ff00
    # fg helligelb | bg Dunkelblau (Hotkey-Buchstabe)
    menuhot = #ffff00;#101a33
    # fg schwarz | bg hellgruen, fett (Hotkey im ausgew. Punkt)
    menuhotsel = #000000;#00ff00;bold
    # fg hellgelb | bg Dunkelblau (inaktives Menue - Links, Datei, Befehl ...)
    menuinactive = #ffff00;#101a33

[popupmenu]
    # fg hellgelb | bg Dunkelblau (Popup-Menue + Rahmen)
    _default_ = #ffff00;#101a33
    # fg schwarz | bg hellgruen (ausgewaehlter Punkt)
    menusel = #000000;#00ff00
    # fg helligelb | bg Dunkelblau (Popup-Titel)
    menutitle = #ffff00;#101a33

[buttonbar]
    # fg hellgruen, fett | bg Dunkelblau (F1-F10 Ziffern)
    hotkey = #00ff00;#101a33;bold
    # fg hellgelb | bg Dunkelblau (F1-F10 Beschriftung - Hilfe, Menue, Ansicht ...)
    button = #ffff00;#101a33

[statusbar]
    # fg hellgruen | bg Dunkelblau (Statuszeile, normaler Text)
    _default_ = #00ff00;#101a33

[help]
    # fg hellgelb | bg Dunkelblau (Hilfe-Rahmen + Text)
    _default_ = #ffff00;#101a33
    # fg hellcyan | bg Dunkelblau (kursiv betonter Text)
    helpitalic = #00ffff;#101a33
    # fg helligelb | bg Dunkelblau (fett betonter Text)
    helpbold = #ffff00;#101a33
    # fg weiss, unterstrichen | bg Dunkelblau (Verweise)
    helplink = #e8e8e8;#101a33;underline
    # fg schwarz | bg hellgruen (ausgewaehlter Verweis)
    helpslink = #000000;#00ff00
    # fg helligelb | bg Dunkelblau (Hilfe-Titel)
    helptitle = #ffff00;#101a33

[editor]
    # fg hellgruen | bg Dunkelblau (Editor, normaler Text)
    _default_ = #00ff00;#101a33
    # fg helligelb | bg Dunkelblau (fetter Text im Editor)
    editbold = #ffff00;#101a33
    # fg schwarz | bg hellgruen (markierter Text)
    editmarked = #000000;#00ff00
    # fg grau | bg Dunkelblau (Sichtbarmachung von Leerzeichen)
    editwhitespace = #50505a;#101a33
    # fg magenta | bg Dunkelblau (nicht druckbare Zeichen)
    editnonprintable = #ff55ff;#101a33
    # fg grau | bg Dunkelblau (Zeilenstatus-Spalte)
    editlinestate = #909095;#101a33
    # fg helligelb, unterstrichen | bg Dunkelblau (Lesezeichen)
    bookmark = #ffff00;#101a33;underline
    # fg schwarz | bg hellgruen (gefundene Stelle)
    bookmarkfound = #000000;#00ff00
    # fg hellrot | bg Dunkelblau (rechter Rand-Ueberlauf)
    editrightmargin = #ff3333;#101a33
    # fg hellgelb | bg Dunkelblau (aktiver Rahmen)
    editframeactive = #ffff00;
    # fg helligelb | bg Dunkelblau (Rahmen beim Verschieben)
    editframedrag = #ffff00;

[viewer]
    # fg hellgruen | bg Dunkelblau (Viewer, normaler Text)
    _default_ = #00ff00;#101a33
    # fg helligelb, fett | bg Dunkelblau (fetter Text)
    viewbold = #ffff00;#101a33;bold
    # fg hellcyan, unterstrichen | bg Dunkelblau (unterstr. Text)
    viewunderline = #00ffff;#101a33;underline
    # fg schwarz | bg hellgruen (Auswahl im Viewer)
    viewselected = #000000;#00ff00

[diffviewer]
    # fg hellgruen | bg Dunkelblau (hinzugefuegte Zeilen)
    added = #00ff00;#101a33
    # fg helligelb | bg Dunkelblau (geaenderte Zeilen)
    changedline = #ffff00;#101a33
    # fg hellcyan | bg Dunkelblau (neue Teilabschnitte)
    changednew = #00ffff;#101a33
    # fg hellcyan | bg Dunkelblau (geaenderte Teilabschnitte)
    changed = #00ffff;#101a33
    # fg hellrot | bg Dunkelblau (entfernte Zeilen)
    removed = #ff3333;#101a33
    # fg weiss | bg dunkelrot (Fehler)
    error = #ffffff;#a00000
__MC_SKIN_EOF__
}

emit_Creamy() {
    cat <<'__MC_SKIN_EOF__'
[skin]
    description = Creamy - Neongruen auf dunklem Sand (Truecolor)

# =====================================================================
#  FARB-Legende - alle Farben als Hexcode, beliebig austauschbar
#
#  >>> Farbe aendern = Hexcode an der jeweiligen Stelle ersetzen <<<
#  MC-Syntax: #rrggbb (Standard-HTML-Hexfarbe) oder kurz #rgb
#
#  BESONDERHEIT VON CREAMY: Wo die anderen Skins HELLGELB (#000000)
#  verwenden, steht hier SCHWARZ (#000000).
#
#  ZENTRALE FARBEN:
#  -----------------------------------------------------------------
#  HINTERGRUND (Sand-Mittenton) .......... #b29f77
#  SAND DUNKLER (Schatten, Eingabefelder) #8f7d57
#  SCHWARZ (statt Hellgelb: Rahmen, Dialoge,
#          Menues, Verzeichnisse, Markierung) #000000
#  HELLGRUEN (normaler Text) .......... #00ff00
#  DUNKELBLAU (normale Dateien, fi=94) .. #00008b
#  HELLLILA (ausfuehrbare Dateien) .... #cc66ff
#  HELLCYAN (Symlinks, Hotkeys) ....... #00ffff
#  HELLROT (*.txt, Fehler) ............ #ff3333
#  MAGENTA (Devices, Archive) ......... #ff55ff
#  GRAU (deaktiviert, temp) ........... #909095
#  WEISS (Dokumente, Hilfe-Links) ..... #e8e8e8
#  SAND-HELL (Text auf schwarz) ....... #e8d8b0
#
#  Tipp: Ein Hexcode laesst sich mit Suchen&Ersetzen global tauschen,
#  z. B.:  sed -i 's/#b29f77/#a08c5e/g' ~/.local/share/mc/skins/Creamy.ini
#
#  Voraussetzung: Terminal mit Truecolor (pruefen: echo $COLORTERM).
# =====================================================================

[Lines]
    horiz = ─
    vert = │
    lefttop = ┌
    righttop = ┐
    leftbottom = └
    rightbottom = ┘
    topmiddle = ┬
    bottommiddle = ┴
    leftmiddle = ├
    rightmiddle = ┤
    cross = ┼
    dhoriz = ─
    dvert = │
    dlefttop = ┌
    drighttop = ┐
    dleftbottom = └
    drightbottom = ┘
    dtopmiddle = ┬
    dbottommiddle = ┴
    dleftmiddle = ├
    drightmiddle = ┤

[core]
    # fg schwarz (Rahmen/Umrandungen der Panels) | bg Sand
    _default_ = #000000;#b29f77
    # fg schwarz | bg hellgruen (Cursorbalken auf Auswahl)
    selected = #000000;#00ff00
    # fg schwarz (di=93) | bg Sand, fett (markierte Dateien)
    marked = #000000;#b29f77;bold
    # fg schwarz | bg hellgruen (markiert + Cursor)
    markselect = #000000;#00ff00;bold
    # fg hellgruen | bg abgedunkelt (Kopier-Fortschrittsbalken)
    gauge = #00ff00;#8f7d57
    # fg hellgruen | bg abgedunkelt (Eingabefelder)
    input = #00ff00;#8f7d57
    # fg grau | bg abgedunkelt (unveraenderte Eingabefelder)
    inputunchanged = #909095;#8f7d57
    # fg schwarz | bg grau (Markierung in Eingabefeldern)
    inputmark = #000000;#909095
    # fg grau | bg Sand (deaktivierte Elemente)
    disabled = #909095;#b29f77
    # fg schwarz | bg hellgruen (invertierte Anzeige)
    reverse = #000000;#00ff00
    # fg schwarz | bg schwarz (Befehlszeilen-Markierung)
    commandlinemark = #e8d8b0;#000000
    # fg hellgruen, fett | bg Sand (Panel-Kopfzeile)
    header = #00ff00;#b29f77;bold
    # fg grau | bg abgedunkelt (Schatten unter Fenstern)
    shadow = #50505a;#8f7d57
    inputhistory =
    commandhistory =

[dialog]
    # fg schwarz | bg Sand (Dialog-Rahmen und Dialog-Text - teilen
    # sich in MC zwangsweise eine Farbe, daher ist der ganze Dialog gelb)
    _default_ = #000000;#b29f77
    # fg schwarz | bg hellgruen (fokussiertes Dialog-Element)
    dfocus = #000000;#00ff00
    # fg hellcyan | bg Sand (Hotkey-Taste, nicht fokussiert)
    dhotnormal = #00ffff;#b29f77
    # fg schwarz | bg hellgruen, unterstrichen (Hotkey, fokussiert)
    dhotfocus = #000000;#00ff00;underline
    # fg hellcyan | bg Sand (Dialog-Titel)
    dtitle = #00ffff;#b29f77

[error]
    # fg weiss | bg dunkelrot (Fehlerfenster)
    _default_ = #ffffff;#a00000
    # fg schwarz | bg weiss (Fokus im Fehlerfenster)
    errdfocus = #000000;#e8e8e8
    # fg schwarz | bg dunkelrot (Hotkey, nicht fokussiert)
    errdhotnormal = #000000;#a00000
    # fg schwarz | bg weiss (Hotkey, fokussiert)
    errdhotfocus = #000000;#e8e8e8
    # fg schwarz | bg dunkelrot (Fehler-Titel)
    errdtitle = #000000;#a00000

# --- Dateitypen: 1:1-Mapping der LS_COLORS ---------------------------
# Reihenfolge in filehighlight.ini entscheidet: erster Treffer gewinnt.
[filehighlight]
    # *.txt = 91 -> hellrot
    txtfiles = #ff3333;
    # Verzeichnisse -> schwarz (Creamy-Besonderheit, sonst hellgelb)
    directory = #000000;
    # ex -> hell lila (ausfuehrbare Dateien)
    executable = #cc66ff;
    # ln = 96 -> hellcyan (Symlinks)
    symlink = #00ffff;
    # defekter Symlink -> hellrot
    stalelink = #ff3333;
    # Geraetedateien -> magenta
    device = #ff55ff;
    # Spezialdateien (Sockets, FIFOs) -> magenta
    special = #ff55ff;
    # Core-Dumps -> hellrot
    core = #ff3333;
    # temporaere Dateien -> grau
    temp = #909095;
    # Archive -> magenta
    archive = #ff55ff;
    # Dokumente -> weiss
    doc = #e8e8e8;
    # *.sh und *.py = 92 -> hellgruen (Quelltexte)
    source = #00ff00;
    # Medien -> hellcyan
    media = #00ffff;
    # Grafiken -> hellcyan
    graph = #00ffff;
    # Datenbanken -> hellrot
    database = #ff3333;
    # normale Dateien (fi=94) -> hellblau (Auffanggruppe, siehe [regular]
    # in filehighlight.ini; dadurch bleiben Rahmen gelb, Dateien blau)
    regular = #00008b;

[menu]
    # fg hellgruen | bg Sand (Menueleiste, normaler Text)
    _default_ = #00ff00;#b29f77
    # fg schwarz | bg hellgruen (ausgewaehlter Menuepunkt)
    menusel = #000000;#00ff00
    # fg schwarz | bg Sand (Hotkey-Buchstabe)
    menuhot = #000000;#b29f77
    # fg schwarz | bg hellgruen, fett (Hotkey im ausgew. Punkt)
    menuhotsel = #000000;#00ff00;bold
    # fg schwarz | bg Sand (inaktives Menue - Links, Datei, Befehl ...)
    menuinactive = #000000;#b29f77

[popupmenu]
    # fg schwarz | bg Sand (Popup-Menue + Rahmen)
    _default_ = #000000;#b29f77
    # fg schwarz | bg hellgruen (ausgewaehlter Punkt)
    menusel = #000000;#00ff00
    # fg schwarz | bg Sand (Popup-Titel)
    menutitle = #000000;#b29f77

[buttonbar]
    # fg hellgruen, fett | bg Sand (F1-F10 Ziffern)
    hotkey = #00ff00;#b29f77;bold
    # fg schwarz | bg Sand (F1-F10 Beschriftung - Hilfe, Menue, Ansicht ...)
    button = #000000;#b29f77

[statusbar]
    # fg hellgruen | bg Sand (Statuszeile, normaler Text)
    _default_ = #00ff00;#b29f77

[help]
    # fg schwarz | bg Sand (Hilfe-Rahmen + Text)
    _default_ = #000000;#b29f77
    # fg hellcyan | bg Sand (kursiv betonter Text)
    helpitalic = #00ffff;#b29f77
    # fg schwarz | bg Sand (fett betonter Text)
    helpbold = #000000;#b29f77
    # fg weiss, unterstrichen | bg Sand (Verweise)
    helplink = #e8e8e8;#b29f77;underline
    # fg schwarz | bg hellgruen (ausgewaehlter Verweis)
    helpslink = #000000;#00ff00
    # fg schwarz | bg Sand (Hilfe-Titel)
    helptitle = #000000;#b29f77

[editor]
    # fg hellgruen | bg Sand (Editor, normaler Text)
    _default_ = #00ff00;#b29f77
    # fg schwarz | bg Sand (fetter Text im Editor)
    editbold = #000000;#b29f77
    # fg schwarz | bg hellgruen (markierter Text)
    editmarked = #000000;#00ff00
    # fg grau | bg Sand (Sichtbarmachung von Leerzeichen)
    editwhitespace = #50505a;#b29f77
    # fg magenta | bg Sand (nicht druckbare Zeichen)
    editnonprintable = #ff55ff;#b29f77
    # fg grau | bg Sand (Zeilenstatus-Spalte)
    editlinestate = #909095;#b29f77
    # fg schwarz, unterstrichen | bg Sand (Lesezeichen)
    bookmark = #000000;#b29f77;underline
    # fg schwarz | bg hellgruen (gefundene Stelle)
    bookmarkfound = #000000;#00ff00
    # fg hellrot | bg Sand (rechter Rand-Ueberlauf)
    editrightmargin = #ff3333;#b29f77
    # fg schwarz | bg Sand (aktiver Rahmen)
    editframeactive = #000000;
    # fg schwarz | bg Sand (Rahmen beim Verschieben)
    editframedrag = #000000;

[viewer]
    # fg hellgruen | bg Sand (Viewer, normaler Text)
    _default_ = #00ff00;#b29f77
    # fg schwarz, fett | bg Sand (fetter Text)
    viewbold = #000000;#b29f77;bold
    # fg hellcyan, unterstrichen | bg Sand (unterstr. Text)
    viewunderline = #00ffff;#b29f77;underline
    # fg schwarz | bg hellgruen (Auswahl im Viewer)
    viewselected = #000000;#00ff00

[diffviewer]
    # fg hellgruen | bg Sand (hinzugefuegte Zeilen)
    added = #00ff00;#b29f77
    # fg schwarz | bg Sand (geaenderte Zeilen)
    changedline = #000000;#b29f77
    # fg hellcyan | bg Sand (neue Teilabschnitte)
    changednew = #00ffff;#b29f77
    # fg hellcyan | bg Sand (geaenderte Teilabschnitte)
    changed = #00ffff;#b29f77
    # fg hellrot | bg Sand (entfernte Zeilen)
    removed = #ff3333;#b29f77
    # fg weiss | bg dunkelrot (Fehler)
    error = #ffffff;#a00000
__MC_SKIN_EOF__
}

emit_filehighlight() {
    cat <<'__MC_SKIN_EOF__'
# Dateigruppen fuer den Skin "neongreen".
# Die REIHENFOLGE entscheidet: der erste zutreffende Eintrag gewinnt.
# "txtfiles" steht bewusst ganz oben, damit *.txt vor der allgemeinen
# doc-Gruppe greift (LS_COLORS: *.txt=91).

[txtfiles]
    extensions=txt

[executable]
    type=FILE_EXE

[directory]
    type=DIR

[device]
    type=DEVICE

[special]
    type=SPECIAL

[stalelink]
    type=STALE_LINK

[symlink]
    type=SYMLINK

[core]
    regexp=^core\\.*\\d*$
    extensions_case=true

[temp]
    extensions=~;$$$;bak;part;tmp
    regexp=(^#.*|.*~$)

[archive]
    extensions=7z;Z;ace;apk;arc;arj;ark;bz2;cab;cpio;deb;gz;lha;lz;lz4;lzh;lzma;lzo;rar;rpm;tar;tbz;tbz2;tgz;tlz;txz;tzo;tzst;vsix;xz;zip;zoo;zst

[doc]
    extensions=chm;css;ctl;diz;doc;docm;docx;dtd;fodg;fodp;fods;fodt;htm;html;json;letter;lsm;mail;man;markdown;md;me;mkd;msg;nroff;odg;odp;ods;odt;pdf;po;ppt;pptm;pptx;ps;rtf;sgml;shtml;tex;text;xls;xlsm;xlsx;xml;xsd;xslt

# Nur sh/py wie im LS_COLORS (92). Andere Quelltext-Endungen (c, js, ...)
# fallen durch auf "normale Datei" (hellblau, wie fi=01;94).
# Willst du mehr gruen haben, Endungen hier einfach ergaenzen.
[source]
    extensions=sh;py

[media]
    extensions=3gp;aac;ac3;ape;asf;avi;awb;dts;flac;flv;it;m3u;m4a;m4v;med;mid;midi;mkv;mod;mol;mov;mp2;mp3;mp4;mpeg;mpg;mpl;ogg;ogv;opus;s3m;ts;umx;vob;wav;webm;wma;wmv;xm;y4m

[graph]
    extensions=ai;avif;bmp;cdr;eps;gif;heic;heif;ico;jp2;jpeg;jpg;jxl;omf;pcx;pic;png;psb;psd;rle;svg;tga;tif;tiff;webp;wmf;xbm;xcf;xpm

[database]
    extensions=cdx;dat;db;dbf;dbi;dbx;fox;mdb;mdn;mdx;msql;mssql;pgsql;sql;ssql

# Auffanggruppe fuer alle uebrigen Dateien (= normale Dateien, fi=94).
# Muss als LETZTES stehen, da der erste zutreffende Eintrag gewinnt -
# so bleiben Verzeichnisse/Links/Archive etc. von ihren Gruppen gefaerbt
# und nur "normale" Dateien bekommen die Farbe aus dem Skin ([filehighlight]
# -> regular = hellblau). Dadurch koennen die Panel-Rahmen eine eigene
# Farbe haben (hellgruen bzw. hellgelb).
[regular]
    regexp=.*
__MC_SKIN_EOF__
}

emit_Anleitung() {
    cat <<'__MC_SKIN_EOF__'
CREAMY / DARKGREEN / BLUEMOON - MIDNIGHT COMMANDER SKINS
========================================================
Anleitung zur manuellen Installation unter Arch, Ubuntu, Debian
und Alpine Linux.

INHALT DIESES VERZEICHNISSES
----------------------------
  DarkGreen.ini        Skin: Neongruen auf Anthrazit
  BlueMoon.ini         Skin: Neongruen auf Dunkelblau (gelbe Rahmen)
  Creamy.ini           Skin: Neongruen auf Sand (schwarze Rahmen)
  filehighlight.ini    Datei-Farbwahl (*.txt rot, *.sh/*.py gruen,
                       normale Dateien hellblau, Auffang-Gruppe "regular")
                       DIESE DATEI IST PFLICHT - ohne sie fehlt die
                       Endungs-Faerbung der Dateien!

VORAUSSETZUNGEN
---------------
  1. Midnight Commander 4.8.19 oder neuer (Truecolor-Skins)
  2. Terminal mit Truecolor-Unterstuetzung. Pruefen:
         echo $COLORTERM
     -> sollte "truecolor" oder "24bit" melden (koennen die meisten
        modernen Terminal-Emulatoren: GNOME Terminal, Konsole,
        xterm, alacritty, kitty, foot, ...).
  3. Falls die Farben falsch/graustufig aussehen:
         export COLORTERM=truecolor
         export TERM=xterm-256color

SCHRITT 1: MIDNIGHT COMMANDER INSTALLIEREN
------------------------------------------
  Arch Linux:
      sudo pacman -S --needed mc

  Ubuntu:
      sudo apt update
      sudo apt install mc

  Debian:
      sudo apt update
      sudo apt install mc
      (bei altem Debian < 10 ist mc evtl. zu alt fuer Truecolor-Skins)

  Alpine Linux:
      sudo apk add mc
      (ohne sudo, als root angemeldet: einfach "apk add mc")
      Hinweis: busybox ash ist vollkommen ausreichend, alle Skins
      funktionieren auch in reinen ash-Umgebungen.

SCHRITT 2: SKIN-DATEIEN KOPIEREN (bei allen 4 Distros identisch)
----------------------------------------------------------------
  Die Skins gehoeren in das persoenliche Skin-Verzeichnis, die
  filehighlight.ini in das persoenliche mc-Konfigurationsverzeichnis:

      mkdir -p ~/.local/share/mc/skins
      cp DarkGreen.ini BlueMoon.ini Creamy.ini ~/.local/share/mc/skins/
      mkdir -p ~/.config/mc
      cp filehighlight.ini ~/.config/mc/

  WICHTIG: Die ~/.config/mc/filehighlight.ini ERSETZT die zentrale
  Systemdatei (/etc/mc bzw. /usr/share/mc). Existiert dort schon eine
  eigene, vorher sichern:
      cp ~/.config/mc/filehighlight.ini ~/.config/mc/filehighlight.ini.mein

  Wer die Dateien systemweit fuer alle Benutzer installieren will
  (Root-Rechte noetig):
      cp DarkGreen.ini BlueMoon.ini Creamy.ini /usr/share/mc/skins/
      (die filehighlight.ini gehoert NUR benutzerweit nach ~/.config/mc,
       da sie sonst die System-Defaults aller Nutzer ersetzt)

SCHRITT 3: SKIN AKTIVIEREN
--------------------------
  Variante A - dauerhaft ueber das Menue (empfohlen):
      mc starten
      F9 -> Optionen -> Aussehen -> gewuenschten Skin waehlen
      F9 -> Optionen -> Konfiguration speichern

  Variante B - nur zum Testen:
      mc -S DarkGreen        (oder: mc -S BlueMoon / mc -S Creamy)

  Variante C - von Hand in der Datei ~/.config/mc/ini:
      In der Sektion [Midnight-Commander] die Zeile setzen/aendern:
          skin=DarkGreen
      (MC vorher beenden, sonst schreibt er die ini beim Beenden
       wieder zurueck)

DESIGN-UEBERBLICK
-----------------
  DarkGreen : Hintergrund #26262b (Anthrazit), Rahmen hellgruen,
              normale Dateien hellblau #00b2ff, ausfuehrbar helllila
  BlueMoon  : Hintergrund #101a33 (Dunkelblau), Rahmen hellgelb,
              normale Dateien hellblau, ausfuehrbar helllila
  Creamy    : Hintergrund #b29f77 (Sand), Rahmen schwarz (statt
              hellgelb), normale Dateien dunkelblau #00008b,
              ausfuehrbar helllila #cc66ff

  Gemeinsam (LS_COLORS-Mapping): Verzeichnisse hellgelb bzw. schwarz
  (Creamy), Symlinks hellcyan, *.txt hell- bzw. dunkelrot, *.sh und
  *.py hellgruen.

DAS INSTALLATIONSSCRIPT
-----------------------
Das Script, das diese Dateien entpackt hat, ist selbst-entpackend
und kann BELIEBIG UMBENANNT werden - die Hilfe passt sich dem
aktuellen Namen automatisch an. Aufrufe (unabhaengig vom Namen):

  ./<scriptname>.sh              Alle drei Skins installieren
  ./<scriptname>.sh -x [DIR]     Dateien entpacken (dabei entsteht
                                 diese Anleitung.txt), Standard DIR
                                 ist ./mc-skins
  ./<scriptname>.sh -a SKIN      Skin in der mc-ini aktivieren
  ./<scriptname>.sh -i SKIN      Nur diesen einen Skin installieren
                                 (filehighlight.ini wird mit installiert,
                                 falls noch nicht vorhanden)
  ./<scriptname>.sh -r DIR       Ueberarbeitete Dateien aus DIR in
                                 ein NEUES Installer-Script verpacken;
                                 Ausgabe: DIR/mc-skins-installer.sh
                                 (im Ordner muessen liegen:
                                 DarkGreen.ini, BlueMoon.ini,
                                 Creamy.ini, filehighlight.ini -
                                 Anleitung.txt optional, sonst wird
                                 die eingebaute verwendet)
  ./<scriptname>.sh -h           Hilfe mit aktuellem Script-Namen
  ./<scriptname>.sh -de          Ausgabe auf Deutsch (Standard)
  ./<scriptname>.sh -en          Ausgabe auf Englisch
  Die Sprache laesst sich auch dauerhaft oben im Script in der
  Variable LANG_MODE einstellen ("de" oder "en").

FARBEN ANPASSEN (HEXCODES)
--------------------------
Jede Farbe ist in den Skin-Dateien als Hexcode im MC-Format hinterlegt:

    #rrggbb     Standard-HTML-Schreibweise (z. B. #00ff00 = Hellgruen)
    #rgb        Kurzform (#0f0 entspricht #00ff00)

Jede Skin-Datei hat im Kopf eine FARB-Legende mit allen zentral
verwendeten Farben und ihrer Bedeutung (Hintergrund, Rahmen, normale
Dateien, Verzeichnisse, ...). Vor jeder Farbzeile steht ein Kommentar,
der die Farbe erklaert, z. B.:

    # fg hellgruen (Rahmen/Umrandungen der Panels) | bg Anthrazit
    _default_ = #00ff00;#26262b

Das Zeilenformat ist:  Vordergrund;Hintergrund[;Attribute]
Attribute sind: bold, underline, reverse, blink. Ein leerer
Hintergrund (z. B. "directory = #ffff00;") erbt den Panel-Hintergrund.

Drei Regeln:
  1. Nur die Hexcodes aendern, nicht die Struktur der Datei.
  2. KEINE Kommentare HINTER eine Wertzeile schreiben! MC liest
     "key = #00ff00  ; gruen" als Farbe "#00ff00  ; gruen" und
     verwirft den Skin komplett. Kommentare immer als eigene Zeile,
     beginnend mit #.
  3. Nach jeder Aenderung testen:  mc -S Skinname

Beispiele:

  a) Einzelne Stelle aendern: in der Skin-Datei den Hexcode an der
     passenden (kommentierten) Stelle ersetzen, z. B. Verzeichnisse
     in Creamy von schwarz auf grau:
         directory = #000000;   ->   directory = #606060;

  b) Eine Farbe global tauschen (alle Vorkommen auf einmal):
         sed -i 's/#b29f77/#c9b58a/g' Creamy.ini

  c) Farbwert aus einem anderen Skin uebernehmen: den Hexcode in
     dessen Legende ablesen und an der gewuenschten Stelle eintragen.

Nach dem Bearbeiten entweder die geaenderte Datei direkt nach
~/.local/share/mc/skins/ kopieren (mc liest den Skin beim Start neu
ein) oder mit dem Installer-Kommando -r die ueberarbeiteten Dateien
wieder in ein neues Script verpacken (siehe DAS
INSTALLATIONSSCRIPT). Wenn Farben trotz richtigem Hexcode nicht
ankommen: Terminal muss Truecolor koennen, siehe VORAUSSETZUNGEN.

FEHLERBEHEBUNG
--------------
  - "Kann Skin nicht parsen": Datei unvollstaendig/korrupt kopiert,
    oder es wurde ein Kommentar HINTER einen Farbwert geschrieben
    (MC erlaubt nur Kommentarzeilen, die mit # BEGINNEN).
  - Alles grau/schwarz-weiss: Terminal unterstuetzt kein Truecolor,
    siehe VORAUSSETZUNGEN Punkt 2/3.
  - Dateien alle gleichfarben: fehlt die ~/.config/mc/filehighlight.ini,
    oder ist in den Panel-Optionen "Dateien hervorheben" (F9 ->
    Optionen -> Panels) deaktiviert.
  - Skin wird nicht gefunden: Pfad pruefen mit
      ls ~/.local/share/mc/skins/
    Der Dateiname (ohne .ini) muss exakt dem Skin-Namen entsprechen
    (Gross-/Kleinschreibung: DarkGreen, BlueMoon, Creamy).
__MC_SKIN_EOF__
}

emit_Manual() {
    cat <<'__MC_SKIN_EOF__'
CREAMY / DARKGREEN / BLUEMOON - MIDNIGHT COMMANDER SKINS
========================================================
Manual for manual installation on Arch, Ubuntu, Debian and
Alpine Linux.

CONTENTS OF THIS FOLDER
-----------------------
  DarkGreen.ini        Skin: neon green on anthracite
  BlueMoon.ini         Skin: neon green on dark blue (yellow frames)
  Creamy.ini           Skin: neon green on sand (black frames)
  filehighlight.ini    File colouring (*.txt red, *.sh/*.py green,
                       normal files blue, catch-all group "regular")
                       THIS FILE IS MANDATORY - without it the
                       extension colouring of files is missing!

PREREQUISITES
-------------
  1. Midnight Commander 4.8.19 or newer (truecolor skins)
  2. A terminal with truecolor support. Check:
         echo $COLORTERM
     -> should print "truecolor" or "24bit" (most modern terminal
        emulators do: GNOME Terminal, Konsole, xterm, alacritty,
        kitty, foot, ...).
  3. If the colours look wrong or grayscale:
         export COLORTERM=truecolor
         export TERM=xterm-256color

STEP 1: INSTALL MIDNIGHT COMMANDER
----------------------------------
  Arch Linux:
      sudo pacman -S --needed mc

  Ubuntu:
      sudo apt update
      sudo apt install mc

  Debian:
      sudo apt update
      sudo apt install mc
      (on old Debian < 10 mc may be too old for truecolor skins)

  Alpine Linux:
      sudo apk add mc
      (without sudo when logged in as root: just "apk add mc")
      Note: busybox ash is perfectly sufficient, all skins work
      in pure ash environments too.

STEP 2: COPY THE SKIN FILES (identical on all 4 distros)
-------------------------------------------------------
  The skins belong into your personal skin directory, the
  filehighlight.ini into your personal mc configuration directory:

      mkdir -p ~/.local/share/mc/skins
      cp DarkGreen.ini BlueMoon.ini Creamy.ini ~/.local/share/mc/skins/
      mkdir -p ~/.config/mc
      cp filehighlight.ini ~/.config/mc/

  IMPORTANT: The ~/.config/mc/filehighlight.ini REPLACES the central
  system file (/etc/mc resp. /usr/share/mc). If you already have your
  own one, back it up first:
      cp ~/.config/mc/filehighlight.ini ~/.config/mc/filehighlight.ini.mine

  To install the files system-wide for all users (needs root):
      cp DarkGreen.ini BlueMoon.ini Creamy.ini /usr/share/mc/skins/
      (the filehighlight.ini belongs ONLY user-wide in ~/.config/mc,
       because otherwise it would replace the system defaults of all
       users)

STEP 3: ACTIVATE A SKIN
-----------------------
  Variant A - permanently via the menu (recommended):
      start mc
      F9 -> Options -> Appearance -> choose the desired skin
      F9 -> Options -> Save configuration

  Variant B - for testing only:
      mc -S DarkGreen        (or: mc -S BlueMoon / mc -S Creamy)

  Variant C - manually in the file ~/.config/mc/ini:
      In the section [Midnight-Commander] set/change the line:
          skin=DarkGreen
      (quit mc first, otherwise it rewrites the ini on exit)

DESIGN OVERVIEW
---------------
  DarkGreen : background #26262b (anthracite), frames bright green,
              normal files bright blue #00b2ff, executable bright lilac
  BlueMoon  : background #101a33 (dark blue), frames bright yellow,
              normal files bright blue, executable bright lilac
  Creamy    : background #b29f77 (sand), frames black (instead of
              bright yellow), normal files dark blue #00008b,
              executable bright lilac #cc66ff

  Common (LS_COLORS mapping): directories bright yellow resp. black
  (Creamy), symlinks bright cyan, *.txt bright resp. dark red,
  *.sh and *.py bright green.

CUSTOMISING COLOURS (HEX CODES)
-------------------------------
Every colour is stored in the skin files as a hex code in MC format:

    #rrggbb     standard HTML notation (e. g. #00ff00 = bright green)
    #rgb        short form (#0f0 equals #00ff00)

Every skin file has a COLOUR LEGEND at the top listing all central
colours and their meaning (background, frames, normal files,
directories, ...). Above each colour line there is a comment
explaining the colour, e. g.:

    # fg bright green (panel frames) | bg anthracite
    _default_ = #00ff00;#26262b

The line format is:  foreground;background[;attributes]
Attributes are: bold, underline, reverse, blink. An empty background
(e. g. "directory = #ffff00;") inherits the panel background.

Three rules:
  1. Only change the hex codes, not the structure of the file.
  2. NEVER put comments BEHIND a value line! MC reads
     "key = #00ff00  ; green" as the colour "#00ff00  ; green" and
     discards the whole skin. Comments always as their own line,
     starting with #.
  3. Test after every change:  mc -S skinname

Examples:

  a) Change a single place: replace the hex code at the matching
     (commented) place in the skin file, e. g. directories in Creamy
     from black to grey:
         directory = #000000;   ->   directory = #606060;

  b) Swap one colour globally (all occurrences at once):
         sed -i 's/#b29f77/#c9b58a/g' Creamy.ini

  c) Adopt a colour value from another skin: read the hex code from
     that skin's legend and enter it at the desired place.

After editing either copy the changed file directly to
~/.local/share/mc/skins/ (mc re-reads the skin on start) or use the
installer command -r to pack the edited files back into a new script
(see THE INSTALLER SCRIPT). If colours do not come through despite
correct hex codes: the terminal must support truecolor, see
PREREQUISITES.

THE INSTALLER SCRIPT
--------------------
The script that extracted these files is self-extracting and can be
RENAMED FREELY - the help adapts to the current name automatically.
Invocations (independent of the name):

  ./<scriptname>.sh              Install all three skins
  ./<scriptname>.sh -x [DIR]     Extract the files (this Manual.txt is
                                 created then), default DIR is
                                 ./mc-skins
  ./<scriptname>.sh -a SKIN      Activate a skin in the mc ini
  ./<scriptname>.sh -i SKIN      Install only this single skin
                                 (filehighlight.ini is installed too,
                                 if not yet present)
  ./<scriptname>.sh -r DIR       Pack the edited files from DIR into
                                 a NEW installer script; output:
                                 DIR/mc-skins-installer.sh
                                 (the folder must contain:
                                 DarkGreen.ini, BlueMoon.ini,
                                 Creamy.ini, filehighlight.ini -
                                 Anleitung.txt/Manual.txt optional,
                                 otherwise the built-in version is
                                 used)
  ./<scriptname>.sh -de          Output in German (default)
  ./<scriptname>.sh -en          Output in English
                                 The language can also be set
                                 permanently in the variable LANG_MODE
                                 at the top of the script ("de" or
                                 "en").
  ./<scriptname>.sh -h           Help with the current script name

TROUBLESHOOTING
---------------
  - "Cannot parse skin": file copied incompletely/corrupted, or a
    comment was written BEHIND a value line (MC only allows comment
    lines starting with #).
  - Everything grey/black-and-white: terminal does not support
    truecolor, see PREREQUISITES item 2/3.
  - All files the same colour: the ~/.config/mc/filehighlight.ini is
    missing, or "file highlighting" is disabled in the panel options
    (F9 -> Options -> Panels).
  - Skin not found: check the path with
      ls ~/.local/share/mc/skins/
    The file name (without .ini) must exactly match the skin name
    (case-sensitive: DarkGreen, BlueMoon, Creamy).
__MC_SKIN_EOF__
}


# ---------------------------------------------------------------------
#  Hilfsfunktionen
# ---------------------------------------------------------------------

backup_if_exists() {
    # $1 = Dateipfad
    if [ -f "$1" ]; then
        BK="$1.bak.$(date +%Y%m%d-%H%M%S)"
        cp -p "$1" "$BK"
        msgf backup "$BK"
    fi
}

warn_root() {
    # Warnt, wenn das Script per sudo/root lief (Skins landen in /root)
    if [ "$(id -u)" = "0" ]; then
        if [ -n "${SUDO_USER:-}" ]; then
            msgf sudo_warn "$HOME (root statt ${SUDO_USER})"
        else
            msgf sudo_warn "$HOME (root)"
        fi
        msg ""
    fi
}

build_emit() {
    # $1 = Funktionsname, $2 = Quelldatei -> gibt emit-Funktion aus
    if grep -q "^$D\$" "$2"; then
        msgf delim_err "$2" "$D"
        exit 1
    fi
    printf 'emit_%s() {\n' "$1"
    printf "    cat <<'%s'\n" "$D"
    awk '{ print }' "$2"
    printf '%s\n}\n\n' "$D"
}

# ---------------------------------------------------------------------
#  Aktionen
# ---------------------------------------------------------------------

install_skins() {
    warn_root
    msgf installing
    msgf skin_dir "$SKIN_DIR"
    msgf colors_dir "$FH_FILE"
    mkdir -p "$SKIN_DIR"
    mkdir -p "$(dirname "$FH_FILE")"

    for S in $SKINS; do
        "emit_$S" > "$SKIN_DIR/$S.ini"
        chmod 644 "$SKIN_DIR/$S.ini"
        msgf installed "$SKIN_DIR/$S.ini"
    done

    backup_if_exists "$FH_FILE"
    emit_filehighlight > "$FH_FILE"
    chmod 644 "$FH_FILE"
    msgf installed "$FH_FILE"

    msg ""
    msgf done_head
    msgf done_test
    msgf done_menu
    msgf done_menu2
    msgf done_a
}

install_one() {
    SKIN="$1"
    OK=0
    for S in $SKINS; do
        [ "$SKIN" = "$S" ] && OK=1
    done
    if [ "$OK" -ne 1 ]; then
        msgf err_name_i "$SKINS"
        exit 1
    fi
    warn_root
    msgf one_start "$SKIN"
    msgf skin_dir "$SKIN_DIR"
    mkdir -p "$SKIN_DIR"
    "emit_$SKIN" > "$SKIN_DIR/$SKIN.ini"
    chmod 644 "$SKIN_DIR/$SKIN.ini"
    msgf installed "$SKIN_DIR/$SKIN.ini"
    mkdir -p "$(dirname "$FH_FILE")"
    if [ -f "$FH_FILE" ]; then
        msgf fh_present "$FH_FILE"
    else
        emit_filehighlight > "$FH_FILE"
        chmod 644 "$FH_FILE"
        msgf fh_installed "$FH_FILE"
    fi
    msg ""
    msgf act_test "$SKIN"
    msgf act_perm "$SKIN"
}

extract_files() {
    DEST="${1:-./mc-skins}"
    mkdir -p "$DEST"
    for S in $SKINS; do
        "emit_$S" > "$DEST/$S.ini"
        msgf extracted "$DEST/$S.ini"
    done
    emit_filehighlight > "$DEST/filehighlight.ini"
    msgf extracted "$DEST/filehighlight.ini"
    { printf 'Entpackt aus / Extracted from: %s (v%s)\n\n' "$SELF" "$VERSION"
      emit_Anleitung
    } > "$DEST/Anleitung.txt"
    msgf extracted "$DEST/Anleitung.txt"
    { printf 'Extracted from / Entpackt aus: %s (v%s)\n\n' "$SELF" "$VERSION"
      emit_Manual
    } > "$DEST/Manual.txt"
    msgf extracted "$DEST/Manual.txt"
    msg ""
    msgf manual_see "$DEST/Anleitung.txt / $DEST/Manual.txt"
    msgf manual_short "$SKIN_DIR" "$CFG_DIR/mc"
}

activate_skin() {
    SKIN="$1"
    OK=0
    for S in $SKINS; do
        [ "$SKIN" = "$S" ] && OK=1
    done
    if [ "$OK" -ne 1 ]; then
        msgf err_name_a "$SKINS"
        exit 1
    fi
    warn_root
    if pgrep -x mc >/dev/null 2>&1; then
        msgf mc_running
        msg ""
    fi
    if [ ! -f "$MC_INI" ]; then
        # mc legt die ini beim ersten Start an; ein Minimalgeruest genuegt
        mkdir -p "$(dirname "$MC_INI")"
        printf '[Midnight-Commander]\nskin=%s\n' "$SKIN" > "$MC_INI"
        msgf ini_created "$MC_INI" "$SKIN"
        msgf act_restart "$SKIN"
        return
    fi
    backup_if_exists "$MC_INI"
    if grep -q '^skin=' "$MC_INI"; then
        awk -v s="skin=$SKIN" '
            /^skin=/ && !done { print s; done = 1; next }
            { print }
        ' "$MC_INI" > "$MC_INI.tmp"
    else
        awk -v s="skin=$SKIN" '
            { print }
            /^\[Midnight-Commander\]/ && !done { print s; done = 1 }
        ' "$MC_INI" > "$MC_INI.tmp"
    fi
    mv "$MC_INI.tmp" "$MC_INI"
    msgf activated "$SKIN" "$MC_INI"
    msgf act_restart "$SKIN"
}

repack() {
    SRC="${1:-.}"
    if [ ! -d "$SRC" ]; then
        msgf err_dir "$SRC"
        exit 1
    fi
    for F in DarkGreen.ini BlueMoon.ini Creamy.ini filehighlight.ini; do
        if [ ! -f "$SRC/$F" ]; then
            msgf err_missing "$SRC/$F"
            exit 1
        fi
    done
    if [ ! -f "$SRC/Anleitung.txt" ]; then
        msgf man_missing "$SRC"
        emit_Anleitung > "$SRC/Anleitung.txt"
    fi
    if [ ! -f "$SRC/Manual.txt" ]; then
        emit_Manual > "$SRC/Manual.txt"
    fi
    OUT="$SRC/mc-skins-installer.sh"
    if [ -f "$OUT" ]; then
        msgf overwrite "$OUT"
    fi
    # Eigenen Inhalt in temporaere Kopie sichern: Wenn OUT == $0 ist
    # (Script in seinem eigenen Ordner neu verpacken), wuerde die
    # Umleitung > "$OUT" die Datei leeren, BEVOR awk daraus liest.
    SELF_COPY="$SRC/.mc_repack_self.$$"
    cp "$0" "$SELF_COPY"
    {
        # Kopfteil dieses Scripts (alles vor der ersten emit-Funktion)
        awk '/^emit_DarkGreen\(\) \{/ { exit } { print }' "$SELF_COPY"
        for S in $SKINS; do
            build_emit "$S" "$SRC/$S.ini"
        done
        build_emit "filehighlight" "$SRC/filehighlight.ini"
        build_emit "Anleitung" "$SRC/Anleitung.txt"
        build_emit "Manual" "$SRC/Manual.txt"
        # Fussteil dieses Scripts (ab der Hilfsfunktionen-Markierung)
        awk '
            /^#  Hilfsfunktionen/ && !f { f = 1; print PL; print; next }
            f { print; next }
            { PL = $0 }
        ' "$SELF_COPY"
    } > "$OUT"
    rm -f "$SELF_COPY"
    # Versionsnummer des neuen Scripts automatisch um 0.1 erhoehen
    NEWVER=$(awk -v v="$VERSION" 'BEGIN { printf "%.1f", v + 0.1 }')
    sed "s/^VERSION=.*/VERSION=\"${NEWVER}\"/" "$OUT" > "$OUT.tmp"
    mv "$OUT.tmp" "$OUT"
    chmod 755 "$OUT"
    msg ""
    msgf repacked "$OUT" "$NEWVER"
    msgf repack_test "$OUT" "$OUT"
}

# ---------------------------------------------------------------------
#  Hauptprogramm: Optionen in beliebiger Reihenfolge parsen
# ---------------------------------------------------------------------

SELF=$(basename "$0")

ACTION="install"
ARG=""
ERR_OPT=""

while [ $# -gt 0 ]; do
    case "$1" in
        -de) LANG_MODE="de" ;;
        -en) LANG_MODE="en" ;;
        -nc) NC=1 ;;
        -h|--help|help) ACTION="help" ;;
        install) ACTION="install" ;;
        -x|-a|-i|-r)
            ACTION="$1"
            # Optionales Argument nur uebernehmen, wenn vorhanden;
            # sonst bleibt ARG leer und die Funktion nutzt ihren Default.
            if [ $# -gt 1 ]; then
                ARG="$2"
                shift
            fi
            ;;
        *) ERR_OPT="$1"; ACTION="error" ;;
    esac
    shift
done

# Farben nur auf einem Terminal (oder wenn nicht mit -nc abgeschaltet)
if [ "${NC:-0}" = "1" ] || [ ! -t 1 ]; then
    COLOR=0
    # Farbkonstanten leeren (auch colorize_help nutzt sie direkt)
    CYAN_H=""; YELLOW_H=""; RED_H=""; MAGENTA_L=""; GREEN_O=""; RESET=""
    if [ "${NC:-0}" = "1" ]; then
        msgf nc_on
    fi
fi

case "$ACTION" in
    install) install_skins ;;
    help)    usage ;;
    -x)      extract_files "$ARG" ;;
    -a)      activate_skin "$ARG" ;;
    -i)      install_one "$ARG" ;;
    -r)      repack "$ARG" ;;
    error)   msgf err_unknown "$ERR_OPT"; msg ""; usage ;;
esac
