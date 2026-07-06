#!/usr/bin/env bash

set -e

# nginx fronts both remote protocols on 3000 and serves them under
# ${PREFIX} (base URL) for k8s ingress path-based routing:
#   selkies: static frontend + websocket proxy to 127.0.0.1:8081
#   dcv:     proxy to dcvserver's embedded web server on 127.0.0.1:8082
NGINX_TEMPLATE=/opt/helios/nginx.conf
if [ "${REMOTE_PROTOCOL}" = "dcv" ]; then
	echo "svc-nginx: REMOTE_PROTOCOL=dcv, proxying DCV web server"
	NGINX_TEMPLATE=/opt/helios/dcv-nginx.conf
fi

# nginx Path
NGINX_CONFIG=/etc/nginx/sites-available/default

# user passed env vars
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
mkdir -p /etc/nginx/sites-available/
cp ${NGINX_TEMPLATE} ${NGINX_CONFIG}
sed -i "s|SUBFOLDER|$SFOLDER|g" ${NGINX_CONFIG}
if [ ! -z ${DISABLE_IPV6+x} ]; then
	sed -i '/listen \[::\]/d' ${NGINX_CONFIG}
fi

/usr/sbin/nginx -c ${NGINX_CONFIG}
