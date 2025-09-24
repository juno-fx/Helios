#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" >>/etc/apt/sources.list
echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" >>/etc/apt/sources.list

apt update
apt upgrade -y
apt install -y gnupg curl wget
wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/VirtualGL.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main" >/etc/apt/sources.list.d/virtualgl.list
curl -fsSL "https://deb.nodesource.com/setup_$SELKIES_NODE_VERSION.x" | bash -
apt update

apt install --no-install-recommends -y \
	$(cat /lists/debian.list) \
	fastfetch \
	kali-wallpapers-2025 \
	gcc \
	g++ \
	python3-dev \
	python3-pip

# handle background
mv -v /usr/share/backgrounds/kali/kali-oleo-16x9.png /tmp/background.png
rm -rfv /usr/share/backgrounds/*
mv -v /tmp/background.png /usr/share/backgrounds/

# backwards compat for password generation
pip install crypt-r --break-system-packages

# package clean up
apt remove --purge -y \
	gcc \
	g++ \
	python3-dev \
	python3-pip

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
/opt/VirtualGL/bin/vglserver_config +glx +s +f +t

# build locale
/usr/sbin/locale-gen en_US.UTF-8

# run clean up
apt clean -y
apt autoclean -y
apt autoremove --purge -y
rm -rfv /var/lib/{apt,cache,log}/ /tmp/* /etc/systemd /var/lib/apt/lists/* /var/tmp/* /tmp/*
