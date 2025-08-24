#!/usr/bin/env bash

set -e

echo "Starting Selkies Service..."

# Default sink setup
#if [ ! -f '/dev/shm/audio.lock' ]; then
#  s6-setuidgid "${USER}" pactl \
#    load-module module-null-sink \
#    sink_name="output" \
#    sink_properties=device.description="output"
#  s6-setuidgid "${USER}" pactl \
#    load-module module-null-sink \
#    sink_name="input" \
#    sink_properties=device.description="input"
#  touch /dev/shm/audio.lock
#fi

echo "Starting Selkies..."

# Start Selkies
exec s6-setuidgid "${USER}" \
  selkies \
    --addr="localhost" \
    --port="8081" \
    --enable_basic_auth="false" \
    --mode="websockets" > /var/log/helios/selkies.log
