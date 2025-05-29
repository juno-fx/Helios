#!/usr/bin/env bash

# trigger custom init scripts
set -e

chmod +x /etc/helios/init.d/*.sh

for script in /etc/helios/init.d/*.sh; do
  if [ -x "$script" ]; then
    echo "Running custom init script: $script"
    "$script"
  else
    echo "Skipping non-executable script: $script"
  fi
done
