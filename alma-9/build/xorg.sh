#!/bin/bash

set -e

cd /src

# pulling latest support xserver version for KasmVNC
XORG_VER="1.20.14"
wget -O /tmp/xorg-server-${XORG_VER}.tar.gz "https://www.x.org/archive/individual/xserver/xorg-server-${XORG_VER}.tar.gz"
tar --strip-components=1 -C unix/xserver -xf /tmp/xorg-server-${XORG_VER}.tar.gz
cd unix/xserver

# Apply patches
patch -Np1 -i ../xserver120.patch
patch -s -p0 <../CVE-2022-2320-v1.20.patch

autoreconf -i
./configure \
	--prefix=/opt/kasmweb \
	--with-xkb-path=/usr/share/X11/xkb \
	--with-xkb-output=/var/lib/xkb \
	--with-xkb-bin-directory=/usr/bin \
	--with-default-font-path="/usr/share/fonts/X11/misc,/usr/share/fonts/X11/cyrillic,/usr/share/fonts/X11/100dpi/:unscaled,/usr/share/fonts/X11/75dpi/:unscaled,/usr/share/fonts/X11/Type1,/usr/share/fonts/X11/100dpi,/usr/share/fonts/X11/75dpi,built-ins" \
	--with-sha1=libcrypto \
	--without-dtrace \
	--disable-dri \
	--disable-static \
	--disable-xinerama \
	--disable-xvfb \
	--disable-xnest \
	--disable-xorg \
	--disable-dmx \
	--disable-xwin \
	--disable-xephyr \
	--disable-kdrive \
	--disable-config-hal \
	--disable-config-udev \
	--disable-dri2 \
	--enable-glx \
	--disable-xwayland \
	--enable-dri3
find . -name "Makefile" -exec sed -i 's/-Werror=array-bounds//g' {} \;
make -j4
