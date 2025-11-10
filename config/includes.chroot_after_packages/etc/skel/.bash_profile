if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]]; then
    $HOME/.local/bin/labwc-start.sh
fi
