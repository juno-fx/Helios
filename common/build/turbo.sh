#!/bin/bash

set -e

mkdir /jpeg-turbo
JPEG_TURBO_RELEASE=$(curl -sX GET "https://api.github.com/repos/libjpeg-turbo/libjpeg-turbo/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
curl -o /tmp/jpeg-turbo.tar.gz -L "https://github.com/libjpeg-turbo/libjpeg-turbo/archive/${JPEG_TURBO_RELEASE}.tar.gz"
tar xf /tmp/jpeg-turbo.tar.gz -C /jpeg-turbo/ --strip-components=1
cd /jpeg-turbo

MAKEFLAGS=-j$(nproc) CFLAGS="-fpic" cmake -DCMAKE_INSTALL_PREFIX=/usr/local -G"Unix Makefiles"
make
make install
