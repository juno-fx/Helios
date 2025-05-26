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
ln -s /usr/lib/x86_64-linux-gnu/dri dri
cd /src
mkdir -p builder/www
cp -ax /www/dist/* builder/www/
make servertarball
mkdir /build-out
tar xzf kasmvnc-Linux*.tar.gz -C /build-out/
mv -v /kclient /build-out/
rm -Rf /build-out/usr/local/man

# setup kasm links
mkdir -p /build-out/usr/share /build-out/etc /build-out/usr/lib
ln -sf /usr/local/share/kasmvnc /build-out/usr/share/kasmvnc
ln -sf /usr/local/etc/kasmvnc /build-out/etc/kasmvnc
ln -sf /usr/local/lib/kasmvnc /build-out/usr/lib/kasmvncserver

# install kasmbins
mkdir -p /build-out/kasmbins
curl -s https://kasm-ci.s3.amazonaws.com/kasmbins-amd64-${KASMBINS_RELEASE}.tar.gz | tar xzvf - -C /build-out/kasmbins/
rm -rfv \
  /build-out/kasmbins/kasm_gamepad_server \
  /build-out/kasmbins/kasm_printer_service \
  /build-out/kasmbins/kasm_upload_server \
  /build-out/kasmbins/kasm_webcam_server
chmod +x /build-out/kasmbins/*
