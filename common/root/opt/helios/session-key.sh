#!/bin/bash
#
# Resolves a stable identity for the desktop session. Sourced by the startup
# restore (startwm.sh) and the shutdown save (shutdown.d/custom.sh), which have
# to agree on the same key.
#
# xfce4 names its saved session after the machine hostname. Under kubernetes
# that is the pod name, which changes on every restart, so the session saved by
# the previous container is never found. We keep our own copy keyed on
# something stable instead.
#
# Kubernetes auto-mounts the namespace into every pod, so this needs no
# manifest change and survives restarts. Two workstations in different
# namespaces stay isolated from each other; two in the same namespace share a
# key, and the most recent shutdown wins.

helios_session_key() {
	local ns_file=/var/run/secrets/kubernetes.io/serviceaccount/namespace
	local key=""

	if [ -r "$ns_file" ]; then
		read -r key <"$ns_file" 2>/dev/null
	fi

	# Fall back to the hostname when off-cluster (compose pins it) or when the
	# service account token is not mounted. Reject anything unusable as a
	# filename rather than building a broken path.
	case "$key" in
	"" | */*) key="$HOSTNAME" ;;
	esac

	echo "$key"
}
