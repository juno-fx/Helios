#!/usr/bin/env bash

mkdir -p /var/log/audio/
chmod -R 777 /opt/helios/
echo "Starting Pulse"
exec s6-setuidgid "${USER}" \
	/usr/bin/pulseaudio \
	--log-level=0 \
	--log-target=stderr \
	--exit-idle-time=-1 >/var/log/helios/pulse.log 2>&1 &

tries=0
echo "Waiting for Pulse to stabilize..."
while [ $tries -le 15 ]; do
	if pgrep -x "pulseaudio" >/dev/null; then
		echo "PulseAudio is running."
		break
	fi
	if [ $tries -eq 15 ]; then
		echo "Pulse Failed to start"
		exit 1
	fi
	tries=$(($tries + 1))
	sleep .5
done
