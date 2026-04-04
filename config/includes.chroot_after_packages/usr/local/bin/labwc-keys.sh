#!/bin/bash
# Display labwc keybindings
# Created for Waydog by sleekmason 17 Dec 2025

#Use friendy names to change the desired output.

declare -A FRIENDLY_NAMES=(
  ["wl-find-cursor"]="Highlight Cursor"
  ["labwc-keys.sh"]="Keybinds Labwc"
  ["~/.config/conky/scripts/conky-chooser"]="Conky Chooser (if installed)"
  ["hotcorners-toggle"]="Hotcorners On/Off"
  ["waybar-toggle"]="Waybar On/Off"
  ["waybar-icon-toggle dialog"]="Waybar Options"
  ["labwc --reconfigure"]="Reload labwc"
  ["toggleShowDesktop"]="Show Desktop"
  ["toggle-random"]="Random Wallpaper - Daemon"
  ["random-wallpaper once"]="Random Wallpaper - Once"
  ["waypaper-update-wrapper"]="Wallpapers"
  ["wlr-gamma-tool -r -a"]="Gamma - Reset to default"
  ["wlr-gamma-gui"]="Gamma Control"
)
CONFIG="$HOME/.config/labwc/rc.xml"
TERMINALS=(
  "xfce4-terminal"
  "foot"
  "wezterm"
  "alacritty"
  "gnome-terminal"
  "kitty"
  "x-terminal-emulator"
)
TERM_CMD=""
for term in "${TERMINALS[@]}"; do
  if command -v "$term" >/dev/null 2>&1; then
    TERM_CMD="$term"
    break
  fi
done
if [[ -z "$TERM_CMD" ]]; then
  notify-send "labwc-keys" "No terminal emulator found"
  exit 1
fi
run_in_terminal() {
  SCRIPT="$1"
  case "$TERM_CMD" in
    xfce4-terminal)   "$TERM_CMD" -x "$SCRIPT" ;;
    gnome-terminal|x-terminal-emulator) "$TERM_CMD" -- "$SCRIPT" ;;
    kitty|alacritty|wezterm|foot) "$TERM_CMD" -e "$SCRIPT" ;;
    *) "$TERM_CMD" -e "$SCRIPT" ;;
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
echo -e " \${GREEN}----------------------------------------------------------\${RESET}"
printf " \033[33m%-15s\033[0m  \033[32m%-15s\033[0m  \033[34m%s\033[0m\n" "Alt+Tab" "WindowSwitcher" "Switch Windows"
awk -F'\t' 'NR==FNR { names[\$1]=\$2; next }
/<keybind key=/ {
  key=\$0; gsub(/.*key="/,"",key); gsub(/".*/,"",key)
  action=""; detail=""
}
/<action name=/ {
  action=\$0; gsub(/.*name="/,"",action); gsub(/".*/,"",action)
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
  if (detail ~ /^(xfce4-terminal|foot|wezterm|alacritty|gnome-terminal|kitty|x-terminal-emulator).*-e /) {
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
  if (detail!="")
    printf " %s%-15s%s  %s%-15s%s  %s%s%s\n", CKEY,key,CR, CACT,action,CR, CDET,detail,CR
  else
    printf " %s%-15s%s  %s%-15s%s\n", CKEY,key,CR, CACT,action,CR
}' "\$NAMES_FILE" "\$CONFIG" | sort
echo -e " \${GREEN}----------------------------------------------------------\${RESET}"
echo
read -n1 -s -r -p "Press any key to close..."
echo
rm -f "\$NAMES_FILE"
EOF
chmod +x "$TMP_SCRIPT"
run_in_terminal "$TMP_SCRIPT"
