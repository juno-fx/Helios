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
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt update

apt install --no-install-recommends -y \
	gcc \
	g++ \
	python3-dev \
	python3-pip \
	fastfetch \
	ca-certificates \
	dbus-x11 \
	ffmpeg \
	file \
	fuse-overlayfs \
	intel-media-va-driver \
	libdatetime-perl \
	libfontenc1 \
	libfreetype6 \
	libgbm1 \
	libgcrypt20 \
	libgl1-mesa-dri \
	libglu1-mesa \
	libgnutls30 \
	libgomp1 \
	libhash-merge-simple-perl \
	libnotify-bin \
	liblist-moreutils-perl \
	libp11-kit0 \
	libpam0g \
	libpixman-1-0 \
	libscalar-list-utils-perl \
	libswitch-perl \
	libtasn1-6 \
	libtry-tiny-perl \
	libvulkan1 \
	libwebp7 \
	libx11-6 \
	libxau6 \
	libxcb1 \
	libxcursor1 \
	libxdmcp6 \
	libxext6 \
	libxfixes3 \
	libxfont2 \
	libxinerama1 \
	libxshmfence1 \
	libxtst6 \
	libyaml-tiny-perl \
	mesa-va-drivers \
	mesa-vulkan-drivers \
	nginx \
	nodejs \
	openssh-client \
	openssl \
	pciutils \
	perl \
	procps \
	pulseaudio \
	pulseaudio-utils \
	python3 \
	ssl-cert \
	tar \
	util-linux \
	x11-apps \
	x11-common \
	x11-utils \
	x11-xkb-utils \
	x11-xserver-utils \
	xauth \
	xdg-utils \
	xfonts-base \
	xkb-data \
	xserver-common \
	xserver-xorg-core \
	xserver-xorg-video-amdgpu \
	xserver-xorg-video-ati \
	xserver-xorg-video-intel \
	xserver-xorg-video-qxl \
	xutils \
	zlib1g \
	xfce4-terminal \
	xfce4 \
	xfce4-whiskermenu-plugin \
	libdrm-dev \
	nvtop \
	virtualgl \
	vim \
	unzip \
	tumbler \
	tumbler-common \
	tumbler-plugins-extra \
	fonts-cascadia-code \
	kali-wallpapers-2025 \
	xssstate

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

# run clean up
apt clean -y
apt autoclean -y
apt autoremove --purge -y
rm -rfv /var/lib/{apt,cache,log}/ /tmp/* /etc/systemd /var/lib/apt/lists/* /var/tmp/* /tmp/*
