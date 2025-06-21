#!/usr/bin/env bash

set -e

echo "Loading Desktop files"
paths="${DESKTOP_FILES//\"/ }"
count=0
for i in ${paths//:/ }; do
	ln -sfn "$i" "/usr/share/applications/$(basename $i)" || continue
	count=$(expr $count + 1)
done
echo "Loaded $count Desktop Files"
echo "Refreshing Desktop File Cache"
update-desktop-database
echo "Desktop Cache Refreshed"
