#!/bin/sh
# Sway is installed as a dependency. This script hides the entry
# and moves the configuration to sway.bak if installed.

FILE=/usr/share/wayland-sessions/sway.desktop
if [ -f "$FILE" ]; then
   sudo sed -i '/NoDisplay=true/d' "$FILE"
   sudo sed -i '/Type/a NoDisplay=true' "$FILE"
fi

if [ -e "$HOME/.config/sway" ]; then
   rm -rf "$HOME/.config/sway.bak"
   mv "$HOME/.config/sway" "$HOME/.config/sway.bak"
fi
