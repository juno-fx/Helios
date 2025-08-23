#!/bin/bash
# reference: https://github.com/linuxserver/docker-baseimage-selkies/blob/ubuntunoble/Dockerfile

set -e

# make build out
mkdir -p /build-out

export SELKIES_VERSION="v1.6.2"

if [ -z "${SELKIES_VERSION}" ]; then
  echo "SELKIES_VERSION is not set"
  exit 1
fi

echo curl -L -o "/build-out/selkies-gstreamer-web_${SELKIES_VERSION}.tar.gz" "https://github.com/selkies-project/selkies/releases/download/${SELKIES_VERSION}/selkies-gstreamer-web_${SELKIES_VERSION}.tar.gz"
curl -L -o "/build-out/selkies-gstreamer-web_${SELKIES_VERSION}.tar.gz" "https://github.com/selkies-project/selkies/releases/download/${SELKIES_VERSION}/selkies-gstreamer-web_${SELKIES_VERSION}.tar.gz"
tar -xzf "/build-out/selkies-gstreamer-web_${SELKIES_VERSION}.tar.gz" -C /build-out/ --strip-components=1
rm "/build-out/selkies-gstreamer-web_${SELKIES_VERSION}.tar.gz"
