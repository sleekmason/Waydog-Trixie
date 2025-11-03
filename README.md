-------
### About Lilidog:

Lilidog is a lightweight linux distro based on debian.  Lilidog uses the Openbox window manager with tint2, thunar, and xfce4-terminal.
Other window managers are also made available through the Lilidog installers. These are awesome, dk, dwm, i3, jwm, and sowm.<br/>

Lilidog is based on debian stable, with some of the hard parts done, and some cool stuff along the way. 
Everything is easily accessible, with numerous options to customize further.

Website: https://sourceforge.net/projects/lilidog/ 

#### Available Versions:

### Available Versions:

There are currently 5 general builds: full, minimal, minimal-i386, Beardog, and xfce4.  

- Full - (Approx. 1300 packages), comes with everything necessary to get started without needing initial extra downloads. I would advise most folks to use the full version if looking for an 'out of the box' computing solution with everything you need.

- Minimal - (Approx. 1080 packages), has everything the full version does, minus most of the main packages so people can choose their own. This version is great for people that like to tinker, and want to learn a bit more about linux.

- Lilidog-i386 - Uses the same base packages as the amd64 minimal version, but for older 32 bit hardware. You may find you need to boot with the kernel parameter 'forcepae' if you have difficulties.    

- Beardog - (Approx. 920 packages), is the 'bare' version of lilidog, allowing users to choose most of what they want. A general knowledge of linux is recommended.

- xfce4 - A new default xfce4 build with all the goodness of Lilidog.  A fine choice for those new to Lilidog.

#### NOTE - The DOWNLOAD button defaults to the full Openbox version. Click on FILES, and then RELEASES to access the other builds.

<a href="https://sourceforge.net/projects/lilidog/files/latest/download"><img alt="Download Lilidog" src="https://a.fsdn.com/con/app/sf-download-button" width=276 height=48 srcset="https://a.fsdn.com/con/app/sf-download-button?button_size=2x 2x"></a>

#### Current Releases:

 The version number is the date of the release beginning with the year, followed by the month, and then the day.  So as an example, release 23.12.21 stands for the 21st of Dec, 2023.  One way to see this after a Lilidog installation is to look at the Install Date Conky for the installation and build date.  Another way is to open a terminal and:

`cat /usr/share/lilidog/GPL/current-build` (after 2-10-24)

Lilidog uses the 'stable' version of debian, which is currently Bookworm, and updates to most of the packages can be had with a quick 

`sudo apt update && sudo apt upgrade`

to bring everything up to date. 

Every Lilidog release in itself is considered fully stable and usable.  New additions to the distro are just the natural forward progression of things to make the distro experience better over time.

