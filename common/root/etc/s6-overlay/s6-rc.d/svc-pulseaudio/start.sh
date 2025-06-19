#!/usr/bin/env bash

exec s6-setuidgid "${USER}" \
	/usr/bin/pulseaudio \
	--log-level=0 \
	--log-target=stderr \
	--exit-idle-time=-1 2>&1
