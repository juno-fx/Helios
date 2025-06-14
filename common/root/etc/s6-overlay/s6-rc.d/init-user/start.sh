#!/usr/bin/env bash

set -e

# just to wait for the other services to finish
sleep .25

if [ -z "$USER" ]; then
	echo "No user configured"
	exit 1
fi

if [ -z "$UID" ]; then
	echo "No UID configured"
	exit 1
fi

if [ -z "$GID" ]; then
	echo "No GID configured, defaulting to matching UID"
	GID="$UID"
fi

# notify we are good to go
echo "Configured User Information"
echo "User: $USER"
echo "UID: $UID"
echo "GID: $GID"

# create user
echo "Creating user $USER with UID $UID and GID $GID"

# check if the group exists
if ! getent group "$GID" >/dev/null; then
	groupadd -g "$GID" "$USER"
else
	echo "Group $GID already exists, skipping group creation"
fi

# handle user creation
if id "$USER" >/dev/null 2>&1; then
	echo 'User already exists. Skipping user creation.'
else
	if [ ! -d "/home/$USER" ]; then
		echo "Creating home directory for $USER"
		useradd -u "$UID" -g "$GID" -m -s /bin/bash "$USER"
	else
		echo "Home directory for $USER already exists"
		useradd -u "$UID" -g "$GID" -s /bin/bash "$USER"
	fi
fi

# set the users password
if [ -z "$PASSWORD" ]; then
	echo "No password configured for user $USER, skipping password setup"
else
	echo "Setting password for user $USER"
	echo "$USER:$PASSWORD" | chpasswd
fi

chown -R "$USER:$GID" "/home/$USER"

# add to the ssl group
usermod -aG ssl-cert "$USER" || (usermod -aG 101 "$USER" || echo "ssl-cert assignment failed. Skipping.")

# setup permissions
mkdir -p /var/run/pulse
chown -R "$UID:root" /var/run/pulse
chown -R "$UID:$GID" /opt/helios/
