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
  <item label="Terminal" icon="/usr/share/icons/gnome/24x24/apps/utilities-terminal.png">
    <action name="Execute" command="xfce4-terminal" />
  </item>
  <item label="Web Browser" icon="/usr/share/icons/gnome/24x24/apps/web-browser.png">
    <action name="Execute" command="firefox-esr" />
  </item>
  <separator />'

# Generate the application menu
labwc-menu-generator -b -I -i "${ignore_files}"

# Add footer items
printf '%b\n' '
  <separator />
  <item label="Reconfigure" icon="/usr/share/icons/gnome/24x24/emblems/emblem-synchronizing.png">
    <action name="Reconfigure" />
  </item>
  <item label="Exit" icon="/usr/share/icons/gnome/24x24/actions/application-exit.png">
    <action name="Exit" />
  </item>
</openbox_menu>'
