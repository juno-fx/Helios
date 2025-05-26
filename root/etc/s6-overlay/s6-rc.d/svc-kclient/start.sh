#!/usr/bin/env bash

sleep 5

# NodeJS wrapper
cd /kclient
chown -R "${USER}:${USER}" /kclient /defaults
chmod -R 755 /kclient /defaults
HOME=$( getent passwd "$USER" | cut -d: -f6 )
export SUBFOLDER="${PREFIX}"
export FM_HOME="${HOME}"

exec s6-setuidgid "${USER}" node index.js
