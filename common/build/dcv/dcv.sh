#!/bin/bash
# Master Amazon DCV installer — dispatches to distro-specific installer
# reference: https://docs.aws.amazon.com/dcv/latest/adminguide/setting-up-installing-linux-server.html

set -e

echo "Amazon DCV Installer"

case "$SRC" in
    jammy|noble)
        bash /tmp/debian-dcv.sh
        ;;
    rocky-9|alma-9)
        bash /tmp/rhel-dcv.sh
        ;;
    *)
        echo "DCV not supported on $SRC, skipping"
        ;;
esac
