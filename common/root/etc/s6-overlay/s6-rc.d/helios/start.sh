#!/usr/bin/env bash

set -e

HOME=$(getent passwd "$USER" | cut -d: -f6)
cd "${HOME}" || (echo "Home directory not found" && exit 1)

# flag the health check we are ready to go.
touch /tmp/.healthz

# Show KasmVNC Logs
tail \
	-f $HOME/.vnc/*${DISPLAY}.log \
	-f /var/log/nginx/*.log
