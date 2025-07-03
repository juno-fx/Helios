#!/bin/bash

set -e

mkdir -p /src /build-out/view-only/
cd /src
wget https://github.com/kasmtech/noVNC/tarball/${KASMWEB_COMMIT} -O - | tar --strip-components=1 -xz

# override theming
cp -v /background.jpg /src/app/images/splash.jpg

# build interactive
if [ "$RHEL" = "true" ]; then
	echo "Using RHEL patch for noVNC"
	cp -v /novnc-rhel-05-02-2025.patch ./novnc.patch
else
	echo "Using general patch for noVNC"
	cp -v /novnc-general-05-02-2025.patch ./novnc.patch
fi
git apply --reject --whitespace=fix novnc.patch
npm install
npm run-script build
rm -rf node_modules/ *.md AUTHORS
cp index.html vnc.html
cp -R ./* /build-out/

# build view-only
cp -v /novnc-viewonly*.patch ./
git apply --reject --whitespace=fix novnc-viewonly*.patch
npm install
npm run-script build
rm -rf node_modules/ *.md AUTHORS
cp index.html vnc.html
cp -R ./* /build-out/view-only/

cd /build-out
echo "KasmWeb Version: ${KASMWEB_COMMIT}" >/tmp/kasmweb.version
