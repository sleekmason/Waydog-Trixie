#!/bin/sh

WIN=$(xdotool getactivewindow getwindowname)

if [ ${#WIN} -gt 60 ]; then
	WIN=$(echo $WIN | cut -c 1-60)
	echo "$WIN..."
else
	echo $WIN
fi
