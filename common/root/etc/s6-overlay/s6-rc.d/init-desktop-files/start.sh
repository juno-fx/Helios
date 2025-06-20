#!/usr/bin/env bash

set -e

echo "Loading Desktop files"
paths=$(echo $DESKTOP_FILES | sed "s/\"//g")
for i in ${paths//:/ }
do
    filename=$(basename "$i")
    ln -sf /usr/share/applications/$filename $i
done
echo "Loading Desktop files"
