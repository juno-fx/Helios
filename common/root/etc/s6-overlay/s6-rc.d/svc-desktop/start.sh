#!/usr/bin/env bash

# wait for X to be running
while true; do
	if xset q &>/dev/null; then
		break
	fi
	sleep .5
done

echo "Waiting for Selkies process to start..."

# Loop until a process matching "pcoip-agent" appears
while true; do
	if pgrep -f pcoip-agent >/dev/null; then
		echo "pcoip-agent process detected."
		break
	fi
	sleep 0.25
done

HOME="/home/$USER"

if [ -z "$USER" ]; then
	echo "No user configured"
	exit 1
fi

if [ -z "$UID" ]; then
	echo "No UID configured"
	exit 1
fi

if [ -z "$GID" ]; then
	echo "No GID configured, defaulting to matching UID"
	GID="$UID"
fi

# set sane resolution before starting apps
s6-setuidgid ${USER} xrandr --newmode "1024x768" 63.50 1024 1072 1176 1328 768 771 775 798 -hsync +vsync
s6-setuidgid ${USER} xrandr --addmode screen "1024x768"
s6-setuidgid ${USER} xrandr --output screen --mode "1024x768" --dpi 96

# set xresources
if [ -f "${HOME}/.Xresources" ]; then
	xrdb "${HOME}/.Xresources"
else
	echo "Xcursor.theme: breeze" >"${HOME}/.Xresources"
	xrdb "${HOME}/.Xresources"
fi
chown ${USER}:${USER} "${HOME}/.Xresources"

# run
cd $HOME
exec s6-setuidgid ${USER} \
	/bin/bash /opt/helios/startwm.sh
