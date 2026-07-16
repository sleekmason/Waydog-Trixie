#!/bin/bash
# display-toggle.sh - Kill and restart the display from a keybind.
# requires wlopm, swayidle, wlr-randr

PIDFILE="/tmp/display-toggle-$USER.pid"
SNAPSHOT="/tmp/display-toggle-snapshot-$USER.txt"
RESUME_SCRIPT="/tmp/display-toggle-resume-$USER.sh"

if [ -f "$PIDFILE" ]; then
    kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
fi

if wlopm | grep -q ' on$'; then
    wlr-randr > "$SNAPSHOT" 2>/dev/null

    wlopm --off '*'

    i=0
    while wlopm | grep -q ' on$'; do
        sleep .03
        i=$((i + 1))
        [ "$i" -gt 100 ] && break
    done

    sleep 0.3

    cat > "$RESUME_SCRIPT" <<EOF
#!/bin/bash
wlopm --on '*'
sleep 0.3
if [ -s "$SNAPSHOT" ] && command -v wlr-randr >/dev/null 2>&1; then
    awk '
        /^[^ ]/ {
            if (name != "") print name "\t" enabled "\t" mode "\t" pos "\t" transform "\t" scale
            name = \$1; enabled=""; pos=""; transform=""; scale=""; mode=""
            next
        }
        /^  Enabled:/ { enabled = \$2 }
        /^  Position:/ { pos = \$2 }
        /^  Transform:/ { transform = \$2 }
        /^  Scale:/ { scale = \$2 }
        /current/ {
            split(\$1, wh, "x")
            mode = wh[1] "x" wh[2] "@" \$3 "Hz"
        }
        END { if (name != "") print name "\t" enabled "\t" mode "\t" pos "\t" transform "\t" scale }
    ' "$SNAPSHOT" | while IFS=\$'\t' read -r out_name out_enabled out_mode out_pos out_transform out_scale; do
        if [ "\$out_enabled" = "yes" ] && [ -n "\$out_mode" ]; then
            wlr-randr --output "\$out_name" --on --mode "\$out_mode" \\
                --pos "\$out_pos" --transform "\$out_transform" --scale "\$out_scale" >/dev/null 2>&1
        elif [ "\$out_enabled" = "no" ]; then
            wlr-randr --output "\$out_name" --off >/dev/null 2>&1
        fi
    done
fi
rm -f "$PIDFILE"
EOF
    chmod +x "$RESUME_SCRIPT"

    swayidle -w timeout 1 true resume "bash '$RESUME_SCRIPT'; kill \$PPID" &
    echo $! > "$PIDFILE"
else
    wlopm --on '*'
fi
