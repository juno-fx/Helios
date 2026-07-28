#!/bin/bash

# Enable Nvidia GPU support if detected
if which nvidia-smi && [ "${DISABLE_ZINK}" == "false" ]; then
	export LIBGL_KOPPER_DRI2=1
	export MESA_LOADER_DRIVER_OVERRIDE=zink
	export GALLIUM_DRIVER=zink
fi

gpu_selector() {
	local dri_dir="/dev/dri"
	local cards=()

	# If /dev/dri doesn't exist → fallback
	if [[ ! -d "$dri_dir" ]]; then
		echo ":1"
		return
	fi

	# Collect all cards
	mapfile -t cards < <(ls -1 "$dri_dir"/card* 2>/dev/null)

	# If no cards found → fallback
	if [[ ${#cards[@]} -eq 0 ]]; then
		echo ":1"
		return
	fi

	# If only one card → pick it
	if [[ ${#cards[@]} -eq 1 ]]; then
		echo "${cards[0]}"
		return
	fi

	# If JUNO_CARD is set and valid → use it
	if [[ -n "$JUNO_CARD" && -e "$dri_dir/card$JUNO_CARD" ]]; then
		echo "$dri_dir/card$JUNO_CARD"
		return
	fi

	# Otherwise → pick randomly
	local rand_index=$((RANDOM % ${#cards[@]}))
	echo "${cards[$rand_index]}"
}

gpu_selector_verbose() {
	local selection="$1"
	local dri_dir="/dev/dri"
	local cards=()

	if [[ "$selection" == ":1" && ! -d "$dri_dir" ]]; then
		echo "Selected :1 because /dev/dri does not exist"
		return
	fi

	if [[ "$selection" == ":1" ]]; then
		echo "Selected :1 because no GPU cards were found under /dev/dri"
		return
	fi

	mapfile -t cards < <(ls -1 "$dri_dir"/card* 2>/dev/null)

	if [[ ${#cards[@]} -eq 1 ]]; then
		echo "Selected $selection because it is the only available GPU"
		return
	fi

	if [[ -n "$JUNO_CARD" && "$selection" == "$dri_dir/card$JUNO_CARD" ]]; then
		echo "Selected $selection because JUNO_CARD=$JUNO_CARD was set"
		return
	fi

	echo "Selected $selection randomly because JUNO_CARD was not set"
}

chosen=$(gpu_selector)
cat <<EOF

>>> Acceleration Configuration
$(gpu_selector_verbose "$chosen")
>>> Acceleration Configured

EOF

# Restore the session saved by the previous container into the hostname-stamped
# name xfce4 will look for on this one. Matched by exact key, so a workstation
# never adopts a session that is not its own (see /opt/helios/session-key.sh).
#
# Entirely best effort: /home is not guaranteed to be persistent and having no
# saved session is the normal first-boot case, so every failure here is a no-op.
restore_session() {
	local dir="${XDG_CACHE_HOME:-$HOME/.cache}/sessions"
	local saved key staged

	if [ ! -r /opt/helios/session-key.sh ]; then
		echo ">>> session: session-key.sh not found, not restoring"
		return 0
	fi
	source /opt/helios/session-key.sh
	key=$(helios_session_key)

	saved="${dir}/helios-session-${key}"
	if [ ! -r "$saved" ]; then
		echo ">>> session: no saved session at ${saved}, starting fresh"
		return 0
	fi

	# The name xfce4 will look for on this container. Must agree with the glob
	# the shutdown hook saves from, which matches on the short hostname.
	staged="${dir}/xfce4-session-${HOSTNAME%%.*}${DISPLAY%.*}"

	mkdir -p "$dir" 2>/dev/null || true
	if cp -p "$saved" "$staged" 2>/dev/null; then
		echo ">>> session: restored ${key} -> $(basename "$staged")"
	else
		echo ">>> session: failed to stage ${saved} as ${staged}"
	fi
}
restore_session || true

if [ -x /usr/bin/xfce4-session ]; then
	if [[ -n "$DISABLE_VGL" ]]; then
		# Run without vglrun if DISABLE_VGL is set
		echo
		echo ">>> Running without vglrun as DISABLE_VGL is set <<<"
		echo
		exec dbus-launch --exit-with-session /usr/bin/xfce4-session 2>&1
	else
		# Default: wrap in vglrun
		echo
		echo ">>> Running with vglrun <<<"
		echo
		exec vglrun -d "$chosen" dbus-launch --exit-with-session /usr/bin/xfce4-session 2>&1
	fi
else
	echo "Desktop Environment not found."
	exit 1
fi
