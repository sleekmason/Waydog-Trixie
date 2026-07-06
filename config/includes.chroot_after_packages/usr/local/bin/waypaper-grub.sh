#!/bin/bash
# Grub background changer for Waydog. Made by sleekmason 26 Jun, 2026
# NOTE: This script must be run from the system that controls GRUB for changes to occur.
# Requires GraphicsMagick or ImageMagick to use.

full_fs=$(df ~ | tail -1 | awk '{print $1}')
fs=$(basename "$full_fs")
if ! grep -q "$fs" /proc/partitions; then
    notify-send -i preferences-system -u low "Not for use in a live environment."
    exit 0
fi

if ! command -v gm >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    notify-send -i dialog-error "Please install GraphicsMagick or ImageMagick to continue."
    exit 0
fi

STATE_FILE="$HOME/.config/waypaper/grub-bg/config.ini"
CONFIG_FILE="$HOME/.config/waypaper/config.ini"
GRUB_DIR="/boot/grub"

mkdir -p "$(dirname "$STATE_FILE")"
CURRENT_FOLDER=$(grep -E '^folder *= *' "$CONFIG_FILE" | cut -d= -f2- | xargs)
CURRENT_FOLDER="${CURRENT_FOLDER/#\~/$HOME}"
if [[ -f "$STATE_FILE" ]]; then
    sed -i "s|^folder *=.*|folder = $CURRENT_FOLDER|" "$STATE_FILE"
else
    if [[ -n "$CURRENT_FOLDER" ]]; then
        printf '[Settings]\n[State]\nfolder = %s\n' "$CURRENT_FOLDER" > "$STATE_FILE"
    fi
fi

BEFORE=$(stat -c %Y "$STATE_FILE" 2>/dev/null || echo 0)
notify-send -u low "Does this system control GRUB?" "(usually the last distro installed)"
waypaper --state-file "$STATE_FILE" >/dev/null 2>&1
AFTER=$(stat -c %Y "$STATE_FILE" 2>/dev/null || echo 0)
real_wallpaper=$(grep -E '^wallpaper *= *' "$CONFIG_FILE" | cut -d= -f2- | xargs)
real_wallpaper="${real_wallpaper/#\~/$HOME}"

if [[ -f "$real_wallpaper" ]]; then
    swaybg -m fill -i "$real_wallpaper" >/dev/null 2>&1 & disown
fi

if [[ "$AFTER" -le "$BEFORE" ]]; then
    exit 0
fi

selected_wallpaper=$(grep -E '^wallpaper *= *' "$STATE_FILE" | cut -d= -f2- | xargs)
selected_wallpaper="${selected_wallpaper/#\~/$HOME}"

if [[ -f "$selected_wallpaper" ]]; then
    BASENAME=$(basename "$selected_wallpaper")
    PNG_NAME="${BASENAME%.*}.png"
    TMP_PNG=$(mktemp /tmp/grub-bg-XXXXXX.png)
    if command -v gm >/dev/null 2>&1; then
        gm convert "$selected_wallpaper" -type TrueColor "$TMP_PNG" 2>/dev/null
    elif command -v convert >/dev/null 2>&1; then
        convert "$selected_wallpaper" -type TrueColor -depth 8 PNG24:"$TMP_PNG" 2>/dev/null
    fi
    if [[ ! -f "$TMP_PNG" || ! -s "$TMP_PNG" ]]; then
        notify-send -i dialog-error "waypaper-grub: Image conversion failed."
        rm -f "$TMP_PNG"
        exit 1
    fi
    notify-send --urgency low "Please enter your password."
    yad --progress --pulsate --no-buttons --skip-taskbar --borders=10 \
        --title="GRUB BG Changer" \
        --image="preferences-desktop-wallpaper" \
        --text=" After entering your password, please wait\n for this dialog to close before rebooting.\n (approx. 10-15 seconds)" \
        --no-focus &
    YAD_PID=$!
    sleep 0.3
    pkexec bash -c "
        rm -f '$GRUB_DIR'/*.png '$GRUB_DIR'/*.jpg '$GRUB_DIR'/*.jpeg &&
        cp -f '$TMP_PNG' '$GRUB_DIR/$PNG_NAME' &&
        chmod 644 '$GRUB_DIR/$PNG_NAME' &&
        update-grub
    "
    PKEXIT=$?
    kill "$YAD_PID" 2>/dev/null
    wait "$YAD_PID" 2>/dev/null
    if [[ $PKEXIT -eq 0 ]]; then
        notify-send --urgency low "GRUB background changed to: $PNG_NAME"
    else
        notify-send -i dialog-error "GRUB update cancelled."
    fi
    rm -f "$TMP_PNG"
fi
exit 0
