#!/usr/bin/env bash
mkdir -p /var/log/audio/
echo "Starting Pulse"
exec s6-setuidgid "${USER}" \
	/usr/bin/pulseaudio \
	--log-level=0 \
	--log-target=stderr \
	--exit-idle-time=-1 >/var/log/audio/error.log 2>&1 &

tries=0
echo "Waiting for Pulse to stabilize..."
while [ $tries -le 15 ]; do
	(pactl list || echo "" >/dev/null) && echo "Ready..." && break
	if [ $tries -eq 15 ]; then
		echo "Pulse Failed to start"
		exit 1
	fi
	tries=$(($tries + 1))
	sleep .5
done
