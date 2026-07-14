#!/bin/bash

set -e
source /tmp/version.sh

echo "Installing Amazon DCV on RHEL-family ($SRC)..."

ARCH="x86_64"

# download DCV server tgz
DCV_TGZ="nice-dcv-${DCV_VERSION}-${DCV_BUILD}-el9-${ARCH}.tgz"
DCV_URL="https://d1uj6qtbmh3dt5.cloudfront.net/${DCV_VERSION}/Servers/${DCV_TGZ}"

echo "Downloading DCV server from ${DCV_URL}..."
wget -q "${DCV_URL}" -O "/tmp/${DCV_TGZ}"
tar -xzf "/tmp/${DCV_TGZ}" -C /tmp/

cd "/tmp/nice-dcv-${DCV_VERSION}-${DCV_BUILD}-el9-${ARCH}"

# runtime deps (glx-utils, pulseaudio-utils, xorg-x11-drv-dummy)
# are already in rhel.list and installed by distro system.sh

# install DCV packages
echo "Installing DCV server packages..."
dnf install -y \
    ./nice-dcv-server-${DCV_VERSION}.${DCV_BUILD}-1.el9.${ARCH}.rpm \
    ./nice-dcv-web-viewer-${DCV_VERSION}.${DCV_BUILD}-1.el9.${ARCH}.rpm \
    ./nice-xdcv-${DCV_VERSION}.${DCV_XDCV_BUILD}-1.el9.${ARCH}.rpm

# install DCV-GL for GPU sharing (only on x86_64)
if [ -f "./nice-dcv-gl-${DCV_VERSION}.${DCV_GL_BUILD}-1.el9.${ARCH}.rpm" ]; then
    echo "Installing DCV-GL for GPU sharing..."
    dnf install -y \
        ./nice-dcv-gl-${DCV_VERSION}.${DCV_GL_BUILD}-1.el9.${ARCH}.rpm
fi

# add dcv user to video group
usermod -aG video dcv

# clean up
cd /tmp
rm -rf "/tmp/${DCV_TGZ}" "/tmp/nice-dcv-${DCV_VERSION}-${DCV_BUILD}-el9-${ARCH}"
dnf clean all -y
rm -rf /var/tmp/* /var/tmp/.[!.]* /tmp/*
