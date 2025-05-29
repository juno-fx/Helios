#!/usr/bin/env bash

sleep 5

# NodeJS wrapper
cd /opt/helios/kclient
chown -R "${USER}:${USER}" /opt/helios/kclient /opt/helios
chmod -R 755 /opt/helios/kclient /opt/helios
HOME=$(getent passwd "$USER" | cut -d: -f6)
export SUBFOLDER="${PREFIX}"
export FM_HOME="${HOME}"
exec s6-setuidgid "${USER}" node index.js
