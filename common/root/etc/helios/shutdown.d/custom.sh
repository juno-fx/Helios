#!/bin/bash

set -e

# Notify we are shutting down
su $USER -c 'notify-send -i /usr/share/themes/helios-icon-sm.png -u critical "Workstation is being shutdown" "Session is being saved in 5 seconds."'

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
