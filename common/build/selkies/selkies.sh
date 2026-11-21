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

pip install --upgrade pip  --break-system-packages || pip install --upgrade pip || true
pip install --break-system-packages . || pip install .

# setup input interposer (upstream renamed js-interposer -> input-interposer in 2.0.0)
cd addons/input-interposer
gcc -shared -fPIC -ldl -o selkies_input_interposer.so input_interposer.c
mv selkies_input_interposer.so /usr/lib/selkies_input_interposer.so

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
