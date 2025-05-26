
set -e

export DEBIAN_FRONTEND=noninteractive

sed -i '/locale/d' /etc/dpkg/dpkg.cfg.d/excludes
apt-get update
apt-get upgrade -y
apt-get install -y gnupg curl wget
wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | \
  gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/VirtualGL.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main" > /etc/apt/sources.list.d/virtualgl.list
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
echo 'deb https://deb.nodesource.com/node_20.x jammy main' > /etc/apt/sources.list.d/nodesource.list
apt-get update
apt-get install --no-install-recommends -y \
  ca-certificates \
  dbus-x11 \
  dunst \
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
  libjpeg-turbo8 \
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
  locales-all \
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
  software-properties-common \
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
  xubuntu-default-settings \
  xubuntu-icon-theme \
  libdrm-dev \
  nvtop \
  virtualgl

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
/opt/VirtualGL/bin/vglserver_config +glx +s +f +t

# run clean up
apt clean -y
apt autoclean -y
apt autoremove --purge -y
rm -rfv /var/lib/{apt,cache,log}/ /tmp/* /etc/systemd /var/lib/apt/lists/* /var/tmp/* /tmp/*
