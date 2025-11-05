#!/usr/bin/env bash
# https://anyware.hp.com/components/graphics-agent-for-linux/24.07/documentation/administrators-guide/installation-guide/installing-the-agent
#
printf "${DISPLAY_SIZEW:-1024}" >/run/s6/container_environment/DISPLAY_SIZEW
printf "${DISPLAY_SIZEH:-768}" >/run/s6/container_environment/DISPLAY_SIZEH
printf "${DISPLAY_REFRESH:60}" >/run/s6/container_environment/DISPLAY_REFRESH
printf "${DISPLAY_DPI:-96}" >/run/s6/container_environment/DISPLAY_DPI
printf "${DISPLAY_CDEPTH:-24}" >/run/s6/container_environment/DISPLAY_CDEPTH
printf "/tmp/.XDG" >/run/s6/container_environment/XDG_RUNTIME_DIR

# pcoip-register-host --registration-code=${HP_ANYWHERE_REGISTRATION_CODE}
