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

STATE_FILE="$HOME/.config/waypaper/grub-bg/config.ini"
CONFIG_FILE="$HOME/.config/waypaper/config.ini"
GRUB_DIR="/boot/grub"
SCRIPT_PATH="$(readlink -f "$0")"

if [[ "$1" == "--post" ]]; then
    selected_wallpaper="$2"
    real_wallpaper="${WAYPAPER_GRUB_REAL_WALLPAPER:-}"

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
                    swaybg -m fill -i "$real_wallpaper" >/dev/null 2>&1 & disown
                    sed -i "s|^wallpaper[[:space:]]*=.*|wallpaper = $real_wallpaper|" "$CONFIG_FILE"
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
                    swaybg -m fill -i "$real_wallpaper" >/dev/null 2>&1 & disown
                    sed -i "s|^wallpaper[[:space:]]*=.*|wallpaper = $real_wallpaper|" "$CONFIG_FILE"
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

real_wallpaper=$(grep -E '^wallpaper *= *' "$CONFIG_FILE" 2>/dev/null | cut -d= -f2- | xargs)
real_wallpaper="${real_wallpaper/#\~/$HOME}"

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

if grep -qE '^post_command[[:space:]]*=' "$CONFIG_FILE"; then
    HAD_POST_COMMAND=1
    original_post_command=$(grep -E '^post_command[[:space:]]*=' "$CONFIG_FILE" | head -n1 | cut -d= -f2- | sed 's/^[[:space:]]*//')
else
    HAD_POST_COMMAND=0
    original_post_command=""
fi

restore_post_command() {
    if [[ $HAD_POST_COMMAND -eq 1 ]]; then
        escaped_post_command=$(printf '%s' "$original_post_command" | sed 's/[\\&|]/\\&/g')
        sed -i "s|^post_command[[:space:]]*=.*|post_command = $escaped_post_command|" "$CONFIG_FILE"
    else
        sed -i '/^post_command[[:space:]]*=/d' "$CONFIG_FILE"
    fi
}

trap restore_post_command EXIT

export WAYPAPER_GRUB_REAL_WALLPAPER="$real_wallpaper"

if [[ $HAD_POST_COMMAND -eq 1 ]]; then
    sed -i "s|^post_command[[:space:]]*=.*|post_command = \"$SCRIPT_PATH\" --post \"\$wallpaper\"|" "$CONFIG_FILE"
else
    sed -i "/^\[Settings\]/a post_command = \"$SCRIPT_PATH\" --post \"\$wallpaper\"" "$CONFIG_FILE"
fi

(sleep 2; notify-send -i dialog-question -u low "Does this system control GRUB?" "(usually the last distro installed)") &
waypaper --state-file "$STATE_FILE" >/dev/null 2>&1

exit 0
