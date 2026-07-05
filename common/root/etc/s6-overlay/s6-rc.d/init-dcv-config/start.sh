#!/usr/bin/env bash

set -e

# Only run in DCV mode
if [ "${REMOTE_PROTOCOL}" != "dcv" ]; then
	echo "init-dcv-config: REMOTE_PROTOCOL=${REMOTE_PROTOCOL}, exiting (DCV disabled)"
	exit 0
fi

echo "Generating DCV server configuration..."

mkdir -p /etc/dcv

# DCVsession starter and session launcher require this env var
printf "x11" >/run/s6/container_environment/XDG_SESSION_TYPE

# Re-run package postinst at runtime to install demo license with valid RLM DB
# During Docker build, systemd runtime dirs (/run/dcv/) don't exist; postinst runs but RLM
# can't persist its license database. At runtime this dir is a real tmpfs, so it works.
mkdir -p /run/dcv /run/dcvlogon
if [ -x /var/lib/dpkg/info/nice-dcv-server.postinst ]; then
	/var/lib/dpkg/info/nice-dcv-server.postinst configure 2>/dev/null || true
elif command -v rpm &>/dev/null; then
	dcv _idl -n 2>/dev/null || true
fi

{
	cat <<EOF
[connectivity]
web-port=${HTTP_PORT:-3000}
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
