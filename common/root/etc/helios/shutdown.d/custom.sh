#!/bin/bash

set -e

# Recover the xfce session bus. The runtime execs this hook directly, so it
# only inherits the image/pod environment - not DBUS_SESSION_BUS_ADDRESS,
# which dbus-launch creates in startwm.sh and only exports into that process
# tree. Without it every dbus client below autolaunches a private bus that
# nothing is listening on.
session_pid=$(pgrep -u "$USER" -x xfce4-session | head -n1)
export DBUS_SESSION_BUS_ADDRESS=$(tr '\0' '\n' </proc/${session_pid}/environ | grep -m1 '^DBUS_SESSION_BUS_ADDRESS=' | cut -d= -f2-)

# Notify we are shutting down (best effort - must not abort the session save)
su $USER -c 'notify-send -i /usr/share/themes/helios-icon-sm.png -u critical "Workstation is being shutdown" "Session is being saved in 5 seconds."' || true

# trigger session save
su $USER -c 'dbus-send --session --dest=org.xfce.SessionManager --print-reply /org/xfce/SessionManager org.xfce.Session.Manager.Checkpoint string:""'

# Wait for the session to save
su $USER -c 'notify-send -i /usr/share/themes/helios-icon-sm.png -u critical "Workstation is being shutdown" "Session saved. Shutting down in 5 seconds."'

# Wait for 5 seconds before shutting down
sleep 5

# Save the session
su $USER -c 'xfce4-session-logout --halt'

# shutting down kasm
su $USER -c "vncserver -kill ${DISPLAY}"
