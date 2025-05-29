set -e

# add srcs for deb
echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" >>/etc/apt/sources.list
echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" >>/etc/apt/sources.list

# install deps
apt-get update
apt-get build-dep -y \
	libxfont-dev \
	xorg-server
apt-get install -y \
	curl \
	autoconf \
	automake \
	cmake \
	console-data \
	git \
	grep \
	kbd \
	libavcodec-dev \
	libdrm-dev \
	libepoxy-dev \
	libgbm-dev \
	libgif-dev \
	libgnutls28-dev \
	libgnutls28-dev \
	libjpeg-dev \
	libpciaccess-dev \
	libpng-dev \
	libssl-dev \
	libtiff-dev \
	libtool \
	libwebp-dev \
	libx11-dev \
	libxau-dev \
	libxcursor-dev \
	libxcursor-dev \
	libxdmcp-dev \
	libxext-dev \
	libxkbfile-dev \
	libxrandr-dev \
	libxrandr-dev \
	libxshmfence-dev \
	libxtst-dev \
	meson \
	nettle-dev \
	tar \
	tightvncserver \
	wget \
	wayland-protocols \
	x11-apps \
	x11-common \
	x11-utils \
	x11-xkb-utils \
	x11-xserver-utils \
	xauth \
	xdg-utils \
	xfonts-base \
	xinit \
	xkb-data \
	xserver-xorg-dev
