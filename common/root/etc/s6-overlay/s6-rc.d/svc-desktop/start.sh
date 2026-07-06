#!/usr/bin/env bash

set -e

# Not needed for DCV virtual sessions — DCV owns its own X server (Xdcv)
if [ "${REMOTE_PROTOCOL}" = "dcv" ] && [ "${DCV_SESSION_TYPE}" = "virtual" ]; then
	echo "svc-desktop: DCV virtual session mode, exiting (Xdcv replaces Xvfb desktop)"
	exec sleep infinity
fi

# wait for X to be running
while true; do
	if xset q &>/dev/null; then
		break
	fi
	sleep .5
done

if [ "${REMOTE_PROTOCOL}" != "dcv" ]; then
	echo "Waiting for Selkies process to start..."
	while true; do
		if pgrep -f selkies >/dev/null; then
			echo "Selkies process detected."
			break
		fi
		sleep 0.25
	done
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
