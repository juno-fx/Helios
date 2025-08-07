#!/bin/ash

set -e

echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories

apk add --no-cache \
	$(cat /lists/alpine.list) \
	fastfetch

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
vglserver_config +glx +s +f +t
