#!/bin/bash
# welcome backend
# Made for Waydog by sleekmason

STAMP="$HOME/.local/share/.remove"

# Run once
[ -f "$STAMP" ] && exit 0

# Detect live vs installed
if [ -e /run/live/medium ]; then
    MODE="live"
else
    MODE="installed"
fi

# Setup
case "$MODE" in
  live)
    /usr/local/bin/live-session
    ;;
  installed)
    /usr/local/bin/installed-session
    ;;
esac

# Mark done
mkdir -p "$(dirname "$STAMP")"
touch "$STAMP"

# Remove autostart entries
sed -i '/welcome-backend.sh/d' "$HOME/.config/labwc/autostart"
sed -i '/welcome-backend.sh/d' "$HOME/.config/sway/config"

# Launch welcome
if command -v yad >/dev/null; then
  if [ "$MODE" = "installed" ]; then
    yad --title "Welcome!" \
      --window-icon=/usr/share/icons/ld-icons/paw-color.png \
      --width=488 --height=444 --center \
      --escape-ok --undecorated --skip-taskbar \
      --button=" Begin"!/usr/share/icons/gnome/22x22/places/debian-swirl.png!:"x-terminal-emulator -T 'Customization' -e 'sudo xentry -i'" \
      --button=" Exit!application-exit:0" \
      --text-info --justify=left --wrap \
      < /usr/share/lilidog/welcome.txt \
      --fontname="JetBrains Mono Light 11" \
      --fore="#DAE4E8"
  else
    yad --title "Welcome To Waydog Live" \
      --window-icon=/usr/share/icons/ld-icons/paw-color.png \
      --width=488 --height=538 --center \
      --escape-ok --undecorated --skip-taskbar \
      --button="gtk-ok:0" \
      --text-info --justify=left --wrap \
      < /usr/share/lilidog/welcome2.txt \
      --fontname="JetBrains Mono Light 11" \
      --fore="#DAE4E8"
  fi
fi

exit 0
