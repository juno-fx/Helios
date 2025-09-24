#!/usr/bin/env bash

# handle a restart if needed
XVFB_PIDS=$(pgrep Xvfb)
if [ -n "$XVFB_PIDS" ]; then
	echo "Xvfb is running with PID(s): $XVFB_PIDS"
	echo "Stopping Xvfb..."
	kill $XVFB_PIDS

	# Optional: Wait a bit and ensure they are killed
	sleep 1
	if pgrep Xvfb >/dev/null; then
		echo "Xvfb still running. Forcing termination..."
		pkill -9 Xvfb
	else
		echo "Xvfb stopped successfully."
	fi
fi

# Enable DRI3 support if detected
VFBCOMMAND=""
if ! which nvidia-smi && [ -e "/dev/dri/renderD128" ]; then
	VFBCOMMAND="-vfbdevice /dev/dri/renderD128"
fi
if [ ! -z ${DRINODE+x} ]; then
	VFBCOMMAND="-vfbdevice ${DRINODE}"
fi
DEFAULT_RES="15360x8640"
if [ ! -z ${MAX_RES+x} ]; then
	DEFAULT_RES="${MAX_RES}"
fi

echo "Starting Xvfb..."

# Run Xvfb server with required extensions
exec s6-setuidgid "${USER}" \
	/usr/bin/Xvfb \
	"${DISPLAY}" \
	-screen 0 "${DEFAULT_RES}x${DISPLAY_CDEPTH}" \
	-dpi "${DISPLAY_DPI}" \
	+extension "COMPOSITE" \
	+extension "DAMAGE" \
	+extension "GLX" \
	+extension "RANDR" \
	+extension "RENDER" \
	+extension "MIT-SHM" \
	+extension "XFIXES" \
	+extension "XTEST" \
	+iglx \
	+render \
	-nolisten "tcp" \
	-ac \
	-noreset \
	-shmem \
	${VFBCOMMAND} >/var/log/helios/xvfb.log
