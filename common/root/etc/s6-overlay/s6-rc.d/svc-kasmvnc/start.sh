#!/usr/bin/env bash

set -e

## Pass gpu flags if mounted
#if ls /dev/dri/renderD* 1> /dev/null 2>&1 && [ -z ${DISABLE_DRI+x} ] && ! which nvidia-smi; then
#  HW3D="-hw3d"
#fi
if [ -z ${DRINODE+x} ]; then
	DRINODE="/dev/dri/renderD128"
fi

HOME=$(getent passwd "$USER" | cut -d: -f6)
cd "${HOME}" || (echo "Home directory not found" && exit 1)
exec s6-setuidgid "${USER}" /bin/bash /opt/helios/startkasm.sh
