set -e

dnf install -y epel-release
dnf config-manager --set-enabled crb
dnf config-manager --set-enabled devel
dnf config-manager --add-repo https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.repo
dnf update -y

# install deps
dnf install -y \
  autoconf \
  automake \
  bzip2 \
  cmake \
  gcc \
  gcc-c++ \
  git \
  libdrm-devel \
  libepoxy-devel \
  libjpeg-turbo-devel \
  libjpeg-turbo-static \
  libpciaccess-devel \
  libglvnd-devel \
  libtool \
  libwebp-devel \
  libX11-devel \
  libXau-devel \
  libxcb-devel \
  libXcursor-devel \
  libXdmcp-devel \
  libXext-devel \
  libXfont2-devel \
  libxkbfile-devel \
  libXrandr-devel \
  libxshmfence-devel \
  libXtst-devel \
  llvm-libs \
  mesa-libEGL-devel \
  mesa-libgbm-devel \
  mesa-libGL-devel \
  meson \
  nettle-devel \
  openssl-devel \
  patch \
  pixman-devel \
  wayland-devel \
  wget \
  xcb-util-devel \
  xcb-util-image-devel \
  xcb-util-keysyms-devel \
  xcb-util-renderutil-devel \
  xcb-util-wm-devel \
  xinit \
  xkbcomp \
  xkeyboard-config \
  xorg-x11-font-utils \
  xorg-x11-proto-devel \
  xorg-x11-server-common \
  xorg-x11-server-devel \
  xorg-x11-xtrans-devel \
  xorg-x11-server-source \
  VirtualGL

cd /tmp
git clone https://gitlab.freedesktop.org/xorg/lib/libxcvt.git
cd libxcvt
meson build
ninja -C build/ install
