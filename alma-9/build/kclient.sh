#!/bin/bash

set -e

# install node
dnf module install nodejs:20/common -y

# build dependencies
dnf install -y --allowerasing \
	curl \
	cmake \
	gcc \
	gcc-c++ \
	make \
	pulseaudio-libs-devel \
	python3
