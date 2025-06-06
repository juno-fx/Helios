#!/bin/bash

set -e

# Incase of loop, remove the healthz file and force a fresh start
rm -rfv /tmp/.healthz

# Lang
if [ ! -z ${LC_ALL+x} ]; then
	export LANGUAGE="${LC_ALL%.UTF-8}"
	export LANG="${LC_ALL}"
fi

# Environment
export KASM_VNC_PATH=/usr/share/kasmvnc
export PULSE_RUNTIME_PATH=/var/run/pulse
if [ -z ${DRINODE+x} ]; then
	DRINODE="/dev/dri/renderD128"
fi
KASMNVC_HW3D=''
if [ ! -z ${HW3D+x} ]; then
	KASMVNC_HW3D="-hw3d"
fi

## Directory setup for home folder ##
mkdir -p "$HOME/Desktop" "$HOME/Downloads"
rm -rf "$HOME/.config/pulse"

# Setup the VNC location so we can share the home directories
VNC_LOCATION=/opt/helios/.vnc/
mkdir -p "$VNC_LOCATION"
ln -sfv "$VNC_LOCATION"

# Startup Script for DE
cp /opt/helios/startwm.sh "$HOME/.vnc/xstartup"
chmod +x "$HOME/.vnc/xstartup"
touch "$HOME/.vnc/.de-was-selected"

# setup Kasm's password
# Password
if [[ -z ${PASSWORD+x} ]]; then
	echo "No password set, shutting down."
	exit 1
fi
VNC_PW_HASH=$(python3 -c "import crypt; print(crypt.crypt('${PASSWORD}', '\$5\$kasm\$'));")
echo "${USER}:${VNC_PW_HASH}:ow" >"$VNC_LOCATION/.kasmpasswd"
echo "${USER}_viewer:${VNC_PW_HASH}:" >>"$VNC_LOCATION/.kasmpasswd"
chmod 600 "$VNC_LOCATION/.kasmpasswd"
if [[ -f "$HOME/.kasmpasswd" ]]; then
	echo "Replacing existing .kasmpasswd file with referenced symlink."
	rm -rfv "$HOME/.kasmpasswd"
fi
ln -sf "$VNC_LOCATION/.kasmpasswd" "$HOME/.kasmpasswd"

# SSL cert
rm -f "${HOME}/.vnc/self.pem"
openssl req -x509 \
	-nodes \
	-days 3650 \
	-newkey rsa:2048 \
	-keyout "${HOME}/.vnc/self.pem" \
	-out "${HOME}/.vnc/self.pem" \
	-subj "/C=US/ST=VA/L=None/O=None/OU=DoFu/CN=kasm/emailAddress=none@none.none"

# Start KasmVNC
vncserver $DISPLAY \
	$KASMVNC_HW3D \
	-drinode $DRINODE \
	-websocketPort 6901 \
	-httpd ${KASM_VNC_PATH}/www \
	-FrameRate=60 \
	-interface 0.0.0.0 \
	-BlacklistThreshold=0 \
	-FreeKeyMappings \
	-PreferBandwidth \
	-DynamicQualityMin=4 \
	-DynamicQualityMax=7 \
	-DLP_ClipDelay=0

# Audio
/opt/helios/kasmbins/kasm_websocket_relay/kasm_audio_out-linux \
	kasmaudio \
	8081 \
	4901 \
	"${HOME}/.vnc/self.pem" \
	"${HOME}/.vnc/self.pem" \
	"${USER}:${VNC_PW}" >/dev/null &
HOME=/var/run/pulse pulseaudio --start
HOME=/var/run/pulse no_proxy=127.0.0.1 ffmpeg \
	-v verbose \
	-f pulse \
	-fragment_size "${PULSEAUDIO_FRAGMENT_SIZE:-2000}" \
	-ar 44100 \
	-i default \
	-f mpegts \
	-correct_ts_overflow 0 \
	-codec:a mp2 \
	-b:a 128k \
	-ac 1 \
	-muxdelay 0.001 \
	http://127.0.0.1:8081/kasmaudio >/dev/null 2>&1 &

# enter a while loop and wait for the curl command to return success
tries=0
echo "Waiting for KasmVNC to start..."
while [ $tries -le 15 ]; do
	response=$(curl -s -w "%{http_code}" "http://127.0.0.1:3000${PREFIX-}")
	http_code=$(tail -n1 <<<"$response")
	if [ "$http_code" == "200" ]; then
		echo "Up and running, releasing healthz endpoint."

		# Unblock the healthz endpoint
		touch /tmp/.healthz
		chmod -v 777 /tmp/.healthz
		break
	fi

	if [ $tries -eq 15 ]; then
		echo "KasmVNC did not start within the expected time frame. Exiting."
		cat $HOME/.vnc/*${DISPLAY}.log
		exit 1
	fi

	tries=$(($tries + 1))
	sleep .5
done

# Show KasmVNC Logs
tail -f $HOME/.vnc/*${DISPLAY}.log
