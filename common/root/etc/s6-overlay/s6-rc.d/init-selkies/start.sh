#!/usr/bin/env bash
# reference: https://github.com/linuxserver/docker-baseimage-selkies/blob/ubuntunoble/root/etc/s6-overlay/s6-rc.d/init-selkies-config/run

# set env based on vars
printf "${GST_DEBUG:-*:1}" > /run/s6/container_environment/GST_DEBUG
printf "${SELKIES_ENCODER:-x264enc}" > /run/s6/container_environment/SELKIES_ENCODER
printf "${SELKIES_FRAMERATE:-60}" > /run/s6/container_environment/SELKIES_FRAMERATE
printf "${SELKIES_ENABLE_RESIZE:-true}" > /run/s6/container_environment/SELKIES_ENABLE_RESIZE
printf "${DISPLAY_SIZEW:-1024}" > /run/s6/container_environment/DISPLAY_SIZEW
printf "${DISPLAY_SIZEH:-768}" > /run/s6/container_environment/DISPLAY_SIZEH
printf "${DISPLAY_REFRESH:60}" > /run/s6/container_environment/DISPLAY_REFRESH
printf "${DISPLAY_DPI:-96}" > /run/s6/container_environment/DISPLAY_DPI
printf "${DISPLAY_CDEPTH:-24}" > /run/s6/container_environment/DISPLAY_CDEPTH
printf "/tmp/.XDG" > /run/s6/container_environment/XDG_RUNTIME_DIR


if [[ -z ${NO_GAMEPAD+x} ]]; then
  printf "/usr/lib/selkies_joystick_interposer.so:/opt/lib/libudev.so.1.0.0-fake" > /run/s6/container_environment/LD_PRELOAD
fi

printf "${LC_ALL%.UTF-8}" > /run/s6/container_environment/LANGUAGE
printf "${LC_ALL}" > /run/s6/container_environment/LANG


# JoyStick (JS) folder setup
mkdir -pm1777 /dev/input
touch /tmp/selkies_js.log
mknod /dev/input/js0 c 13 0
mknod /dev/input/js1 c 13 1
mknod /dev/input/js2 c 13 2
mknod /dev/input/js3 c 13 3
mknod /dev/input/event1000 c 13 1064
mknod /dev/input/event1001 c 13 1065
mknod /dev/input/event1002 c 13 1066
mknod /dev/input/event1003 c 13 1067
chmod 777 /dev/input/js* /dev/input/event* /tmp/selkies*

# Manifest creation
echo "{
  \"name\": \"Helios\",
  \"short_name\": \"Helios\",
  \"manifest_version\": 2,
  \"version\": \"1.0.0\",
  \"display\": \"fullscreen\",
  \"background_color\": \"#000000\",
  \"theme_color\": \"#000000\",
  \"icons\": [
    {
      \"src\": \"icon.png\",
      \"type\": \"image/png\",
      \"sizes\": \"180x180\"
    }
  ],
  \"start_url\": \"/\"
}" > /usr/share/selkies/www/manifest.json
