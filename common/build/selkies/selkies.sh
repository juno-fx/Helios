#!/bin/bash
# reference: https://github.com/linuxserver/docker-baseimage-selkies/blob/ubuntunoble/Dockerfile#L179

set -ex

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

# download selkies
curl -o selkies.tar.gz -L "https://github.com/selkies-project/selkies/archive/${SELKIES_VERSION}.tar.gz"
tar xf selkies.tar.gz
cd selkies-*
sed -i '/cryptography/d' pyproject.toml
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --break-system-packages
python3 -m pip install --upgrade pip --break-system-packages
pip install -r /tmp/reqs/selkies-requirements.txt --break-system-packages
pip install . --break-system-packages
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
curl -o /usr/share/selkies/www/icon.png https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/selkies-logo.png &&
	curl -o /usr/share/selkies/www/favicon.ico https://raw.githubusercontent.com/linuxserver/docker-templates/refs/heads/master/linuxserver.io/img/selkies-icon.ico

# clean up pip
pip cache purge

# hook into distro dependencies cleanup
bash $cleanup
