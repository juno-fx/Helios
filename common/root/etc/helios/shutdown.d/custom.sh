#!/bin/bash

set -e

# Notify we are shutting down
su $USER -c 'notify-send -i /usr/share/themes/helios-icon-sm.png -u critical "Workstation is being shutdown" "Session is being saved in 5 seconds."'

# trigger session save
su $USER -c 'dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionManager org.xfce.Session.Manager.Checkpoint string:""'

# Copy the session xfce4 just wrote to a stable, hostname-independent name so
# the next container can find it. xfce4 stamps the file with the machine
# hostname, which is the pod name under kubernetes and changes every restart
# (see /opt/helios/session-key.sh).
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

		# The pod-named file is a handoff buffer with a one-container lifetime -
		# the next pod looks for a different name and nothing else reads it.
		# Same prefix match, so this only ever removes our own and never another
		# live workstation's. Ordered after the copy so a failed save leaves the
		# original in place.
		rm -f "$dir"/xfce4-session-"${HOSTNAME%%.*}"*:* 2>/dev/null
	fi
}
save_session || true

# Wait for the session to save
su $USER -c 'notify-send -i /usr/share/themes/helios-icon-sm.png -u critical "Workstation is being shutdown" "Session saved. Shutting down in 5 seconds."'

# Wait for 5 seconds before shutting down
sleep 5

# Save the session
su $USER -c 'xfce4-session-logout --halt'

# shutting down kasm
su $USER -c "vncserver -kill ${DISPLAY}"
