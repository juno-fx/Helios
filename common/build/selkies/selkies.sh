#!/bin/bash
# reference: https://github.com/linuxserver/docker-baseimage-selkies/blob/ubuntunoble/Dockerfile#L179

set -ex

dependencies=/tmp/rhel-dependencies.sh
cleanup=/tmp/rhel-clean.sh

if command -v apt >/dev/null 2>&1; then
	dependencies=/tmp/debian-dependencies.sh
	cleanup=/tmp/debian-clean.sh
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
# widen av constraint to accept 15.x (14.x wheels use manylinux_2_17 tags not recognized by this pip)
sed -i 's/av>=14.0.0,<15.0.0/av>=15.0.0,<16.0.0/' pyproject.toml
PY_VER=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if [ "$PY_VER" = "3.9" ]; then
    PIP_URL="https://bootstrap.pypa.io/pip/3.9/get-pip.py"
else
    PIP_URL="https://bootstrap.pypa.io/get-pip.py"
fi
# wrap pip to always use --break-system-packages (PEP 668)
pip() { command pip "$@" --break-system-packages; }

wget -O get-pip.py "$PIP_URL"
python3 get-pip.py --break-system-packages
pip install --upgrade pip
pip install --only-binary av,pixelflux -r /tmp/reqs/selkies-requirements.txt
pip install .
pip install --upgrade setuptools

# setup interposer
cd addons/js-interposer
gcc -shared -fPIC -ldl -o selkies_joystick_interposer.so joystick_interposer.c
mv selkies_joystick_interposer.so /usr/lib/selkies_joystick_interposer.so

# setup udev fake library
cd ../fake-udev
make
mkdir /opt/lib
mv libudev.so.1.0.0-fake /opt/lib/

# setup Selkies web UI directory and branding assets
mkdir -p /usr/share/selkies/www
curl -o /usr/share/selkies/www/icon.png https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/selkies-logo.png &&
	curl -o /usr/share/selkies/www/favicon.ico https://raw.githubusercontent.com/linuxserver/docker-templates/refs/heads/master/linuxserver.io/img/selkies-icon.ico

# clean up pip
command pip cache purge

# hook into distro dependencies cleanup
bash $cleanup
