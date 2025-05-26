set -e

mkdir /src
cd /src
wget https://github.com/kasmtech/noVNC/tarball/${KASMWEB_COMMIT} -O - | tar  --strip-components=1 -xz
npm install
npm run-script build
mkdir /build-out
cd /src
rm -rf node_modules/ *.md AUTHORS
cp -R ./* /build-out/
cd /build-out
cp index.html vnc.html
