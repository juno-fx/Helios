#!/usr/bin/env bash

set -e

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

# if SUDO is set in the env, add the user to the sudoers
# and grant passwordless sudo access
if [ "$SUDO" = "true" ] || [ "$SUDO" = "1" ]; then
  echo "Granting sudo access to user $USER"
  echo "$USER ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/"$USER"
  chmod 440 /etc/sudoers.d/"$USER"
else
  echo "No sudo access granted to user $USER"
fi

# handle user creation
if id "$USER" >/dev/null 2>&1; then
	echo 'User already exists. Skipping user creation.'
else
	if [ ! -d "/home/$USER" ]; then
		echo "Creating home directory for $USER"
		useradd -u "$UID" -g "$GID" -m -s /bin/bash "$USER"

		mkdir -p "/home/$USER/Desktop" "/home/$USER/Downloads"
		chown -R "$USER:$GID" "/home/$USER"
	else
		echo "Home directory for $USER already exists"
		useradd -u "$UID" -g "$GID" -s /bin/bash "$USER"
	fi
fi

printf "/home/${USER}" >/run/s6/container_environment/HOME

# set the users password
if [ -z "$PASSWORD" ]; then
	echo "No password configured for user $USER, skipping password setup"
else
	echo "Setting password for user $USER"
	echo "$USER:$PASSWORD" | chpasswd
fi

# setup permissions
mkdir -p /var/run/pulse
chown -R "$UID:root" /var/run/pulse
chown -R "$UID:$GID" /opt/helios/
chmod +x /etc/helios/shutdown.d/custom.sh

mkdir -p /tmp/.XDG
chown "${UID}":root /tmp/.XDG
chmod 700 /tmp/.XDG
