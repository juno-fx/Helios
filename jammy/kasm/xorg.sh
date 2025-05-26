set -e

cd /src

XORG_VER="21.1.4"
wget --no-check-certificate -O /tmp/xorg-server-${XORG_VER}.tar.gz "https://www.x.org/archive/individual/xserver/xorg-server-${XORG_VER}.tar.gz"
tar --strip-components=1 -C unix/xserver -xf /tmp/xorg-server-${XORG_VER}.tar.gz
cd unix/xserver

# Need to figure out why these aren't coming in
patch -Np1 -i ../xserver21.patch
patch -s -p0 < ../CVE-2022-2320-v1.20.patch

autoreconf -i
./configure \
  --disable-config-hal \
  --disable-config-udev \
  --disable-dmx \
  --disable-dri \
  --disable-dri2 \
  --disable-kdrive \
  --disable-static \
  --disable-xephyr \
  --disable-xinerama \
  --disable-xnest \
  --disable-xorg \
  --disable-xvfb \
  --disable-xwayland \
  --disable-xwin \
  --enable-dri3 \
  --enable-glx \
  --prefix=/opt/kasmweb \
  --with-default-font-path="/usr/share/fonts/X11/misc,/usr/share/fonts/X11/cyrillic,/usr/share/fonts/X11/100dpi/:unscaled,/usr/share/fonts/X11/75dpi/:unscaled,/usr/share/fonts/X11/Type1,/usr/share/fonts/X11/100dpi,/usr/share/fonts/X11/75dpi,built-ins" \
  --without-dtrace \
  --with-sha1=libcrypto \
  --with-xkb-bin-directory=/usr/bin \
  --with-xkb-output=/var/lib/xkb \
  --with-xkb-path=/usr/share/X11/xkb
find . -name "Makefile" -exec sed -i 's/-Werror=array-bounds//g' {} \;
make -j4
