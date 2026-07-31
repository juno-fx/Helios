#!/bin/bash

set -e

# A kubernetes preStop hook's own stdout and stderr are discarded by kubelet, so
# mirror progress to PID 1 to make the shutdown path visible in `kubectl logs`.
log() {
	echo ">>> session: $*" >/proc/1/fd/1 2>/dev/null || true
}

# Best effort - a missing notification daemon must never abort the shutdown
# before the session has been saved.
notify() {
	su "$USER" -c "notify-send -i /usr/share/themes/helios-icon-sm.png -u critical 'Workstation is being shutdown' '$1'" 2>/dev/null || true
}

# The newest session file xfce4 wrote for this machine.
#
# Only ever match our own hostname: on a shared /home another workstation may
# have checkpointed more recently, and taking the newest file outright would
# save its session under our key. xfce4 stamps either the short hostname or
# the FQDN, so match both forms explicitly - but require the hostname be
# followed immediately by ':' (short form) or '.' (FQDN form). An open '*'
# right after the hostname would also match a DIFFERENT host that happens to
# share our hostname as a prefix (e.g. "workstation-1" matching
# "workstation-10"'s file), which is exactly the cross-workstation collision
# this function exists to prevent.
#
# xfce4 rotates the previous session to a .bak alongside the live file, and the
# trailing glob matches it too. Exclude it so a save can never persist the
# previous session in place of the current one.
session_file() {
	local dir="$1" host="${HOSTNAME%%.*}"
	ls -1t "$dir/xfce4-session-${host}:"* "$dir/xfce4-session-${host}."* 2>/dev/null | grep -v '\.bak$' | head -n1
}

mtime() {
	[ -e "$1" ] && stat -c %Y "$1" 2>/dev/null || echo 0
}

