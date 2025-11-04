#!/bin/bash

set -e

# add srcs for deb
sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
