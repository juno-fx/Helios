#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

cat >/etc/apt/preferences.d/firefox-no-snap <<EOL
Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
EOL

sed -i '/locale/d' /etc/dpkg/dpkg.cfg.d/excludes
apt update
apt upgrade -y
apt install -y gnupg curl wget
wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey |
	gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/VirtualGL.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main" >/etc/apt/sources.list.d/virtualgl.list
curl -fsSL "https://deb.nodesource.com/setup_$SELKIES_NODE_VERSION.x" | bash -
apt update

apt install --no-install-recommends -y \
	$(cat /lists/ubuntu.list) \
	neofetch

# ubuntu icon hack
rm -rf /usr/share/icons/elementary
ln -sf /usr/share/icons/elementary-xfce-darker /usr/share/icons/elementary

# backwards compat for neofetch
ln -sf /bin/neofetch /bin/fastfetch

# handle background
rm -rfv /usr/share/backgrounds/*

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
/opt/VirtualGL/bin/vglserver_config +egl +s +f +t

# build locale
/usr/sbin/locale-gen en_US.UTF-8

# run clean up
apt clean -y
apt autoclean -y
apt autoremove --purge -y
rm -rfv /var/lib/{apt,cache,log}/ /etc/systemd /var/lib/apt/lists/* /var/tmp/* /tmp/*
