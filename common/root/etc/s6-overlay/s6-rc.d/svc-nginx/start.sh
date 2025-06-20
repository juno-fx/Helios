#!/usr/bin/env bash

# fail on error
set -e

# nginx Path
NGINX_CONFIG=/etc/nginx/sites-available/default
mkdir -vp /etc/nginx/sites-available/

# modify nginx config
cp /opt/helios/nginx.conf ${NGINX_CONFIG}
sed -i "s/3000/$HTTP_PORT/g" ${NGINX_CONFIG}
sed -i "s/3001/$HTTPS_PORT/g" ${NGINX_CONFIG}
sed -i "s|SUBFOLDER|$PREFIX|g" ${NGINX_CONFIG}
if [ ! -z ${DISABLE_IPV6+x} ]; then
	sed -i '/listen \[::\]/d' ${NGINX_CONFIG}
fi

if pgrep -f "[n]ginx:" >/dev/null; then
	echo "Zombie nginx processes detected, sending SIGTERM"
	pkill -ef [n]ginx:
	sleep 1
fi

if pgrep -f "[n]ginx:" >/dev/null; then
	echo "Zombie nginx processes still active, sending SIGKILL"
	pkill -9 -ef [n]ginx:
	sleep 1
fi

/usr/sbin/nginx -c /etc/nginx/sites-available/default
