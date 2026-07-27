#!/bin/bash

set -e

# preStop output is not captured by `kubectl logs` or `docker logs`. Mirror it
# into PID 1's stdout so failures here are visible in the container log.
if [ -w /proc/1/fd/1 ]; then
	exec >>/proc/1/fd/1 2>&1
fi

# Recover the xfce session bus. The runtime execs this hook directly, so it
# only inherits the image/pod environment - not DBUS_SESSION_BUS_ADDRESS,
# which dbus-launch creates in startwm.sh and only exports into that process
# tree. Without it every dbus client below autolaunches a private bus that
# nothing is listening on.
#
# Both lookups have to be checked by hand: `pgrep | head` exits 0 even when
# pgrep matched nothing, so `set -e` never fires, and an empty address is worse
# than an unset one - libdbus sees the variable as set, skips autolaunch, then
# fails to parse "" as an address.
session_pid=$(pgrep -u "$USER" -x xfce4-session | head -n1)
if [ -z "$session_pid" ]; then
	echo "shutdown.d: xfce4-session is not running, nothing to save" >&2
	exit 1
fi

# Read the environ as the user who owns the process, not as root. Reading
# another uid's /proc/<pid>/environ needs PTRACE_MODE_READ, which root only gets
# via CAP_SYS_PTRACE - and kubernetes and docker both drop that from the default
# capability set, so doing this as root fails with EACCES. Same-uid reads need
# no capability.
#
# su's stdout is piped rather than captured directly: command substitution
# strips NUL bytes, which would collapse the whole environ onto one line.
DBUS_SESSION_BUS_ADDRESS=$(su "$USER" -c "cat /proc/${session_pid}/environ" 2>/dev/null | tr '\0' '\n' | sed -n 's/^DBUS_SESSION_BUS_ADDRESS=//p' | head -n1)
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
	echo "shutdown.d: no DBUS_SESSION_BUS_ADDRESS in the environ of pid $session_pid" >&2
	exit 1
fi
export DBUS_SESSION_BUS_ADDRESS
echo "shutdown.d: recovered session bus from pid $session_pid"

# Notify we are shutting down (best effort - must not abort the session save)
su $USER -c 'notify-send -i /usr/share/themes/helios-icon-sm.png -u critical "Workstation is being shutdown" "Session is being saved in 5 seconds."' || true

# trigger session save
su $USER -c 'dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionManager org.xfce.Session.Manager.Checkpoint string:""'

# Copy the session xfce4 just wrote to a stable, hostname-independent name so
# the next container can find it (see /opt/helios/session-key.sh).
#
# Only ever match our own hostname: on a shared /home another workstation may
# have checkpointed more recently, and taking the newest file outright would
# save its session under our key. The short hostname is a prefix of both the
# short and FQDN forms, so this matches whichever one xfce4 stamped.
#
# Best effort: a missing or read-only /home must not fail the shutdown.
save_session() {
	local dir key newest

	[ -r /opt/helios/session-key.sh ] || return 0
	source /opt/helios/session-key.sh
	key=$(helios_session_key)

	dir="$(getent passwd "$USER" | cut -d: -f6)/.cache/sessions"
	[ -d "$dir" ] || return 0

	newest=$(ls -1t "$dir"/xfce4-session-"${HOSTNAME%%.*}"*:* 2>/dev/null | head -n1)
	[ -n "$newest" ] || return 0

	if cp -p "$newest" "${dir}/helios-session-${key}" 2>/dev/null; then
		chown "$USER" "${dir}/helios-session-${key}" 2>/dev/null
		echo "shutdown.d: saved session for ${key}"

		# The pod-named file is a handoff buffer with a one-container lifetime -
		# the next pod looks for a different name and nothing else reads it.
		# Same prefix match as above, so this only ever removes our own and
		# never another live workstation's. Ordered after the copy so a failed
		# save leaves the original in place.
		rm -f "$dir"/xfce4-session-"${HOSTNAME%%.*}"*:* 2>/dev/null
	fi
}
save_session || true

# Wait for the session to save
su $USER -c 'notify-send -i /usr/share/themes/helios-icon-sm.png -u critical "Workstation is being shutdown" "Session saved. Shutting down in 5 seconds."' || true

# Wait for 5 seconds before shutting down
sleep 5

# End the session. Best effort: --halt needs logind/ConsoleKit to actually halt,
# which a container does not have. The session was already written by the
# Checkpoint above, so a failure here must not abort the hook.
su $USER -c 'xfce4-session-logout --halt' || echo "shutdown.d: xfce4-session-logout returned non-zero (expected in a container)" >&2

echo "shutdown.d: finished"
