#!/bin/bash
# reference: https://github.com/linuxserver/docker-baseimage-selkies/blob/ubuntunoble/Dockerfile

set -e

# make build out
mkdir -p /build-out

# build dependencies
apk add $(cat /lists/frontend.list)

# install selkies front end
git clone https://github.com/selkies-project/selkies.git /src
cd /src
git checkout -f ${SELKIES_VERSION}

# build
cd addons/gst-web-core
npm install
npm run build
cp dist/selkies-core.js ../selkies-dashboard/src
cd ../selkies-dashboard
npm install
npm run build
mkdir dist/src dist/nginx
cp ../universal-touch-gamepad/universalTouchGamepad.js dist/src/
cp ../gst-web-core/nginx/* dist/nginx/
cp -r ../gst-web-core/dist/jsdb dist/
cp -ar dist/* /build-out/
