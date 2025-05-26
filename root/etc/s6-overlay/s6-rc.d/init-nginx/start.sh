#!/usr/bin/env bash

# fail on error
set -e

# handle GUID fallback
if [ -z "$GID" ]; then
  echo "No GID configured, defaulting to matching UID"
  GID="$UID"
fi

# nginx Path
NGINX_CONFIG=/etc/nginx/sites-available/default

# create self signed cert
if [ ! -f "/default/ssl/cert.pem" ]; then
  mkdir -p /default/ssl
  openssl req -new -x509 \
    -days 3650 -nodes \
    -out /default/ssl/cert.pem \
    -keyout /default/ssl/cert.key \
    -subj "/C=US/ST=CA/L=Carlsbad/O=Linuxserver.io/OU=LSIO Server/CN=*"
  chmod 600 /default/ssl/cert.key
  chown -R "$UID:$GID" /default/ssl
fi

# modify nginx config
cp /defaults/nginx.conf ${NGINX_CONFIG}
sed -i "s/3000/$HTTP_PORT/g" ${NGINX_CONFIG}
sed -i "s/3001/$HTTPS_PORT/g" ${NGINX_CONFIG}
sed -i "s|SUBFOLDER|$PREFIX|g" ${NGINX_CONFIG}
if [ ! -z ${DISABLE_IPV6+x} ]; then
  sed -i '/listen \[::\]/d' ${NGINX_CONFIG}
fi

if [ ! -z ${PASSWORD+x} ]; then
  printf "${USER}:$(openssl passwd -apr1 ${PASSWORD})\n" > /etc/nginx/.htpasswd
  sed -i 's/#//g' ${NGINX_CONFIG}
fi
