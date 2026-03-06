#!/bin/sh
# global PATH setup — /etc/profile.d/user-bin.sh

path_prepend() {
    case ":$PATH:" in
        *:"$1":*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

path_append() {
    case ":$PATH:" in
        *:"$1":*) ;;
        *) PATH="$PATH:$1" ;;
    esac
}

# System paths
path_append /sbin
path_append /bin
path_append /usr/sbin
path_append /usr/bin
path_append /usr/games
path_append /usr/local/games

# Local
path_prepend /usr/local/sbin
path_prepend /usr/local/bin

# User
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

export PATH
