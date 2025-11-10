#!/bin/bash
# ~/.local/bin/labwc-start.sh

if [[ -z $WAYLAND_DISPLAY && "$(tty)" == "/dev/tty1" ]]; then
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=labwc
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    # Create runtime dir if missing
    if [ -z "$XDG_RUNTIME_DIR" ]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"
    fi
    
    
    # Auto-detect connected monitor(s)
if command -v kanshi >/dev/null 2>&1; then
    kanshi &
elif command -v wlr-randr >/dev/null 2>&1; then
    wlr-randr --auto
fi

    # Start optional background services
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_RUNTIME_DIR
systemctl --user import-environment WAYLAND_DISPLAY XDG_RUNTIME_DIR
systemctl --user start pipewire wireplumber 2>/dev/null &
systemctl --user start xdg-desktop-portal 2>/dev/null &
systemctl --user start xdg-desktop-portal-wlr 2>/dev/null &

exec labwc > ~/labwc.log 2>&1
fi
