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

if [ -x /usr/bin/xfce4-session ]; then
	exec vglrun -d "$chosen" dbus-launch --exit-with-session /usr/bin/xfce4-session 2>&1
else
	echo "Desktop Environment not found."
	exit 1
fi
