#!/usr/bin/env bash

set -e

# nginx Path
NGINX_CONFIG=/etc/nginx/sites-available/default

# user passed env vars
CPORT="${CUSTOM_PORT:-3000}"
CHPORT="${CUSTOM_HTTPS_PORT:-3001}"
SFOLDER="${PREFIX:-/}"

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

# modify nginx config
cp /opt/helios/nginx.conf ${NGINX_CONFIG}
sed -i "s/3000/$CPORT/g" ${NGINX_CONFIG}
sed -i "s/3001/$CHPORT/g" ${NGINX_CONFIG}
sed -i "s|SUBFOLDER|$SFOLDER|g" ${NGINX_CONFIG}
sed -i "s|REPLACE_HOME|$HOME|g" ${NGINX_CONFIG}
if [ ! -z ${DISABLE_IPV6+x} ]; then
  sed -i '/listen \[::\]/d' ${NGINX_CONFIG}
fi


/usr/sbin/nginx -c /etc/nginx/sites-available/default
