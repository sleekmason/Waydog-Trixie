#!/bin/bash
# A simple dialog to sync the Fuzzel background with the
# current terminal background. - Made by sleekmason 05 Aug 2026
yad --title "Fuzzel BG Color" --escape-ok --borders=12 \
--width=280 --height=50 \
--text="Sync BG to terminal color" --text-align=center \
--button="gtk-cancel:0" \
--button="gtk-ok:0" \
--form --columns=1 \
--field="Fuzzel Background Sync":FBTN "bash -c fuzzel-colorsync"
