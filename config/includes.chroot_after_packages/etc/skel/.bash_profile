# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Some programs will require xcb
export QT_QPA_PLATFORM="wayland;xcb"

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# if running zsh
if [ -n "$ZSH_VERSION" ]; then
    # include .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
	. "$HOME/.zshrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# include sbin in PATH
if [ -d "/sbin" ] ; then
    PATH="${PATH:+${PATH}:}/sbin"
fi

if [ -d "/usr/sbin" ] ; then
    PATH="${PATH:+${PATH}:}/usr/sbin"
fi

if [[ -z $WAYLAND_DISPLAY && $(tty) == /dev/tty1 ]]; then
    $HOME/.local/bin/labwc-start.sh
fi