Updates to Lilidog occur generally on the [Debian Point Release]( https://wiki.debian.org/DebianReleases/PointReleases) dates. New features, installers for various programs, and bug fixes occur at this time, though these are not required by the user to upgrade or worry about if they are happy with the Lilidog version they are using. 

To follow the current development of Lilidog, see my [Github Site](https://github.com/sleekmason), and choose the version of Lilidog you want. - These are Lilidog-Bookworm (full edition), Lilidog-Minimal, Lilidog-i386-Minimal, and Beardog.  After clicking on the version you want to check, look for the small clock symbol below the green 'Code' button and click on that to see the latest 'commits' (changes) for that particular version.

There have been more than 2500 commits since Lilidog was created!  Lilidogs first real release was under debian 'buster'  10-30-2020.

If there is a particular new feature you see here on the forum and would like to have but are unsure of how to get it, just ask, and most can be directly applied to your current system with ease.  I've no problem providing direction or files to get it done. 

#### Directions For Installation:

Probably the easiest way to use Lilidog is to put it on a usb stick.

One easy way is to grab the live-usb-maker app: https://github.com/MX-Linux/lum-qt-appimage/releases/tag/19.11.02  
Download the AppImage.tar.gz and open a terminal: 

`tar -xaf live-usb-maker-qt-19.11.02.x86_64.AppImage.tar.gz`
Then:
`sudo ./live-usb-maker-qt-19.11.02.x86_64.AppImage`

Use "image mode" in the live-usb maker when burning the image.

The boot screen for Lilidog gives a choice of using as a Live session, or installing if you like what you see.  
Lilidog uses the Debian installer with both text and graphical installs available.

When booting into the live session, another opportunity to install can be had by clicking the green icon in the system tray.  This will open the Calamares installer, which works quite well and is preferred by some.

Lilidog opens in the Openbox window manager. Easy enough to install others window managers if desired. They will show up in your login screen as options. The username and password for the live environment is "user", and "live" respectively.

#### Navigating Lilidog:

After boot, you have the option to install or try out Lilidog live.  Once in a session, there are a few items that can shape your experience. Look in the "paw" icon in the tint2 panel for theming options.  Look in the "Toggles" section of the menu for some other useful options, and look in the "Install Extras" portion of the menu for extra programs you may want.  Look around.  There's more to see as well.

#### Some Of The Basic Features:

- Based on Debian with contrib and non-free sources enabled by default.

- The popular Calamares installer is available from the live session to install Lilidog to your computer.  Click on the green icon in the system tray to get started.

- Debian backports sources can be added after installation through the welcome entry screen or from the Lilidog installers. 

- These are 'no --recommends' builds. This means only the required dependencies are included during package install. This leaves out any recommended or suggested packages, allowing for complete control over package installation. No unwanted packages will be installed by default. This can be changed after install if desired. 

- Tint2 is the panel by default.  See the wrench and screwdriver icon in the tint2 panel for some other nifty tint2 options, including toggles for the position (top or bottom), autohide, Tint2 time format (12/24H), and on/off, and theming options. 

- Jgmenu is the menu for all versions.  Huge amount of customization available. Go to menu -> configuration -> jgmenu.conf for how to change and add items.

- Wallpapers are handled by Feh.  Place any image you would like to use as a wallpaper in ~/Pictures/wallpapers.
Go to Menu -> Configuration -> Wallpaper Chooser to change wallpapers. You can also right-click on any image you choose from the file manager to set as background wallpaper. Other right-click options for images include rotation and copying to ~/Pictures.wallpapers. A random wallpaper toggle is included.

- Icons - Currently, the Obsidian Icon theme is default. Papirus, Gnome, and other icon sets are readily available.  

- Grub background changer opens a window to choose your own images. Lilidog ships with six to give you an intitial choice before finding your own to add to the collection.

- There are shortcuts for xfce4-power-manager in the battery icon. Hover over the icons to see what they are.  

- Rofi and Dmenu for alternate menu sources. - ALT + F5 pulls the full Dmenu up, while ALT + F3 pulls up a
customized rofi 'drun' menu.

- Thunar is the default file manager.  Custom right-click options are already added as well. These include everything from "Open as Root', to different rotations and sizing of pics, to comparisons of files using Meld. And more.

- Custom Lilidog Openbox and GTK themes, and matching themes for Geany and Xfce4-terminal.

- The fonts are Noto Sans for the windows and JetBrains mono for the xfce4-terminal. The exceptions are urxvt and Conky, where Dejavu is used.

- Xfce4-terminal is default terminal, with urxvt included. 

- The Conky Chooser in the toggles section of the menu contains toggles for ten different Conkys and the time format shown. All of the Conkys contain relevant info. These include a Clock, Full Info, Fortunes, Shortcuts, Worldclock, and Tao quotes. Everything conky is located in ~/.config/conky,including the Conky Chooser script.

- Custom colors can be chosen for three of the GTK themes, tint2, and conky.  This allows the user to design their own desktop that much easier.

- Picom Composite Manager with transparency enabled.  Look in ~/.config/picom.conf in order to change transparency, shadows, and more.

- Gammy screen color and lightness control located in Toggles, and from the keybind "Super + g". This will allow you to change and set the gamma and brightness of your screen for different times of your choice, or simply as a toggle when desired.

- Newsboat RSS reader with a custom configuration already in place and ready for new RSS feeds.

- System notifications enabled with Dunst, with options for sound effects.

- Menu Extras - Install menu with options for Liquorix kernel, Qemu, Virtualbox, Steam, Etcher, and more.

- Swapid script for the frequent dual installer. This grabs your swap uuid and opens the appropriate windows to edit. Try 'swapid' in a terminal after installing another distro to a different partition.

- ld-hotcorners - Each corner of the screen responds to a command.
Turn it on with the button in the lower left corner or under Toggles in the menu. Change the corners in ~/.config/ld-hotcorners. Currently clockwise from top left: __file manager, toggle Picom, exit menu, and terminal.

#### Instructions For Various Tasks:

#### Theme changes: 
The easiest way to change themes is with the 'Quick Theme Changer' located in the menu under Configuration.
This changes The GTK theme, Openbox theme, Geany theme, Lightdm, wallpaper, menu, and terminal theme all on the fly.

#### Working with the theme changer:
All of the theme file configurations are located in ~/.config/lilidog-themes. This will allow you to change the settings on the existing themes.   For a quick overview see the discussion: [HERE](https://forum.lilidog.org/d/559-adding-gtk-and-openbox-themes-to-the-auto-themes-changer)

#### Other Settings:
- For keyboard language layout see: https://sourceforge.net/p/lilidog/discussion/setup/thread/e9e88533c0/<br/>
- Most common items to change will have an entry under 'Configuration' in the menu.
- Settings Manager - Change your gtk theme, fonts, and icons on an individual basis.  Other important settings are here as well.
- Openbox Conf - The settings here control the window borders and other settings specific to Openbox.
- Jgmenu - Go to menu -> configuration -> jgmenu.conf for menu items. For theme changes, got to Jgmenu Theme Changer in the menu. ("o" or "g")
- Geany - There are themes to match.  These are changed through the Geany program under "view" - "change color scheme" 
- Printer - Setup entry in the menu under utilities.
- Lightdm - Configuration settings in the menu.

Github: https://github.com/sleekmason/Lilidog

#### Lilidog
[![Lili.png](https://i.postimg.cc/hjy8qYS8/Lili.png)](https://postimg.cc/5YzQBnQj)

