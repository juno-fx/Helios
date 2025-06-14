#!/bin/ash

set -e

echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >>/etc/apk/repositories

apk add --no-cache \
	bash \
	ca-certificates \
	dbus-x11 \
	ffmpeg \
	font-noto \
	font-noto-emoji \
	fuse-overlayfs \
	gcompat \
	intel-media-driver \
	iproute2-minimal \
	lang \
	libgcc \
	libgomp \
	libjpeg-turbo \
	libnotify \
	libstdc++ \
	libwebp \
	libxfont2 \
	libxshmfence \
	mcookie \
	mesa \
	mesa-dri-gallium \
	mesa-gbm \
	mesa-gl \
	mesa-va-gallium \
	mesa-vulkan-ati \
	mesa-vulkan-intel \
	mesa-vulkan-layers \
	mesa-vulkan-swrast \
	nginx \
	nodejs \
	openbox \
	openssh-client \
	openssl \
	pciutils-libs \
	perl \
	perl-datetime \
	perl-hash-merge-simple \
	perl-list-moreutils \
	perl-switch \
	perl-try-tiny \
	perl-yaml-tiny \
	pixman \
	pulseaudio \
	pulseaudio-utils \
	py3-xdg \
	python3 \
	setxkbmap \
	tar \
	vulkan-tools \
	xauth \
	xf86-video-amdgpu \
	xf86-video-ati \
	xf86-video-intel \
	xf86-video-nouveau \
	xf86-video-qxl \
	xkbcomp \
	xkeyboard-config \
	xfce4 \
	xfce4-terminal \
	xfce4-whiskermenu-plugin \
	virtualgl \
	shadow \
	curl \
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
rm -rfv /tmp/*
fc-cache -f -v
