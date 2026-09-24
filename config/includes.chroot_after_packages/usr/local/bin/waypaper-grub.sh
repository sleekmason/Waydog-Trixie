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

if [[ "$1" == "--priv" ]]; then
    TMP_PNG="$2"
    PNG_NAME="$3"
    READY_FILE="$4"
    GRUB_DIR="/boot/grub"

    touch "$READY_FILE"

    rm -f "$GRUB_DIR"/*.png "$GRUB_DIR"/*.jpg "$GRUB_DIR"/*.jpeg &&
    cp -f "$TMP_PNG" "$GRUB_DIR/$PNG_NAME" &&
    chmod 644 "$GRUB_DIR/$PNG_NAME" &&
    update-grub

    exit $?
fi

if ! command -v gm >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    notify-send -i dialog-error "Please install GraphicsMagick or ImageMagick to continue."
    exit 0
fi

CONFIG_FILE="$HOME/.config/waypaper/config.ini"
STATE_FILE="$HOME/.config/waypaper/grub/config.ini"
GRUB_DIR="/boot/grub"
SCRIPT_PATH="$(readlink -f "$0")"

get_real_wallpaper() {
    local result=""
    if command -v jq >/dev/null 2>&1; then
        result=$(waypaper --list 2>/dev/null | jq -r '(map(select(.monitor=="All")) + .)[0].wallpaper // empty' 2>/dev/null)
    fi
    if [[ -z "$result" ]]; then
        result=$(grep -E '^wallpaper *= *' "$CONFIG_FILE" 2>/dev/null | cut -d= -f2- | xargs)
    fi
    printf '%s' "$result"
}

if [[ "$1" == "--post" ]]; then
    selected_wallpaper="$2"
    real_wallpaper=""
    if [[ -n "$WAYPAPER_GRUB_REAL_WALLPAPER_FILE" && -f "$WAYPAPER_GRUB_REAL_WALLPAPER_FILE" ]]; then
        real_wallpaper="$(cat "$WAYPAPER_GRUB_REAL_WALLPAPER_FILE" 2>/dev/null)"
    fi

    if [[ -f "$selected_wallpaper" ]]; then
        BASENAME=$(basename "$selected_wallpaper")
        PNG_NAME="${BASENAME%.*}.png"
        TMP_PNG=$(mktemp /tmp/grub-bg-XXXXXX.png)
        READY_FILE=$(mktemp /tmp/grub-bg-ready-XXXXXX)
        rm -f "$READY_FILE"

        if command -v gm >/dev/null 2>&1; then
            gm convert "$selected_wallpaper" -type TrueColor "$TMP_PNG" 2>/dev/null
        elif command -v convert >/dev/null 2>&1; then
            convert "$selected_wallpaper" -type TrueColor -depth 8 PNG24:"$TMP_PNG" 2>/dev/null
        fi

        if [[ ! -f "$TMP_PNG" || ! -s "$TMP_PNG" ]]; then
            notify-send -i dialog-error "waypaper-grub: Image conversion failed."
            rm -f "$TMP_PNG" "$READY_FILE"
        else
            notify-send -i dialog-password --urgency low "Please enter your password"

            pkexec "$SCRIPT_PATH" --priv "$TMP_PNG" "$PNG_NAME" "$READY_FILE" &
            PKPID=$!

            while kill -0 "$PKPID" 2>/dev/null; do
                if [[ -f "$READY_FILE" ]]; then
                    break
                fi
                sleep 0.1
            done

            if [[ -f "$READY_FILE" ]]; then
        if [[ -n "$real_wallpaper" && -f "$real_wallpaper" ]]; then
            (
                flock -w 5 200 || exit 0
                pkill -x swaybg 2>/dev/null
                swaybg -m fill -i "$real_wallpaper" >/dev/null 2>&1 &
                disown
            ) 200>/tmp/waypaper-grub-swaybg.lock
        fi

                WF_SHELL_CONFIG="$HOME/.config/wf-shell.ini"
                if [[ -f "$WF_SHELL_CONFIG" && -n "$real_wallpaper" ]]; then
                    sed -i "s|^image *=.*|image=$real_wallpaper|" "$WF_SHELL_CONFIG" 2>/dev/null
                fi

                yad --progress --pulsate --no-buttons --skip-taskbar --borders=10 \
                    --title="GRUB BG Changer" \
                    --image="preferences-desktop-wallpaper" \
                    --text=" Please allow GRUB to update before rebooting.\n (approx. 10-15 seconds)" \
                    --no-focus &
                YAD_PID=$!
            fi

            wait "$PKPID"
            PKEXIT=$?

            if [[ ! -f "$READY_FILE" ]]; then
        if [[ -n "$real_wallpaper" && -f "$real_wallpaper" ]]; then
            (
                flock -w 5 200 || exit 0
                pkill -x swaybg 2>/dev/null
                swaybg -m fill -i "$real_wallpaper" >/dev/null 2>&1 &
                disown
            ) 200>/tmp/waypaper-grub-swaybg.lock
        fi

                WF_SHELL_CONFIG="$HOME/.config/wf-shell.ini"
                if [[ -f "$WF_SHELL_CONFIG" && -n "$real_wallpaper" ]]; then
                    sed -i "s|^image *=.*|image=$real_wallpaper|" "$WF_SHELL_CONFIG" 2>/dev/null
                fi
            fi

            if [[ -n "$YAD_PID" ]]; then
                kill "$YAD_PID" 2>/dev/null
                wait "$YAD_PID" 2>/dev/null
            fi

            if [[ $PKEXIT -eq 0 ]]; then
                notify-send -i dialog-information --urgency low "GRUB background changed to: $PNG_NAME"
            else
                notify-send -i dialog-information "GRUB update cancelled."
            fi

            rm -f "$TMP_PNG" "$READY_FILE"
        fi
    fi

    exit 0
fi

mkdir -p "$(dirname "$STATE_FILE")"

if [[ ! -f "$STATE_FILE" ]]; then
    cp "$CONFIG_FILE" "$STATE_FILE"

    sed -i "s|^post_command[[:space:]]*=.*|post_command = \"$SCRIPT_PATH\" --post \"\$wallpaper\"|" "$STATE_FILE"

    if ! grep -qE '^post_command[[:space:]]*=' "$STATE_FILE"; then
        sed -i "/^\[Settings\]/a post_command = \"$SCRIPT_PATH\" --post \"\$wallpaper\"" "$STATE_FILE"
    fi
fi

REAL_WALLPAPER_FILE="$(mktemp /tmp/waypaper-grub-real-XXXXXX)"
export WAYPAPER_GRUB_REAL_WALLPAPER_FILE="$REAL_WALLPAPER_FILE"
(
    result="$(get_real_wallpaper)"
    result="${result/#\~/$HOME}"
    printf '%s' "$result" > "$REAL_WALLPAPER_FILE"
) &
LOOKUP_PID=$!

(sleep 2; notify-send -i dialog-question -u low "Does this system control GRUB?" "(usually the last distro installed)") &
waypaper --config-file "$STATE_FILE" --state-file "$STATE_FILE" >/dev/null 2>&1

wait "$LOOKUP_PID" 2>/dev/null
rm -f "$REAL_WALLPAPER_FILE"

exit 0
