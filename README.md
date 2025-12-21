### About Waydog:
Waydog is a lightweight Linux distro based on Debian Trixie. Waydog uses
the new Wayland protocol for its display server.

Labwc and Sway are the current window managers available. Either can be
selected at login, and others can be added at will.

https://sourceforge.net/projects/lilidog/files/Releases/

### Current Release:
The version number shown is the date of the release beginning with the
year, followed by the month, and then the day. So as an example,
release 25.12.20 stands for the 20th of Dec, 2025.

To identify a Waydog build date after installation, in a terminal, try:
`cat /usr/share/lilidog/GPL/current-build`

### Updating:
Waydog uses the 'stable' version of Debian, which is currently Trixie.
Updates to Debian packages are gained by using apt:

`sudo apt update && sudo apt upgrade`

### Directions For Installation:
One easy way to install Waydog is to grab the live-usb-maker app:
https://github.com/MX-Linux/lum-qt-appimage/releases/tag/19.11.02  
Download the AppImage.tar.gz and open a terminal:

`tar -xaf live-usb-maker-qt-19.11.02.x86_64.AppImage.tar.gz`  
Then:  
`sudo ./live-usb-maker-qt-19.11.02.x86_64.AppImage`

Use "image mode" in the live-usb maker when burning the image.

The boot screen for Waydog gives a choice of using as a live session or
installing if you like what you see.

### Navigating Waydog:
For live login use: Live Username = 'user', and Live Password = 'live'.
The live session starts in the SDDM display manager after boot.

Waydog can be run in a VM, but not very well due to apparent Wayland
requirements. Ample video memory is a must.

### Features:
- Labwc and Sway window managers. Choose either at login.
- SDDM display manager for logging in. An installer for Ly is included.
- Waybar provides the panel top bar.
- NWG Look provides an interface for GTK settings.
- Labwc Tweaks provides for common Labwc adjustments.
- Usbimager to create USB images.
- Kernel remover for those that build their own, or just to clean up.
- Waypaper wallpaper setter for both wallpaper and SDDM login screen.
- Random background changer. Works in conjunction with the other changers.
- Labwc keybinds. 'Super + F1' will show all the current keybinds.
- Grimshot screenshot. Adds screenshots directly to ~/Pictures.
- Fuzzel menu. (dmenu equivalent) (Super + F5)
- Mako provides the system notifications.
- Sway has gaps!
- Optional installers for a few different items. Kernels, VirtualBox,
  extra themes, Conky, Dropbox, and others.

There are only a few more user-related programs to get you started.
Firefox, Geany, Thunar, and Xfce4-terminal are standard.

### Building Waydog:
No need to wait for a new release if wanting to keep up with the latest.
In fact, this is a great way to make personal changes, and to help with
testing new features.

How to build Waydog, Beardog, and Lilidog on your system.

Go to https://github.com/sleekmason to select the Trixie version you
would like to build. Here, I am using the Waydog-Trixie release:

1. sudo apt install -y git live-build
2. git clone https://github.com/sleekmason/Waydog-Trixie.git
3. cd Waydog-Trixie
4. sudo lb build

Wait for the build to finish and look for the ISO in the top folder.

To make it your own:  
Change stuff!

Then:  
lb clean  (cleans the configuration for the next build)  
lb build

Items to possibly change:  
Waydog-Trixie/config/package-lists/my.list.chroot  (package list)  
Waydog-Trixie/config/includes.chroot_after_packages/ (main files)

Of course there are other files that can also be changed in the build,
but maybe keep it simple for a run or two.

To follow the current development of Waydog:  
[Github Site](https://github.com/sleekmason)
