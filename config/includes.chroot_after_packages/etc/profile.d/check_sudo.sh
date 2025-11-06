#!/bin/bash
# Check and ensure sudo access for the logged-in user

# Skip for root or system accounts
if [ "$USER" != "root" ] && id "$USER" &>/dev/null; then
    # Check if user is in sudo group
    if ! id -nG "$USER" | grep -qw "sudo"; then
        echo "[INFO] User '$USER' is not in the sudo group."

        # If root is enabled and this runs as root, fix it
        if [ "$(id -u)" -eq 0 ]; then
            usermod -aG sudo "$USER"
            echo "[FIXED] Added '$USER' to sudo group."
        else
            echo "[WARN] '$USER' lacks sudo access. Ask root to run:"
            echo "       usermod -aG sudo $USER"
        fi
    fi
fi
