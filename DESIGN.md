# design.md – Bash-Skript-Farbschema

# Überschrift 1 (Hell Cyan)
echo -e "\033[1;96m# Überschrift 1 (Hell Cyan)\033[0m"

# Überschrift 2 (Hell Cyan)
echo -e "\033[1;96m## Überschrift 2 (Hell Cyan)\033[0m"

# Normaler Text (Hell Gelb)
echo -e "\033[1;93mDies ist normaler Text in Hell Gelb.\033[0m"

# Warnung / Fehler (Hell Rot)
echo -e "\033[1;91mWARNUNG: Dies ist eine Fehlermeldung in Hell Rot.\033[0m"

# Datei / Befehl (Hell Lila)
echo -e "\033[1;35mDatei: /pfad/zur/datei.sh, Befehl: ls -la\033[0m"

# Alles andere (Hell Grün)
echo -e "\033[1;92mDieser Abschnitt ist Everything Else in Hell Grün.\033[0m"

# Farbschema-Referenzen (nur Beispiele)
# Headers -> Hell Cyan: \033[1;96m
# Body Text -> Hell Gelb: \033[1;93m
# Warnings -> Hell Rot: \033[1;91m
# File/Command labels -> Hell Lila: \033[1;35m
# Other -> Hell Grün: \033[1;92m
# Reset: \033[0m

# Hinweise zur Implementierung
# Verwende ANSI-ESC-Sequenzen wie \033[1;3Xm oder \033[1;3Xmm, entsprechend dem gewünschten Farbcode.
# Kombiniere mit [0m, um Farbsetzung zurückzusetzen.
# Wenn du Enums oder Variablen bevorzugst, kannst du Farbkonstanten definieren:

CYAN_H="\033[1;96m"      # Hell Cyan
YELLOW_H="\033[1;93m"    # Hell Gelb
RED_H="\033[1;91m"       # Hell Rot
MAGENTA_L="\033[1;35m"   # Hell Lila
GREEN_O="\033[1;92m"     # Hell Grün
RESET="\033[0m"          # Reset

# Beispiel:
echo -e "${CYAN_H}# Überschrift${RESET}"
echo -e "${YELLOW_H}Normaler Text${RESET}"
echo -e "${RED_H}Warnung: Fehler${RESET}"
echo -e "${MAGENTA_L}Datei: /pfad/zur/datei.sh${RESET}"
echo -e "${GREEN_O}Alles andere${RESET}"