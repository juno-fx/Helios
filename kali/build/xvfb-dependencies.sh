#!/bin/bash

set -e

# add srcs for deb
echo "deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" >>/etc/apt/sources.list
echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" >>/etc/apt/sources.list
