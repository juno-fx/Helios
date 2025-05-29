#!/usr/bin/env bash

# link to our the custom kasmvnc config
echo "Linking to custom kasmvnc config"
ln -sfv /etc/helios/kasmvnc.yaml /usr/local/etc/kasmvnc/kasmvnc.yaml

chown -Rv root:ssl-cert /etc/ssl/private/ssl-cert-snakeoil.key
chown -Rv root:root /etc/ssl/certs/ssl-cert-snakeoil.pem
