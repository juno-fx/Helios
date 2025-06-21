#!/usr/bin/env bash

# trigger custom init scripts
set -e

cat /opt/helios/header.txt
echo "Helios Version $HELIOS_VERSION"
cat /opt/helios/*.version

chmod +x /etc/helios/init.d/*.sh

for script in /etc/helios/init.d/*.sh; do
	if [ -x "$script" ]; then
		echo "Running custom init script: $script"
		"$script"
	else
		echo "Skipping non-executable script: $script"
	fi
done

chmod +x /etc/helios/services.d/custom.sh
