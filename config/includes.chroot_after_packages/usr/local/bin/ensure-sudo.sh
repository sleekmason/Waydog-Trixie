#!/bin/bash
# /usr/local/bin/ensure-sudo.sh
# Ensure all normal users (UID >= 1000) are in the sudo group

LOGFILE="/var/log/ensure-sudo.log"
touch "$LOGFILE" 2>/dev/null

# Loop through all normal users directly in a for loop
for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
    # Only add if user is not already in sudo
    if ! id -nG "$user" | grep -qw sudo; then
        usermod -aG sudo "$user"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Added '$user' to sudo group." >> "$LOGFILE"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - '$user' already in sudo group." >> "$LOGFILE"
    fi
done
