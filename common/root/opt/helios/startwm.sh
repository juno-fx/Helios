#!/bin/bash

# Enable Nvidia GPU support if detected
if which nvidia-smi && [ "${DISABLE_ZINK}" == "false" ]; then
  export LIBGL_KOPPER_DRI2=1
  export MESA_LOADER_DRIVER_OVERRIDE=zink
  export GALLIUM_DRIVER=zink
fi

if [ -x /usr/bin/xfce4-session ]; then
	/usr/bin/xfce4-session 2>&1
else
	echo "Desktop Environment not found."
	exit 1
fi