# Mirrors helios_session_key() in session-key.sh. Keep in sync.
session_key() {
	local ns_file=/var/run/secrets/kubernetes.io/serviceaccount/namespace
	local key=""

	if [ -r "$ns_file" ]; then
		read -r key <"$ns_file" 2>/dev/null
	fi

	case "$key" in
	"" | */*) key="$HOSTNAME" ;;
	esac

	echo "$key"
}

# Address of the session bus xfce4-session is actually on.
#
# A kubernetes preStop hook inherits only the container spec's environment, so
# DBUS_SESSION_BUS_ADDRESS is not set here. Left to itself libdbus falls back to
# X11 autolaunch, which needs `_DBUS_SESSION_BUS_ADDRESS` on the root window -
# and `dbus-launch --exit-with-session <program>` never publishes it. Autolaunch
# then quietly starts a *second, empty* bus and every call to it fails with
# ServiceUnknown.
#
# The address cannot be recovered from the running process either: reading
# /proc/<pid>/environ needs CAP_SYS_PTRACE, which is not in the container's
# capability set. So enumerate the listening dbus sockets and ask each one
# whether it has the session manager on it. The transport varies by distro -
# abstract on some, a plain path on others - so build the address to match.
session_bus() {
	local sock addr

	for sock in $(awk '$NF ~ /\/tmp\/dbus-/ {print $NF}' /proc/net/unix 2>/dev/null | sort -u); do
		case "$sock" in
		@*) addr="unix:abstract=${sock#@}" ;;
		*) addr="unix:path=$sock" ;;
		esac
		if su "$USER" -c "DBUS_SESSION_BUS_ADDRESS='$addr' dbus-send --session --print-reply --reply-timeout=3000 --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.NameHasOwner string:org.xfce.SessionManager" 2>/dev/null | grep -q 'boolean true'; then
			echo "$addr"
			return 0
		fi
	done

	return 1
}

# Checkpoint the running session and copy it to a stable, hostname-independent
# name so the next container can find it. xfce4 stamps the file with the machine
# hostname, which is the pod name under kubernetes and changes every restart
# (see /opt/helios/session-key.sh).
#
# Best effort throughout: a failed checkpoint, a missing or read-only /home, or
# having no session at all must not fail the shutdown.
save_session() {
	local dir key before newest bus last size i

	key=$(session_key)

	dir="$(getent passwd "$USER" | cut -d: -f6)/.cache/sessions"
	if [ ! -d "$dir" ]; then
		log "no sessions dir at $dir, skipping save"
		return 0
	fi

	before=$(mtime "$(session_file "$dir")")

	# Always address the bus explicitly. Letting dbus-send autolaunch not only
	# fails, it leaves a stray bus daemon behind on every attempt. The bounded
	# --reply-timeout matters too: the default is 25s, long enough to outlast
	# the pod's termination grace period on its own.
	bus=$(session_bus) || true
	if [ -z "$bus" ]; then
		log "no session bus with org.xfce.SessionManager, cannot checkpoint"
	elif su "$USER" -c "DBUS_SESSION_BUS_ADDRESS='$bus' dbus-send --session --dest=org.xfce.SessionManager --print-reply --reply-timeout=10000 /org/xfce/SessionManager org.xfce.Session.Manager.Checkpoint string:''" >/dev/null 2>&1; then
		log "checkpoint requested on $bus"
	else
		log "checkpoint failed on $bus, falling back to whatever is already on disk"
	fi

	# The reply means "save started", not "save finished": xfce4 writes the file
	# only once every client has answered SaveYourselfDone. Poll for it rather
	# than guessing at a sleep.
	for i in $(seq 1 20); do
		newest=$(session_file "$dir")
		if [ -n "$newest" ] && [ "$(mtime "$newest")" -gt "$before" ]; then
			break
		fi
		sleep 0.5
	done

	newest=$(session_file "$dir")
	if [ -z "$newest" ]; then
		log "no session file for ${HOSTNAME%%.*} in $dir, nothing to save"
		return 0
	fi
	if [ "$(mtime "$newest")" -le "$before" ]; then
		log "checkpoint did not refresh $newest, saving the existing copy"
	fi

	# Let the write settle before copying. On a first boot there is no previous
	# session file, so `before` is 0 and the poll above returns the instant the
	# file appears - which may be mid-write, as xfce4 rewrites it in place rather
	# than renaming a finished one into position. A truncated session restores
	# worse than no session at all.
	last=""
	for i in $(seq 1 10); do
		size=$(stat -c %s "$newest" 2>/dev/null || echo 0)
		if [ "$size" = "$last" ]; then
			break
		fi
		last="$size"
		sleep 0.5
	done

	# Keep these file ops running as $USER, consistent with everything else
	# this script does to the session. Args are passed positionally rather
	# than interpolated into the -c string.
	if su -s /bin/bash "$USER" -c 'cp -p "$1" "$2"' -- "$newest" "${dir}/helios-session-${key}"; then
		log "saved $(basename "$newest") -> helios-session-${key}"

		# The pod-named file is a handoff buffer with a one-container lifetime -
		# the next pod looks for a different name and nothing else reads it.
		# Anchored the same way as session_file() above, so this only ever
		# removes our own hostname's files and never another live workstation's
		# whose name happens to share our hostname as a prefix. Ordered after
		# the copy so a failed save leaves the original in place.
		su -s /bin/bash "$USER" -c 'rm -f "$1/xfce4-session-$2:"* "$1/xfce4-session-$2."*' -- "$dir" "${HOSTNAME%%.*}"
	else
		log "copy to helios-session-${key} failed"
	fi
}

notify "Session is being saved."
save_session || log "save_session exited unexpectedly"
notify "Session saved. Shutting down."

# Ask the desktop to shut down cleanly. Best effort and deliberately not given
# the discovered bus address: the session is already saved by this point, and
# SIGTERM from kubelet tears the container down regardless.
su "$USER" -c 'xfce4-session-logout --halt' || true

# shutting down kasm
su "$USER" -c "vncserver -kill ${DISPLAY}" || true
