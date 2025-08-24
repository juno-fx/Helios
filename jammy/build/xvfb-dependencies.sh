#!/bin/bash

set -e

# add srcs for deb
sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
