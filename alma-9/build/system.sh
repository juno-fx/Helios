#!/bin/bash

set -e

dnf install --nogpgcheck -y \
	epel-release \
	https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm \
	almalinux-release-devel
dnf config-manager --add-repo https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.repo
dnf config-manager --set-enabled crb

# install system
dnf update -y
dnf install -y --allowerasing --setopt=install_weak_deps=False --best \
	$(cat /lists/rhel.list) \
	fastfetch

# handle background
mv -v /usr/share/backgrounds/Alma-waves-sunset-2560x1600.jpg /tmp/background.png
rm -rfv /usr/share/backgrounds/*
mv -v /tmp/background.png /usr/share/backgrounds/

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
/opt/VirtualGL/bin/vglserver_config +glx +s +f +t

# Run ansible playbooks from hook directories
if [ -d "/tmp/playbooks/distro" ]; then
    echo "Running alma-9-specific Ansible playbooks..."

    # Install ansible if not present
    if ! command -v ansible-playbook &>/dev/null; then
        pip install ansible
    fi

    # Run playbooks from distro playbooks directory
    for playbook in /tmp/playbooks/distro/*.yml; do
        [ -f "$playbook" ] && ansible-playbook "$playbook" --connection=local
    done

    # Clean up ansible to keep container lean
    pip uninstall -y ansible 2>/dev/null || true
    rm -rf /root/.cache/pip 2>/dev/null || true
fi

dnf config-manager --set-disabled crb
dnf remove --nogpgcheck -y \
	epel-release \
	https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm \
	almalinux-release-devel
dnf clean all -y
