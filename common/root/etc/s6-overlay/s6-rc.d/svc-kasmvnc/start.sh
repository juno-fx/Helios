#!/usr/bin/env bash

set -e

# Incase of loop, remove the healthz file and force a fresh start
rm -rfv /tmp/.healthz /tmp/.X1-lock

echo "Linking to custom kasmvnc config"
ln -sf /etc/helios/kasmvnc.yaml /usr/local/etc/kasmvnc/kasmvnc.yaml

if [ -z ${DRINODE+x} ]; then
	DRINODE="/dev/dri/renderD128"
fi

HOME=$(getent passwd "$USER" | cut -d: -f6)
cd "${HOME}" || (echo "Home directory not found" && exit 1)
exec s6-setuidgid "${USER}" /etc/s6-overlay/s6-rc.d/svc-kasmvnc/startkasm.sh
