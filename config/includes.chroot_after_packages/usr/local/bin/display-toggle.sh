#!/bin/bash
# display-toggle.sh - Kill and restart the display from a keybind.
# requires wlopm

PIDFILE="/tmp/display-toggle-$USER.pid"

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
fi

if wlopm | grep -q ' on$'; then
    wlopm --off '*'
    while wlopm | grep -q ' on$'; do
        sleep .03
    done
    swayidle -w timeout 1 true resume "wlopm --on '*'; rm -f \"$PIDFILE\"; kill \$PPID" &
    echo $! > "$PIDFILE"
else
    wlopm --on '*'
fi
