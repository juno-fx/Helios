#!/bin/ash

set -e

# build dependencies
apk add --no-cache \
	alpine-sdk \
	curl \
	cmake \
	g++ \
	gcc \
	make \
	nodejs \
	npm \
	pulseaudio-dev \
	python3 \
	bash
