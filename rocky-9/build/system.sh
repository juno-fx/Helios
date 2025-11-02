#!/bin/bash

set -e

dnf install --nogpgcheck -y \
	epel-release \
	https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
dnf config-manager --add-repo https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.repo
dnf config-manager --set-enabled crb
dnf config-manager --set-enabled devel

#PCoIP Repos
dnf config-manager --add-repo https://dl.anyware.hp.com/g82Ye1S2Gk2eeY1G/pcoip-agent/rpm/el/9/x86_64
dnf config-manager --add-repo https://dl.anyware.hp.com/g82Ye1S2Gk2eeY1G/pcoip-agent/rpm/el/9/noarch
dnf config-manager --add-repo https://dl.anyware.hp.com/g82Ye1S2Gk2eeY1G/pcoip-agent/rpm/el/9/SRPMS
dnf config-manager --setopt="dl.anyware.hp.com_g82Ye1S2Gk2eeY1G_pcoip-agent_rpm_el_9_x86_64.gpgcheck=0" --save
dnf config-manager --setopt="dl.anyware.hp.com_g82Ye1S2Gk2eeY1G_pcoip-agent_rpm_el_9_noarch.gpgcheck=0" --save
dnf config-manager --setopt="dl.anyware.hp.com_g82Ye1S2Gk2eeY1G_pcoip-agent_rpm_el_9_SRPMS.gpgcheck=0" --save
# install system
dnf update -y
dnf install -y --allowerasing --setopt=install_weak_deps=False --best \
	$(cat /lists/rhel.list) \
	fastfetch

# handle background
mv -v /usr/share/backgrounds/rocky-default-9-onyx-mountains.png /tmp/background.png
rm -rfv /usr/share/backgrounds/*
mv -v /tmp/background.png /usr/share/backgrounds/

# install node
dnf module install "nodejs:$SELKIES_NODE_VERSION/common" -y

# remove screensaver and lock screen
rm -f /etc/xdg/autostart/xscreensaver.desktop

# configure vgl
/opt/VirtualGL/bin/vglserver_config +glx +s +f +t

# run clean up
dnf config-manager --set-disabled crb
dnf config-manager --set-disabled devel
dnf remove --nogpgcheck -y \
	epel-release \
	https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
dnf clean all -y
