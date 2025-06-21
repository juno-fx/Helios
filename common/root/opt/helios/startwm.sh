#!/bin/bash

if [ -x /usr/bin/xfce4-session ]; then
	/usr/bin/xfce4-session 2>&1
else
	echo "Desktop Environment not found."
	exit 1
fi
