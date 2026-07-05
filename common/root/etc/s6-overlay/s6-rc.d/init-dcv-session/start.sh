#!/usr/bin/env bash

set -e

# Only run in DCV mode
if [ "${REMOTE_PROTOCOL}" != "dcv" ]; then
	echo "init-dcv-session: REMOTE_PROTOCOL=${REMOTE_PROTOCOL}, exiting (DCV disabled)"
	exit 0
fi

echo "Creating DCV virtual session..."

# Wait for dcvserver to be ready
for ((i=1; i<=30; i++)); do
	if dcv list-sessions >/dev/null 2>&1; then
		echo "DCV server is ready."
		break
	fi
	if [ "$i" -eq 30 ]; then
		echo "ERROR: DCV server did not start within 30 seconds"
		exit 1
	fi
	sleep 1
done

# Validate required env vars
if [ -z "$USER" ]; then
	echo "ERROR: USER not set"
	exit 1
fi

SESSION_ID="helios-session"

# Create virtual session with XFCE desktop
dcv create-session \
	--type virtual \
	--user "${USER}" \
	--owner "${USER}" \
	--init /opt/helios/dcv-startwm.sh \
	--gl on \
	"${SESSION_ID}"

echo "DCV virtual session '${SESSION_ID}' created for user '${USER}'"
