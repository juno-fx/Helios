#!/usr/bin/env bash

set -e

# Only run in DCV mode
if [ "${REMOTE_PROTOCOL}" != "dcv" ]; then
	echo "init-dcv-config: REMOTE_PROTOCOL=${REMOTE_PROTOCOL}, exiting (DCV disabled)"
	exit 0
fi

echo "Generating DCV server configuration..."

mkdir -p /etc/dcv

{
	cat <<EOF
[connectivity]
web-port=3000
web-use-hsts=false
enable-quic-frontend=false

[security]
authentication=none

[session-management]
create-session=false

[display]
target-fps=${SELKIES_FRAMERATE:-60}
enable-client-resize=true
EOF

	# Only write license section when DCV_LICENSE_FILE is set
	# Empty value would prevent demo/EC2 license fallback
	if [ -n "${DCV_LICENSE_FILE}" ]; then
		cat <<EOF

[license]
license-file=${DCV_LICENSE_FILE}
EOF
	fi
} > /etc/dcv/dcv.conf

if [ -n "${DCV_LICENSE_FILE}" ]; then
	echo "DCV license configured: ${DCV_LICENSE_FILE}"
else
	echo "DCV license not set — using auto-license (free on EC2, demo elsewhere)"
fi

echo "DCV configuration written to /etc/dcv/dcv.conf"
