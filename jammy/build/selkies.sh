#!/bin/bash
# reference: https://github.com/linuxserver/docker-baseimage-selkies/blob/ubuntunoble/Dockerfile#L179

set -e

# install selkies build dependencies
apt update
apt install --no-install-recommends -y $(cat /lists/selkies.list)

# move to work directory
cd /tmp/

# download selkies
curl -o selkies.tar.gz -L "https://github.com/selkies-project/selkies/archive/${SELKIES_VERSION}.tar.gz"
tar xf selkies.tar.gz
cd selkies-*
sed -i '/cryptography/d' pyproject.toml
pip install --upgrade pip
pip install --break-system-packages .
pip install --upgrade setuptools --break-system-packages

# setup interposer
cd addons/js-interposer
gcc -shared -fPIC -ldl -o selkies_joystick_interposer.so joystick_interposer.c
mv selkies_joystick_interposer.so /usr/lib/selkies_joystick_interposer.so

# setup udev fake library
cd ../fake-udev
make
mkdir /opt/lib
mv libudev.so.1.0.0-fake /opt/lib/

# why do I need this?
mkdir -p /usr/share/selkies/www
curl -o /usr/share/selkies/www/icon.png https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/selkies-logo.png && \
curl -o /usr/share/selkies/www/favicon.ico https://raw.githubusercontent.com/linuxserver/docker-templates/refs/heads/master/linuxserver.io/img/selkies-icon.ico

# clean up pip
pip cache purge

# remove selkies build dependencies
apt remove -y $(cat /lists/selkies.list)

# clean up
apt clean -y
apt autoclean -y
apt autoremove --purge -y
rm -rfv /var/lib/{apt,cache,log}/ /etc/systemd /var/lib/apt/lists/* /var/tmp/* /tmp/*
