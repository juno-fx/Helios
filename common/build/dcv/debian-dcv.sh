#!/bin/bash

set -e
source /tmp/version.sh

export DEBIAN_FRONTEND=noninteractive

echo "Installing Amazon DCV on Debian-family ($SRC)..."

# map distro to DCV release name
case "$SRC" in
    jammy)
        DCV_RELEASE="ubuntu2204"
        ;;
    noble)
        DCV_RELEASE="ubuntu2404"
        ;;
    *)
        echo "Unsupported Debian-family distro for DCV: $SRC"
        exit 1
        ;;
esac

ARCH="x86_64"
DEB_ARCH="amd64"

# download DCV server tgz
DCV_TGZ="nice-dcv-${DCV_VERSION}-${DCV_BUILD}-${DCV_RELEASE}-${ARCH}.tgz"
DCV_URL="https://d1uj6qtbmh3dt5.cloudfront.net/${DCV_VERSION}/Servers/${DCV_TGZ}"

echo "Downloading DCV server from ${DCV_URL}..."
wget -q "${DCV_URL}" -O "/tmp/${DCV_TGZ}"
tar -xzf "/tmp/${DCV_TGZ}" -C /tmp/

cd "/tmp/nice-dcv-${DCV_VERSION}-${DCV_BUILD}-${DCV_RELEASE}-${ARCH}"

# apt cache was cleared by distro system.sh — refresh to resolve DCV deps
apt update

# install DCV packages
echo "Installing DCV server packages..."
apt install --no-install-recommends -y \
    ./nice-dcv-server_${DCV_VERSION}.${DCV_BUILD}-1_${DEB_ARCH}.${DCV_RELEASE}.deb \
    ./nice-dcv-web-viewer_${DCV_VERSION}.${DCV_BUILD}-1_${DEB_ARCH}.${DCV_RELEASE}.deb \
    ./nice-xdcv_${DCV_VERSION}.${DCV_XDCV_BUILD}-1_${DEB_ARCH}.${DCV_RELEASE}.deb

# install DCV-GL for GPU sharing (only on x86_64)
if [ -f "./nice-dcv-gl_${DCV_VERSION}.${DCV_GL_BUILD}-1_${DEB_ARCH}.${DCV_RELEASE}.deb" ]; then
    echo "Installing DCV-GL for GPU sharing..."
    apt install --no-install-recommends -y \
        ./nice-dcv-gl_${DCV_VERSION}.${DCV_GL_BUILD}-1_${DEB_ARCH}.${DCV_RELEASE}.deb
fi

# add dcv user to video group
usermod -aG video dcv

# clean up
cd /tmp
rm -rf "/tmp/${DCV_TGZ}" "/tmp/nice-dcv-${DCV_VERSION}-${DCV_BUILD}-${DCV_RELEASE}-${ARCH}"
apt clean -y
rm -rf /var/lib/apt/lists/* /var/tmp/* /var/tmp/.[!.]* /tmp/*
