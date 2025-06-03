set -e

mkdir /src
cd /src
wget https://github.com/kasmtech/noVNC/tarball/${KASMWEB_COMMIT} -O - | tar --strip-components=1 -xz

if [ "$RHEL" ]; then
	echo "Using RHEL patch for noVNC"
	cp -v /novnc-rhel-05-02-2025.patch ./novnc.patch
else
	echo "Using general patch for noVNC"
	cp -v /novnc-general-05-02-2025.patch ./novnc.patch
fi

git apply --reject --whitespace=fix novnc.patch
npm install
npm run-script build
mkdir /build-out
cd /src
rm -rf node_modules/ *.md AUTHORS
cp -R ./* /build-out/
cd /build-out
cp index.html vnc.html

echo "KasmWeb Version: ${KASMWEB_COMMIT}" >/tmp/kasmweb.version
