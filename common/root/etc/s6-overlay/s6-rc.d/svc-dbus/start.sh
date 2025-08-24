#!/usr/bin/env bash
set -e

mkdir -p /run/dbus
chown ${USER}:${USER} /run/dbus

exec s6-setuidgid ${USER} \
	dbus-daemon \
	--system \
	--nofork \
	--nosyslog
