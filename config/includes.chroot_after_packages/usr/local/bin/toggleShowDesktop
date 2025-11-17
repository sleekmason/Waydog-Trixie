#!/bin/bash

CACHE_FILE="$HOME/.cache/.tsd"

if wlrctl window find state:unminimized; then
	wlrctl window list state:unminimized > $CACHE_FILE
	wlrctl window list state:focused >> $CACHE_FILE
	wlrctl window minimize state:unminimized
else 
	while IFS=':' read -r app_id title; do
		wlrctl window focus app_id:"${app_id}" title:"${title/ /}"
	done < "$CACHE_FILE"
	> "$CACHE_FILE"
fi
