#!/usr/bin/env bash

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

exec /usr/sbin/nginx -g 'daemon off;'
tail -f /var/log/nginx/*.log
