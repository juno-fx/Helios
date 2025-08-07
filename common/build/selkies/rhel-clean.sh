#!/bin/bash

set -e

# would love to get this working. For some reason it is trying to remove dnf?
## remove selkies build dependencies
#dnf remove -y $(cat /lists/selkies-rhel.list) --skip-broken --nobest

# clean up
rm -rfv /var/lib/{dnf,cache,log}/ /etc/systemd /var/lib/apt/lists/* /var/tmp/* /tmp/*
