#!/bin/bash
# Display Sway keybindings.
# Created for Waydog by sleekmason 25 Dec 2025

CONFIG="$HOME/.config/sway/config"

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
  notify-send "sway-keys" "No terminal emulator found"
  exit 1
fi

run_in_terminal() {
  SCRIPT="$1"
  case "$TERM_CMD" in
    xfce4-terminal)
      "$TERM_CMD" -x "$SCRIPT"
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

# Temporary script shown in terminal
TMP_SCRIPT=$(mktemp)

cat >"$TMP_SCRIPT" <<'EOF'
#!/bin/bash
CONFIG="$HOME/.config/sway/config"

clear

# Colors
HEAD_COLOR="\033[94m"
GREEN="\033[32m"
BLUE="\033[34m"
RESET="\033[0m"

echo -e " ${BLUE}SWAY KEYBINDS   Legend: Mod=Super  S=Shift  C=Ctrl${RESET}"
echo -e " ${GREEN}--------------------------------------------------------${RESET}"

awk -v HEAD="$HEAD_COLOR" -v SEP="$GREEN" -v RESET="$RESET" '
BEGIN {
  KEY_COLOR=33
  ACT_COLOR=32
  DET_COLOR=34
  CKEY="\033[" KEY_COLOR "m"
  CACT="\033[" ACT_COLOR "m"
  CDET="\033[" DET_COLOR "m"
  width_key=18
  width_act=12
  max_detail=50
}

# Capture variables
/^set \$[A-Za-z0-9_]+ / {
  var=$2
  val=$3
  sub(/^\$/, "", var)
  vars[var]=val
}

function expand_vars(str, v) {
  for (v in vars)
    gsub("\\$" v, vars[v], str)
  return str
}

# Enter/Exit mode
/^[ \t]*mode "/ { mode=$0; gsub(/.*mode "/,"",mode); gsub(/".*/,"",mode); next }
/^[ \t]*}/ { mode=""; next }

# Parse bindsym lines
/^[ \t]*bindsym / {
  line=$0
  line=expand_vars(line)
  sub(/^[ \t]*bindsym[ \t]+/, "", line)

  # Strip options
  while (line ~ /^--[A-Za-z-]+[ \t]+/) sub(/^--[A-Za-z-]+[ \t]+/, "", line)

  key=line; sub(/[ \t].*$/, "", key)
  action_text=line; sub(/^[^ \t]+[ \t]+/, "", action_text)

  action="Command"
  detail=action_text

  if (action_text ~ /^workspace number/) { action="Workspace"; sub(/^workspace number[ \t]+/, "", detail) }
  else if (action_text ~ /^move container to workspace number/) { action="Send"; sub(/^move container to workspace number[ \t]+/, "", detail) }
  else if (action_text ~ /^exec/) { sub(/^exec[ \t]+(--no-startup-id[ \t]+)?/, "", detail) }
  else if (action_text ~ /^focus /) { action="Focus"; sub(/^focus[ \t]+/, "", detail) }
  else if (action_text ~ /^move /) { action="Move"; sub(/^move[ \t]+/, "", detail) }
  else if (action_text ~ /^resize /) { action="Resize"; sub(/^resize[ \t]+/, "", detail) }
  else if (action_text ~ /^layout /) { action="Layout"; sub(/^layout[ \t]+/, "", detail) }
  else if (action_text ~ /^fullscreen/) { action="Fullscreen"; detail="toggle" }
  else if (action_text ~ /^floating toggle/) { action="Floating"; detail="toggle" }
  else if (action_text ~ /^scratchpad /) { action="Scratchpad"; sub(/^scratchpad[ \t]+/, "", detail) }
  else if (action_text ~ /^gaps /) { action="Gaps"; sub(/^gaps[ \t]+/, "", detail) }
  else if (action_text ~ /^mode /) { action="Mode"; sub(/^mode[ \t]+/, "", detail); gsub(/"/,"",detail) }

  if (!seen[action]++) print "\n" HEAD "[" action "]" RESET

  # Truncate Mod4+Shift+e command
  if (key == "Mod4+Shift+e" && action == "Command") {
      if (length(detail) > 19) detail = substr(detail,1,19) "..."
  }

  # Truncate audio keys and brightness keys
  if (key ~ /^XF86Audio/ || key ~ /^XF86MonBrightness/) {
      gsub(/\\@DEFAULT_SINK@/, "", detail)
      gsub(/\\@DEFAULT_SOURCE@/, "", detail)
      if (length(detail) > 50) detail = substr(detail,1,50) "..."
  }

  # Default truncation for everything else
  if (length(detail) > max_detail) detail = substr(detail,1,max_detail) "..."

  printf " %s%-*s%s  %s%-*s%s - %s%s%s\n",
    CKEY, width_key, key, RESET,
    CACT, width_act, action, RESET,
    CDET, detail, RESET
}
' "$CONFIG" /etc/sway/config.d/*

echo -e " ${GREEN}--------------------------------------------------------${RESET}"
echo
read -n1 -s -r -p "Press any key to close..."
echo
EOF

chmod +x "$TMP_SCRIPT"
run_in_terminal "$TMP_SCRIPT"
