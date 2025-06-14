#!/bin/bash

set -e

# run the kasm packaing process
cd /src
mkdir -p xorg.build/bin
cd xorg.build/bin/
ln -s /src/unix/xserver/hw/vnc/Xvnc Xvnc
cd ..
mkdir -p man/man1
touch man/man1/Xserver.1
cp /src/unix/xserver/hw/vnc/Xvnc.man man/man1/Xvnc.1
mkdir lib
cd lib
if [ -d /usr/lib64/dri ]; then
	ln -s /usr/lib64/dri dri
elif [ -d /usr/lib/x86_64-linux-gnu/dri ]; then
	ln -s /usr/lib/x86_64-linux-gnu/dri dri
elif [ -d /usr/lib/dri ]; then
	ln -s /usr/lib/dri dri
else
	echo "No dri directory found in /usr/lib64 or /usr/lib/x86_64-linux-gnu"
	exit 1
fi

cd /src
mkdir -p builder/www
cp -ax /www/dist/* builder/www/
make servertarball
mkdir /build-out
mkdir -pv /build-out/opt/helios/kclient
tar xzf kasmvnc-Linux*.tar.gz -C /build-out/
mv -v /kclient/* /build-out/opt/helios/kclient/
rm -Rf /build-out/usr/local/man

# setup kasm links
mkdir -p /build-out/usr/share /build-out/etc /build-out/usr/lib
ln -sf /usr/local/share/kasmvnc /build-out/usr/share/kasmvnc
ln -sf /usr/local/etc/kasmvnc /build-out/etc/kasmvnc
ln -sf /usr/local/lib/kasmvnc /build-out/usr/lib/kasmvncserver

# install kasmbins
mkdir -p /build-out/opt/helios/kasmbins
curl -s https://kasm-ci.s3.amazonaws.com/kasmbins-amd64-${KASMBINS_RELEASE}.tar.gz | tar xzvf - -C /build-out/opt/helios/kasmbins/
rm -rfv \
	/build-out/opt/helios/kasmbins/kasm_gamepad_server \
	/build-out/opt/helios/kasmbins/kasm_printer_service \
	/build-out/opt/helios/kasmbins/kasm_upload_server \
	/build-out/opt/helios/kasmbins/kasm_webcam_server
chmod +x /build-out/opt/helios/kasmbins/*

echo "KasmVNC Version: ${KASMVNC_COMMIT}" >/build-out/opt/helios/kasmvnc.version
echo "Kasm Bins Version: ${KASMBINS_RELEASE}" >/build-out/opt/helios/kasmbins.version
