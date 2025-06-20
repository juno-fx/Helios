#!/usr/bin/env bash

sleep 5

# NodeJS wrapper
cd /opt/helios/kclient
chown -R "${USER}:${USER}" /opt/helios/kclient /opt/helios
chmod -R 755 /opt/helios/kclient /opt/helios
HOME=$(getent passwd "$USER" | cut -d: -f6)
export SUBFOLDER="${PREFIX}"
echo "Starting Kclient"
exec s6-setuidgid "${USER}" node index.js &

tries=0
echo "Waiting for Kclient to stabilize..."
while [ $tries -le 15 ]; do
	response=$(curl -I http://127.0.0.1:6900/${PREFIX}/ 2>/dev/null | head -n 1 | cut -d$' ' -f2)
	if [ "$response" == "404" ]; then
		echo "Ready..."
		break
	fi

	if [ $tries -eq 15 ]; then
		echo "Kclient failed to start"
		cat $HOME/.vnc/*${DISPLAY}.log
		exit 1
	fi
	tries=$(($tries + 1))
	sleep .5
done
