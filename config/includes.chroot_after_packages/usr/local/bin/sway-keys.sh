#!/bin/bash
# Display Sway keybindings
# Created for Waydog by sleekmason 25 Dec 2025

CONFIG="$HOME/.config/sway/config"

# Terminal preference
TERMINALS=( "xfce4-terminal" "foot" "wezterm" "alacritty" "gnome-terminal" "kitty" "x-terminal-emulator" )

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
        xfce4-terminal) "$TERM_CMD" -x "$SCRIPT" ;;
        gnome-terminal|x-terminal-emulator) "$TERM_CMD" -- "$SCRIPT" ;;
        kitty|alacritty|wezterm|foot) "$TERM_CMD" -e "$SCRIPT" ;;
    esac
}

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

awk -v HEAD="$HEAD_COLOR" -v GREEN="$GREEN" -v RESET="$RESET" '
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
    var=$2; val=$3
    sub(/^\$/,"",var)
    vars[var]=val
}

function expand_vars(str,v) {
    for(v in vars) gsub("\\$" v, vars[v], str)
    return str
}

# Mode handling
/^[ \t]*mode "/ { mode=$0; gsub(/.*mode "/,"",mode); gsub(/".*/,"",mode); next }
/^[ \t]*}/ { mode=""; next }

# Parse bindsym
/^[ \t]*bindsym / {
    line=$0
    line=expand_vars(line)
    sub(/^[ \t]*bindsym[ \t]+/,"",line)

    while(line ~ /^--[A-Za-z-]+[ \t]+/) sub(/^--[A-Za-z-]+[ \t]+/,"",line)

    key=line; sub(/[ \t].*$/,"",key)
    action_text=line; sub(/^[^ \t]+[ \t]+/,"",action_text)

    action="Command"; detail=action_text

    if(action_text ~ /^workspace number/) { action="Workspace"; sub(/^workspace number[ \t]+/,"",detail) }
    else if(action_text ~ /^move container to workspace number/) { action="Send"; sub(/^move container to workspace number[ \t]+/,"",detail) }
    else if(action_text ~ /^exec/) { sub(/^exec[ \t]+(--no-startup-id[ \t]+)?/,"",detail) }
    else if(action_text ~ /^focus /) { action="Focus"; sub(/^focus[ \t]+/,"",detail) }
    else if(action_text ~ /^move /) { action="Move"; sub(/^move[ \t]+/,"",detail) }
    else if(action_text ~ /^resize /) { action="Resize"; sub(/^resize[ \t]+/,"",detail) }
    else if(action_text ~ /^layout /) { action="Layout"; sub(/^layout[ \t]+/,"",detail) }
    else if(action_text ~ /^fullscreen/) { action="Fullscreen"; detail="toggle" }
    else if(action_text ~ /^floating toggle/) { action="Floating"; detail="toggle" }
    else if(action_text ~ /^scratchpad /) { action="Scratchpad"; sub(/^scratchpad[ \t]+/,"",detail) }
    else if(action_text ~ /^gaps /) {
        action="Gaps"; sub(/^gaps[ \t]+/,"",detail)
        split(detail,a," ")
        norm = key " " a[2] " " a[3] " " a[4]
        if(seen_gaps[norm]++) next
        detail=a[2] " " a[3] " " a[4]; in_gaps=1
    }
    else if(action_text ~ /^mode /) {
        action="Mode"; sub(/^mode[ \t]+/,"",detail)
        gsub(/"/,"",detail)
        gsub(/^Mod4e_/,"",detail)
        if(in_gaps && seen_gaps_mode[detail]++) next
    }

    # Print headers
    if(!seen[action]++) {
        if(action=="Resize") {
            print "\n" HEAD "[Resize]" RESET
            printf " %s%-*s%s  %s%-*s%s - %s%s%s\n",
                CKEY, width_key, "Mod4+r", RESET,
                CACT, width_act, "Mode", RESET,
                CDET, "resize", RESET
            mod4r_printed=1
        } else if(action=="Gaps") { gaps_heading_printed=0; gap_controls_printed=0 }
        else if(action=="Workspace") print "\n" HEAD "[Workspaces]" RESET
        else if(action=="Send") print "\n" HEAD "[Send]" RESET
        else if(action=="Focus") print "\n" HEAD "[Focus]" RESET
        else if(action=="Move") print "\n" HEAD "[Move]" RESET
        else if(action=="Command") { 
            print "\n" HEAD "[Commands]" RESET
            if(!print_keybind_printed++)
                printf " %s%-*s%s  %s%-*s%s - %s%s%s\n",
                    CKEY, width_key, "Print", RESET,
                    CACT, width_act, action, RESET,
                    CDET, "grimshot save area", RESET
        }
    }

    # Insert Layout heading after Send section
    if(action=="Send") last_was_send=1
    else if(last_was_send && !layout_heading_printed++) {
        print "\n" HEAD "[Layout]" RESET
        last_was_send=0
    }

    # Skip Mod4+r duplicate
    if(key=="Mod4+r" && action=="Mode" && mod4r_printed) next

    # Audio & Brightness heading
    if(action=="Command" && key ~ /^XF86/) {
        if(!audio_heading_printed++) print "\n" HEAD "[Audio & Brightness]" RESET
    }

    # Gaps headings
    if(action=="Mode" && key=="Mod4+Shift+g") if(!gaps_heading_printed++) print "\n" HEAD "[Gaps]" RESET
    if(action=="Gaps") {
        if(!gap_controls_printed++) print "\n" HEAD "[Gap Controls]" RESET
        if(key=="Return" || key=="Escape") action="Mode"
        if(key != "Return" && key != "Escape") action="Resize"
    }

    # Skip duplicate Print
    if(key=="Print" && print_keybind_printed && action=="Command") next
    
    # Consolidated cleanup & formatting before printing
    gsub(/@DEFAULT_SINK@/, "", detail)
    gsub(/@DEFAULT_SOURCE@/, "", detail)
    gsub(/\\[ \t]*/, "", detail)
    if(length(key)==1 && key !~ /^[0-9]$/) key = "<" key ">"

    if(length(detail) > max_detail) detail = substr(detail, 1, max_detail) "..."

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
rm -f "$TMP_SCRIPT"
