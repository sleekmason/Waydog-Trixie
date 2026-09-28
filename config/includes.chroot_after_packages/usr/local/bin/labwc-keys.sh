#!/bin/bash
# Display labwc keybindings
# Created for Waydog by sleekmason 17 Dec 2025
#Use friendy names to change the desired output.
declare -A FRIENDLY_NAMES=(
  ["wl-find-cursor"]="Highlight Cursor"
  ["labwc-keys.sh"]="Keybinds Labwc"
  ["~/.config/conky/scripts/conky-chooser"]="Conky Chooser (if installed)"
  ["fuzzel --config ~/.config/fuzzel/labwc/fuzzel.ini"]="Fuzzel Menu"
  ["hotcorners-toggle"]="Hotcorners On/Off"
  ["waybar-toggle"]="Waybar On/Off"
  ["waybar-icon-toggle dialog"]="Waybar Options"
  ["labwc-reconfigure-toggle"]="Reload labwc"
  ["display-toggle.sh"]="Toggle Display On/Off"
  ["grimshot save screen --notify"]="Screenshot All"
  ["grimshot save area --notify"]="Screenshot Select"
  ["grimshot save area --wait 10 --notify"]="Screenshot Select Wait 10s"
  ["toggleShowDesktop"]="Show Desktop"
  ["toggle-random"]="Random Wallpaper - Daemon"
  ["random-wallpaper once"]="Random Wallpaper - Once"
  ["waypaper-update-wrapper"]="Wallpapers"
  ["wlr-gamma-tool -r -a"]="Gamma - Reset to default"
  ["wlr-gamma-gui"]="Gamma Control"
)
CONFIG="$HOME/.config/labwc/rc.xml"

if command -v x-terminal-emulator >/dev/null 2>&1; then
    REAL_TERM=$(basename "$(readlink -f "$(command -v x-terminal-emulator)")")
else
    notify-send "labwc-keys" "No terminal emulator found"
    exit 1
fi

run_in_terminal() {
    SCRIPT="$1"
    case "$REAL_TERM" in
        ghostty)        x-terminal-emulator --title="Labwc Keybinds" -e "$SCRIPT" ;;
        xfce4-terminal) x-terminal-emulator -T "Labwc Keybinds" -x "$SCRIPT" ;;
        alacritty)      x-terminal-emulator --title "Labwc Keybinds" -e "$SCRIPT" ;;
        gnome-terminal) x-terminal-emulator -T "Labwc Keybinds" -- "$SCRIPT" ;;
        foot)           x-terminal-emulator --title="Labwc Keybinds" -e "$SCRIPT" ;;
        kitty)          x-terminal-emulator --title="Labwc Keybinds" -e "$SCRIPT" ;;
        wezterm)        x-terminal-emulator start --title "Labwc Keybinds" "$SCRIPT" ;;
        *)              x-terminal-emulator -e "$SCRIPT" ;;
    esac
}

TMP_NAMES=$(mktemp)
for key in "${!FRIENDLY_NAMES[@]}"; do
  printf '%s\t%s\n' "$key" "${FRIENDLY_NAMES[$key]}"
done > "$TMP_NAMES"

TMP_SCRIPT=$(mktemp)
cat >"$TMP_SCRIPT" <<EOF
#!/bin/bash
CONFIG="\$HOME/.config/labwc/rc.xml"
NAMES_FILE="$TMP_NAMES"
clear
BLUE="\033[34m"
GREEN="\033[32m"
RESET="\033[0m"
echo -e " \${BLUE}LABWC KEYBINDS   Legend: W=Super  S=Shift  C=Ctrl\${RESET}"
echo -e " \${GREEN}--------------------------------------------------------------\${RESET}"
printf " \033[33m%-22s\033[0m  \033[32m%-16s\033[0m  \033[34m%s\033[0m\n" "Alt+Tab" "WindowSwitcher" "Switch Windows"
awk -F'\t' 'NR==FNR { names[\$1]=\$2; next }
/<keybind key=/ {
  key=\$0; gsub(/.*key="/,"",key); gsub(/".*/,"",key)
  action=""; detail=""
}
/<action name=/ {
  action=\$0
  gsub(/.*name="/,"",action)
  gsub(/".*/,"",action)

  if (\$0 ~ /command="/) {
    detail=\$0
    gsub(/.*command="/,"",detail)
    gsub(/".*/,"",detail)
  }
}
/<execute>/ {
  detail=\$0; gsub(/.*<execute>/,"",detail); gsub(/<\/execute>.*/,"",detail)
}
/<command>/ {
  detail=\$0; gsub(/.*<command>/,"",detail); gsub(/<\/command>.*/,"",detail)
}
/<to>/ {
  detail=\$0; gsub(/.*<to>/,"",detail); gsub(/<\/to>.*/,"",detail)
  detail="Desktop " detail
}
/<\/keybind>/ {
  CKEY="\033[33m"; CACT="\033[32m"; CDET="\033[34m"; CR="\033[0m"
  # Extract label from terminal -e calls (POSIX-compatible)
  if (detail ~ /^x-terminal-emulator.*-e /) {
    tmp=detail; sub(/^[^ ]+ .*-e /,"",tmp); sub(/ .*/,"",tmp)
    detail=tmp
  }
  # Longest-match friendly name lookup
  bestlen=0
  bestval=""
  for (f in names) {
    if (index(detail, f) && length(f) > bestlen) {
      bestval = names[f]
      bestlen = length(f)
    }
  }
  if (bestlen > 0) detail=bestval
  if (action=="GoToDesktop" && detail=="") {
    if (key ~ /-[0-9]+$/) detail="Desktop " substr(key, match(key,/[0-9]+$/))
    else if (key ~ /Left$/) detail="Desktop Left"
    else if (key ~ /Right$/) detail="Desktop Right"
  }
  sk=key
  if (key ~ /Print$/) sk="Print " key
  if (detail!="")
    printf "%s\t %s%-22s%s  %s%-16s%s  %s%s%s\n", sk, CKEY,key,CR, CACT,action,CR, CDET,detail,CR
  else
    printf "%s\t %s%-22s%s  %s%-16s%s\n", sk, CKEY,key,CR, CACT,action,CR
}' "\$NAMES_FILE" "\$CONFIG" | sort -t\$'\t' -k1,1 | cut -f2-
echo -e " \${GREEN}--------------------------------------------------------------\${RESET}"
echo
read -n1 -s -r -p "Press any key to close..."
echo
rm -f "\$NAMES_FILE"
EOF
chmod +x "$TMP_SCRIPT"
run_in_terminal "$TMP_SCRIPT"
