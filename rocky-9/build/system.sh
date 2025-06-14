#!/bin/bash

set -e

dnf install --nogpgcheck -y \
	epel-release \
	https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
dnf config-manager --add-repo https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.repo
dnf config-manager --set-enabled crb
dnf config-manager --set-enabled devel

dnf update -y
dnf install -y --setopt=install_weak_deps=False --best \
	xfce4-whiskermenu-plugin \
	procps-ng \
	libXdmcp \
	fastfetch \
	git \
	ca-certificates \
	dbus-x11 \
	ffmpeg \
	fuse-overlayfs \
	intel-media-driver \
	iproute \
	libjpeg-turbo \
	libnotify \
	libstdc++ \
	libwebp \
	libXfont2 \
	libxshmfence \
	mesa-dri-drivers \
	mesa-libgbm \
	mesa-libGL \
	mesa-vulkan-drivers \
	nginx \
	nodejs \
	openssh-clients \
	openssl \
	pciutils-libs \
	perl \
	perl-DateTime \
	perl-Hash-Merge-Simple \
	perl-List-MoreUtils \
	perl-Switch \
	perl-Try-Tiny \
	perl-YAML-Tiny \
	pixman \
	pulseaudio \
	pulseaudio-utils \
	python3 \
	python3-pyxdg \
	setxkbmap \
	util-linux \
	xauth \
	xkbcomp \
	xkeyboard-config \
	Thunar \
	xfce4-panel \
	xfce4-session \
	xfce4-settings \
	xfce4-terminal \
	xfconf \
	xfdesktop \
	xfwm4 \
	xfwm4-themes \
	VirtualGL \
	xfce-polkit \
	wget

# handle background
mv -v /usr/share/backgrounds/rocky-default-9-onyx-mountains.png /tmp/background.png
rm -rfv /usr/share/backgrounds/*
mv -v /tmp/background.png /usr/share/backgrounds/

# install node
dnf module install nodejs:20/common -y

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
/opt/VirtualGL/bin/vglserver_config +glx +s +f +t

# install font
mkdir -pv /usr/share/fonts/cascadia-code
cd /tmp
wget https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip
unzip CascadiaCode-2407.24.zip
mv -v otf/static/* /usr/share/fonts/cascadia-code/
rm -rfv /tmp/*
fc-cache -f -v

# run clean up
dnf config-manager --set-disabled crb
dnf config-manager --set-disabled devel
dnf remove --nogpgcheck -y \
	epel-release \
	https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
dnf clean all -y
