#!/bin/bash
# reference: https://github.com/linuxserver/docker-baseimage-selkies/blob/ubuntunoble/Dockerfile#L179
# another good one: https://github.com/selkies-project/docker-selkies-glx-desktop

set -ex

export SELKIES_VERSION="v1.6.2"

dependencies=/tmp/rhel-dependencies.sh
cleanup=/tmp/rhel-clean.sh

if command -v apt >/dev/null 2>&1; then
  dependencies=/tmp/debian-dependencies.sh
  cleanup=/tmp/debian-clean.sh
elif command -v dnf >/dev/null 2>&1; then
  dependencies=/tmp/rhel-dependencies.sh
  cleanup=/tmp/rhel-clean.sh
fi

echo "Using dependencies script: $dependencies"
bash $dependencies

# move to work directory
cd /tmp/



# TODO: when we upgrade selkies, check if it supports websockets > 13.1
# Currently it fails due to cross-lib deprecations https://websockets.readthedocs.io/en/stable/faq/client.html#how-do-i-set-http-headers
pip install websockets==13.1

# download selkies
curl -o selkies.tar.gz -L "https://github.com/selkies-project/selkies/archive/${SELKIES_VERSION}.tar.gz"
tar xf selkies.tar.gz
cd selkies-*
sed -i '/cryptography/d' pyproject.toml
pip install --upgrade pip
pip install . --break-system-packages
pip install --upgrade setuptools --break-system-packages

# setup interposer
cd addons/js-interposer
gcc -shared -fPIC -ldl -o selkies_joystick_interposer.so joystick_interposer.c
mv selkies_joystick_interposer.so /usr/lib/selkies_joystick_interposer.so


# since git 2.49, we can pass clone --max-depth --revision <commit sha>
# most modern distros are on 2.43 >.<
git init wolf
git -C wolf remote add origin https://github.com/games-on-whales/wolf.git
# todo: parametrize that commit
git -C wolf fetch --depth 1 origin d2a5c35bf66374292745e00571fb91f2f995a8ab
git -C wolf checkout FETCH_HEAD
g++ -shared -fPIC -std=c++17 -Iwolf/src/fake-udev -o libudev.so.1.0.0-fake wolf/src/fake-udev/*cpp

mkdir -p /opt/lib
mv libudev.so.1.0.0-fake /opt/lib/

# Todo: unhardcode
wget https://github.com/selkies-project/selkies/releases/download/v1.6.2/gstreamer-selkies_gpl_v1.6.2_ubuntu22.04_amd64.tar.gz -O /tmp/gstreamer-selkies_gpl_v1.6.2_ubuntu22.04_amd64.tar.gz
tar -xzf /tmp/gstreamer-selkies_gpl_v1.6.2_ubuntu22.04_amd64.tar.gz -C /opt
rm /tmp/gstreamer-selkies_gpl_v1.6.2_ubuntu22.04_amd64.tar.gz

# why do I need this?
mkdir -p /usr/share/selkies/www
curl -o /usr/share/selkies/www/icon.png https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/selkies-logo.png && \
curl -o /usr/share/selkies/www/favicon.ico https://raw.githubusercontent.com/linuxserver/docker-templates/refs/heads/master/linuxserver.io/img/selkies-icon.ico

# clean up pip
pip cache purge

# hook into distro dependencies cleanup
bash $cleanup
