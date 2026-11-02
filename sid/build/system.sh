#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

# add srcs for deb
sed -Ei 's/^Components: main /Components: main contrib non-free non-free-firmware /' /etc/apt/sources.list.d/debian.sources
cat >/etc/apt/sources.list <<EOL
deb http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ sid main contrib non-free non-free-firmware
EOL

apt update
apt upgrade -y
apt install -y gnupg curl wget
wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey |
	gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/VirtualGL.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main" >/etc/apt/sources.list.d/virtualgl.list
apt update

apt install --no-install-recommends -y \
	$(cat /lists/debian.list) \
	fastfetch \
	gcc \
	g++ \
	python3-dev

rm -rfv /usr/share/backgrounds/*

# backwards compat for password generation
sudo apt-get install -y libcrypt-dev build-essential
pip install crypt-r --break-system-packages

# package clean up
apt remove --purge -y \
	gcc \
	g++ \
	python3-dev \
	libcrypt-dev \
	build-essential

# remove duplicate sources
rm -f /etc/apt/sources.list

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
/opt/VirtualGL/bin/vglserver_config +glx +s +f +t

# build locale
/usr/sbin/locale-gen en_US.UTF-8

# Run ansible playbooks from hook directories
if [ -d "/tmp/playbooks/distro" ]; then
    echo "Running sid-specific Ansible playbooks..."

    # Install ansible if not present
    if ! command -v ansible-playbook &>/dev/null; then
        pip install --break-system-packages ansible
    fi

    # Run playbooks from distro playbooks directory
    for playbook in /tmp/playbooks/distro/*.yml; do
        [ -f "$playbook" ] && ansible-playbook "$playbook" --connection=local
    done

    # Clean up ansible to keep container lean
    pip uninstall -y ansible 2>/dev/null || true
    rm -rf /root/.cache/pip 2>/dev/null || true
fi

# run clean up
apt clean -y
apt autoclean -y
apt autoremove --purge -y
rm -rfv /var/lib/{apt,cache,log}/ /etc/systemd /var/lib/apt/lists/* /var/tmp/* /tmp/*
