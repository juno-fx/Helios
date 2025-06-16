#!/bin/ash

set -e

echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories

apk add --no-cache \
	$(cat /tmp/lists/alpine.list) \
	fastfetch

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
vglserver_config +glx +s +f +t

# install font
mkdir -pv /usr/share/fonts/cascadia-code
cd /tmp
wget https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip
unzip CascadiaCode-2407.24.zip
mv -v otf/static/* /usr/share/fonts/cascadia-code/
rm -rfv /tmp/* /var/cache/apk/*
fc-cache -f -v
