#!/bin/sh

ignore_files=$(mktemp)
trap "rm -f $ignore_files" EXIT
cat <<'EOF' >${ignore_files}
gammastep-indicator.desktop
libreoffice-startcenter.desktop
cmake-gui.desktop
electron27.desktop
org.gtk.IconBrowser4.desktop
org.gtk.gtk4.NodeEditor.desktop
org.gtk.PrintEditor4.desktop
org.gtk.WidgetFactory4.desktop
bssh.desktop
bvnc.desktop
qv4l2.desktop
qvidcap.desktop
pcmanfm-qt-desktop-pref.desktop
pcmanfm-desktop-pref.desktop
libfm-pref-apps.desktop
org.xfce.mousepad-settings.desktop
avahi-discover.desktop
org.codeberg.dnkl.footclient.desktop
org.codeberg.dnkl.foot-server.desktop
lstopo.desktop
gtk-lshw.desktop
urxvtc.desktop
urxvt-tabbed.desktop
xterm.desktop
rofi.desktop
rofi-theme-selector.desktop
EOF

# Start the pipemenu output
printf '%b\n' '<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu>'

# Add static items
printf '%b\n' '
  <item label="Terminal" icon="utilities-terminal">
    <action name="Execute" command="x-terminal-emulator" />
  </item>
  <item label="Web Browser" icon="web-browser">
    <action name="Execute" command="x-www-browser" />
  </item>
  <separator />'

# Generate the application menu
labwc-menu-generator -b -I -i "${ignore_files}" -t "x-terminal-emulator -e"

# Add footer items
printf '%b\n' '
  <separator />
  <item label="Reconfigure" icon="emblem-synchronizing">
    <action name="Execute" command="labwc-reconfigure-toggle" />
  </item>
  <item label="Exit" icon="application-exit">
    <action name="Execute" command="ld-logout" />
  </item>
</openbox_menu>'
