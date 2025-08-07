#!/bin/bash

set -e

mkdir -p /build-out/

if command -v apt >/dev/null 2>&1; then

  # install xvfb dependencies
  bash /tmp/xvfb-dependencies.sh

  # install build deps
  apt-get update
  apt-get install -y \
    devscripts \
    dpkg-dev
  apt-get build-dep -y \
    xorg-server

  # patch and build xvfb
  apt-get source xorg-server
  cd xorg-server-*
  cp /tmp/${HELIOS_XVFB_PATCH}-xvfb-dri3.patch patch.patch
  patch -p0 < patch.patch
  awk ' \
    { print } \
    /include \/usr\/share\/dpkg\/architecture.mk/ { \
      print ""; \
      print "GLAMOR_DEP_LIBS := $(shell pkg-config --libs gbm epoxy libdrm)"; \
      print "GLAMOR_DEP_CFLAGS := $(shell pkg-config --cflags gbm epoxy libdrm)"; \
      print "export DEB_LDFLAGS_PREPEND ?= $(GLAMOR_DEP_LIBS)"; \
      print "export DEB_CFLAGS_PREPEND ?= $(GLAMOR_DEP_CFLAGS)"; \
    } \
  ' debian/rules > debian/rules.tmp
  mv debian/rules.tmp debian/rules
  debuild -us -uc -b
  mkdir -p /build-out/usr/bin
  mv debian/xvfb/usr/bin/Xvfb /build-out/usr/bin/
fi
