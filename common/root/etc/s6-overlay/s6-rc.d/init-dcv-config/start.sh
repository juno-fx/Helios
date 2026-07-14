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

# RLM stores the detached demo license as hidden dotfiles in /var/tmp, bound
# to the identity of the machine that installed them. If the build host's
# postinst managed to persist them (depends on the builder), the image ships
# demo state bound to the BUILD container, and the runtime license checkout
# fails with "No license for product (-1)" — the server then cannot create
# the console session and clients get "No session is available" (Error 4).
# The build cleanup's `rm -rf /var/tmp/*` misses dotfiles, so clear them here
# and let the reinstall below create fresh state valid for THIS container.
rm -f /var/tmp/.[!.]* 2>/dev/null || true

# Re-run package postinst at runtime to install demo license with valid RLM DB
# During Docker build, systemd runtime dirs (/run/dcv/) don't exist; postinst runs but RLM
# can't persist its license database. At runtime this dir is a real tmpfs, so it works.
mkdir -p /run/dcv /run/dcvlogon
if [ -x /var/lib/dpkg/info/nice-dcv-server.postinst ]; then
	/var/lib/dpkg/info/nice-dcv-server.postinst configure 2>/dev/null || true
elif command -v rpm &>/dev/null; then
	dcv _idl -n 2>/dev/null || true
fi

# nginx fronts DCV on 3000 (same architecture as Selkies with its 8081
# backend); dcvserver's embedded web server listens on an internal port.
# PREFIX (e.g. /plugins/bob) maps to DCV's native web-url-path so the web
# client is served under the base URL — for k8s ingress path-based routing.
DCV_WEB_PORT=8082
DCV_WEB_URL_PATH="${PREFIX:-/}"

{
	cat <<EOF
[connectivity]
web-port=${DCV_WEB_PORT}
web-use-hsts=false
enable-quic-frontend=false
EOF

	# Only write web-url-path for a real prefix — "/" is the default
	if [ "${DCV_WEB_URL_PATH}" != "/" ]; then
		cat <<EOF
web-url-path="${DCV_WEB_URL_PATH%/}"
EOF
	fi

	cat <<EOF

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
