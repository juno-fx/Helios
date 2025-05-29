set -e

# add srcs for deb
sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources

# install deps
apt-get update
apt-get build-dep -y \
  libxfont-dev \
  xorg-server
apt-get install -y \
  curl \
  wget \
  autoconf \
  automake \
  cmake \
  git \
  grep \
  libavcodec-dev \
  libdrm-dev \
  libepoxy-dev \
  libgbm-dev \
  libgif-dev \
  libgnutls28-dev \
  libgnutls28-dev \
  libjpeg-dev \
  libjpeg-turbo8-dev \
  libpciaccess-dev \
  libpng-dev \
  libssl-dev \
  libtiff-dev \
  libtool \
  libx11-dev \
  libxau-dev \
  libxcursor-dev \
  libxcursor-dev \
  libxcvt-dev \
  libxdmcp-dev \
  libxext-dev \
  libxkbfile-dev \
  libxrandr-dev \
  libxrandr-dev \
  libxshmfence-dev \
  libxtst-dev \
  libavformat-dev \
  libswscale-dev \
  meson \
  nettle-dev \
  tar \
  tightvncserver \
  wget \
  wayland-protocols \
  xinit \
  xserver-xorg-dev \
  libsharpyuv-dev
