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
# save its session under our key. The short hostname is a prefix of both the
# short and FQDN forms, so this matches whichever one xfce4 stamped.
session_file() {
	ls -1t "$1"/xfce4-session-"${HOSTNAME%%.*}"*:* 2>/dev/null | head -n1
}

mtime() {
	[ -e "$1" ] && stat -c %Y "$1" 2>/dev/null || echo 0
}

# Checkpoint the running session and copy it to a stable, hostname-independent
# name so the next container can find it. xfce4 stamps the file with the machine
# hostname, which is the pod name under kubernetes and changes every restart
# (see /opt/helios/session-key.sh).
#
# Best effort throughout: a failed checkpoint, a missing or read-only /home, or
# having no session at all must not fail the shutdown.
save_session() {
	local dir key before newest i

	if [ ! -r /opt/helios/session-key.sh ]; then
		log "session-key.sh not found, skipping save"
		return 0
	fi
	source /opt/helios/session-key.sh
	key=$(helios_session_key)

	dir="$(getent passwd "$USER" | cut -d: -f6)/.cache/sessions"
	if [ ! -d "$dir" ]; then
		log "no sessions dir at $dir, skipping save"
		return 0
	fi

	before=$(mtime "$(session_file "$dir")")

	# dbus-send defaults to a 25 second reply timeout - long enough to outlast
	# the pod's termination grace period, and under `set -e` long enough to
	# abort this hook before the copy below ever runs.
	if su "$USER" -c 'dbus-send --session --dest=org.xfce.SessionManager --print-reply --reply-timeout=10000 /org/xfce/SessionManager org.xfce.Session.Manager.Checkpoint string:""' >/dev/null 2>&1; then
		log "checkpoint requested"
	else
		log "checkpoint failed, falling back to whatever is already on disk"
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

	if cp -p "$newest" "${dir}/helios-session-${key}"; then
		chown "$USER" "${dir}/helios-session-${key}" 2>/dev/null || true
		log "saved $(basename "$newest") -> helios-session-${key}"

		# The pod-named file is a handoff buffer with a one-container lifetime -
		# the next pod looks for a different name and nothing else reads it. Same
		# prefix match, so this only ever removes our own and never another live
		# workstation's. Ordered after the copy so a failed save leaves the
		# original in place.
		rm -f "$dir"/xfce4-session-"${HOSTNAME%%.*}"*:*
	else
		log "copy to helios-session-${key} failed"
	fi
}

notify "Session is being saved."
save_session || log "save_session exited unexpectedly"
notify "Session saved. Shutting down."

# Save the session
su "$USER" -c 'xfce4-session-logout --halt' || true

# shutting down kasm
su "$USER" -c "vncserver -kill ${DISPLAY}" || true
