#!/bin/ash

set -e

# install deps
apk add --no-cache \
	alpine-release \
	alpine-sdk \
	autoconf \
	automake \
	bash \
	ca-certificates \
	cmake \
	coreutils \
	curl \
	eudev-dev \
	font-cursor-misc \
	font-misc-misc \
	font-util-dev \
	git \
	grep \
	jq \
	libdrm-dev \
	libepoxy-dev \
	libjpeg-turbo-dev \
	libjpeg-turbo-static \
	libpciaccess-dev \
	libtool \
	libwebp-dev \
	libx11-dev \
	libxau-dev \
	libxcb-dev \
	libxcursor-dev \
	libxcvt-dev \
	libxdmcp-dev \
	libxext-dev \
	libxfont2-dev \
	libxkbfile-dev \
	libxrandr-dev \
	libxshmfence-dev \
	libxtst-dev \
	mesa-dev \
	mesa-dri-gallium \
	meson \
	nettle-dev \
	openssl-dev \
	pixman-dev \
	procps \
	shadow \
	tar \
	tzdata \
	wayland-dev \
	wayland-protocols \
	xcb-util-dev \
	xcb-util-image-dev \
	xcb-util-keysyms-dev \
	xcb-util-renderutil-dev \
	xcb-util-wm-dev \
	xinit \
	xkbcomp \
	xkbcomp-dev \
	xkeyboard-config \
	xorgproto \
	xorg-server-common \
	xorg-server-dev \
	xtrans
