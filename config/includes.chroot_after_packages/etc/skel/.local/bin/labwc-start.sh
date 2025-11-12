#!/bin/bash
#
#

# === 1. Basic environment ===
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=labwc
export XDG_SESSION_CLASS=user
export XDG_SEAT=seat0

# Optional: better Wayland support for apps
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# === 2. Only run on tty1 ===
if [[ -z "$WAYLAND_DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then

    # === 3. Start D-Bus if not already running ===
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
        eval "$(dbus-launch --sh-syntax --exit-with-session)"
    fi

dbus-update-activation-environment --systemd XDG_RUNTIME_DIR XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
# systemctl --user import-environment WAYLAND_DISPLAY XDG_RUNTIME_DIR
systemctl --user import-environment XDG_RUNTIME_DIR XDG_SESSION_TYPE XDG_CURRENT_DESKTOP
# Start gvfsd and metadata service (optional but needed for recent files)
if ! pgrep -x gvfsd >/dev/null; then
    /usr/libexec/gvfsd &
    /usr/libexec/gvfsd-metadata &
fi

    # === 4. Start Labwc itself ===
    echo "Starting Labwc... logs in ~/labwc.log"
    exec labwc > ~/labwc.log 2>&1

else
    echo "Already in Wayland or not on tty1; not starting Labwc."
fi
