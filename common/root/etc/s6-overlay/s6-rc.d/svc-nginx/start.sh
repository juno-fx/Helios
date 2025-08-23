#!/usr/bin/env bash

set -e

NGINX_CONFIG=/opt/helios/nginx.conf

if [ -z "$UID" ]; then
	echo "No UID configured"
	exit 1
fi

if [ -z "$GID" ]; then
	echo "No GID configured, defaulting to matching UID"
	GID="$UID"
fi

if [ ! -f "/opt/helios/ssl/cert.pem" ]; then
  mkdir -p /opt/helios/ssl
  openssl req -new -x509 \
    -days 3650 -nodes \
    -out /opt/helios/ssl/cert.pem \
    -keyout /opt/helios/ssl/cert.key \
    -subj "/C=US/ST=CA/L=Carlsbad/O=Linuxserver.io/OU=LSIO Server/CN=*"
  chmod 600 /opt/helios/ssl/cert.key
  chown -R $UID:$GID /opt/helios/ssl
fi


/usr/sbin/nginx -c ${NGINX_CONFIG}
