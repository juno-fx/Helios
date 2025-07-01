#!/bin/bash

set -e

# clone kclient from lsio
mkdir -p /kclient
KCLIENT_RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/kclient/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
curl -o /tmp/kclient.tar.gz -L "https://github.com/linuxserver/kclient/archive/${KCLIENT_RELEASE}.tar.gz" &&
	tar xf /tmp/kclient.tar.gz -C /kclient/ --strip-components=1

# build kclient
cd /kclient
cp -v /build/kclient-06-28-2025.patch ./
cp -v public/index.html public/view-only.html
git apply --reject --whitespace=fix kclient-06-28-2025.patch
npm install
rm -f package-lock.json
