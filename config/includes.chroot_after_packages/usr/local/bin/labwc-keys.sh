#!/bin/bash
# Display labwc keybindings
# Created for Waydog by sleekmason 17 Dec 2025

CONFIG="$HOME/.config/labwc/rc.xml"

# Terminal preference
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
    xfce4-terminal)
      "$TERM_CMD" --hold -x "$SCRIPT"
      ;;
    gnome-terminal|x-terminal-emulator)
      "$TERM_CMD" -- "$SCRIPT"
      ;;
    kitty|alacritty|wezterm|foot)
      "$TERM_CMD" -e "$SCRIPT"
      ;;
    *)
      "$TERM_CMD" -e "$SCRIPT"
      ;;
  esac
}

# Temp script
TMP_SCRIPT=$(mktemp)

cat >"$TMP_SCRIPT" <<'EOF'
#!/bin/bash
CONFIG="$HOME/.config/labwc/rc.xml"

clear

# Basic colors
YELLOW="\033[33m"
GREEN="\033[32m"
WHITE="\033[37m"
CYAN="\033[36m"
BLUE="\033[34m"
MAGENTA="\033[35m"
RESET="\033[0m"


echo -e "${BLUE}LABWC KEYBINDS   Legend: W=Super  S=Shift  C=Ctrl${RESET}"
echo -e "${GREEN}--------------------------------------------------------${RESET}"

awk '
BEGIN {
  KEY_COLOR=33     # yellow
  ACT_COLOR=32     # green
  DET_COLOR=34     # blue
  RESET="\033[0m"

  CKEY="\033[" KEY_COLOR "m"
  CACT="\033[" ACT_COLOR "m"
  CDET="\033[" DET_COLOR "m"
}

/<keybind key=/ {
  key=$0
  gsub(/.*key="/,"",key)
  gsub(/".*/,"",key)
  action=""
  detail=""
}

/<action name=/ {
  action=$0
  gsub(/.*name="/,"",action)
  gsub(/".*/,"",action)
}

/<execute>/ {
  detail=$0
  gsub(/.*<execute>/,"",detail)
  gsub(/<\/execute>.*/,"",detail)
}

/<to>/ {
  detail=$0
  gsub(/.*<to>/,"",detail)
  gsub(/<\/to>.*/,"",detail)
  detail="Desktop " detail
}

/<\/keybind>/ {
  if (action=="GoToDesktop" && detail=="") {
    if (key ~ /-[0-9]+$/)
      detail="Desktop " substr(key, match(key, /[0-9]+$/))
    else if (key ~ /Left$/)
      detail="Desktop Left"
    else if (key ~ /Right$/)
      detail="Desktop Right"
  }

  if (detail!="")
    printf "%s%-15s%s  %s%-15s%s  %s%s%s\n",
      CKEY, key, CRESET,
      CACT, action, CRESET,
      CDET, detail, CRESET
  else
    printf "%s%-15s%s  %s%-15s%s\n",
      CKEY, key, CRESET,
      CACT, action, CRESET
}
' "$CONFIG" | sort

echo -e "${GREEN}--------------------------------------------------------${RESET}"
exec "$SHELL"
EOF

chmod +x "$TMP_SCRIPT"
run_in_terminal "$TMP_SCRIPT"
