#!/bin/bash
# Desktop init script for DCV virtual sessions
# Invoked by: dcv create-session --init /opt/helios/dcv-startwm.sh

set -e

HOME=$(getent passwd "$USER" | cut -d: -f6)

if [ -z "$HOME" ] || [ ! -d "$HOME" ]; then
	echo "ERROR: Home directory for user '$USER' not found"
	exit 1
fi

cd "$HOME"

# Enable Nvidia GPU support if detected
if which nvidia-smi &>/dev/null && [ "${DISABLE_ZINK}" != "true" ]; then
	export LIBGL_KOPPER_DRI2=1
	export MESA_LOADER_DRIVER_OVERRIDE=zink
	export GALLIUM_DRIVER=zink
fi

# Source user profile if it exists
if [ -f "$HOME/.profile" ]; then
	. "$HOME/.profile"
fi

echo "Starting XFCE desktop session for user '$USER'..."

if [ -x /usr/bin/xfce4-session ]; then
	exec dbus-launch --exit-with-session /usr/bin/xfce4-session 2>&1
else
	echo "ERROR: xfce4-session not found"
	exit 1
fi
