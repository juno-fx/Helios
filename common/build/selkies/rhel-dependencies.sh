#!/bin/bash

set -e

# install selkies build dependencies
# install system
dnf update -y
dnf install -y --allowerasing --setopt=install_weak_deps=False --best \
	$(cat /lists/selkies-rhel.list)
