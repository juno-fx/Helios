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
# the streaming core; its postbuild gendb.js generates the jsdb remap database
cd addons/selkies-web-core
npm install
npm run build
# the dashboard's own prebuild (copy-core.js) and postbuild (copy-jsdb.js) read
# the core and jsdb out of the tree above, so it must be built after it
cd ../selkies-dashboard
npm install
npm run build
cp -ar dist/* /build-out/
