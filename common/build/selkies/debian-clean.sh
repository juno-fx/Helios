#!/bin/bash

set -e

# remove selkies build dependencies
apt remove -y $(cat /lists/selkies.list)

# clean up
apt clean -y
apt autoclean -y
apt autoremove --purge -y
rm -rfv /var/lib/{apt,cache,log}/ /etc/systemd /var/lib/apt/lists/* /var/tmp/* /tmp/*
