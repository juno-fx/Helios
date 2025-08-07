#!/bin/ash
# reference: https://github.com/linuxserver/docker-xvfb/blob/master/Dockerfile

set -e

export APK_BRANCH=3.22-stable

apk update
apk add --no-cache alpine-sdk git

sed '/SUDO=/d' -i /usr/bin/abuild-keygen
abuild-keygen --install -n

abuild-keygen -a -n
git clone --depth 1 --branch ${APK_BRANCH} https://gitlab.alpinelinux.org/alpine/aports.git
cd aports/community/xorg-server/
cp /tmp/${HELIOS_XVFB_PATCH}-xvfb-dri3-alpine.patch patch.patch
sed -i 's|\.tar\.xz"|\.tar\.xz\npatch.patch"|' APKBUILD
sed -i '/^sha512sums="/,/"$/{ s|\(  .*\.tar\.xz\)|\1\n'"$(sha512sum patch.patch)"'|; }' APKBUILD
abuild -F -r || :
ls -la /aports/community/xvfb-run/
tar -xf /aports/community/*/xvfb*.apk
mkdir -p /build-out/usr/bin
mv usr/bin/Xvfb /build-out/usr/bin/
