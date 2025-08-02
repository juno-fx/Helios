#!/usr/bin/env bash

# trigger custom init scripts
set -e

cat /opt/helios/header.txt
echo "Helios Version $HELIOS_VERSION"
#cat /opt/helios/*.version

chmod +x /etc/helios/init.d/*.sh || echo "Potentially Read-Only Mounts. Skipping chmod. Root..."
chmod +x /etc/helios/init.d/*/entrypoint.sh || echo "Potentially Read-Only Mounts. Skipping chmod. Nested..."

for script in /etc/helios/init.d/*.sh; do
	if [ -x "$script" ]; then
		echo "Running custom init script: $script"
		"$script"
	else
		printf "Non-executable script: $script\n\tAttempting with bash: /bin/bash $script\n"
		/bin/bash "$script" || echo "Failed to run: $script"
	fi
done

for script in /etc/helios/init.d/*/entrypoint.sh; do
	if [ -x "$script" ]; then
		echo "Running custom init script: $script"
		"$script"
	else
		printf "Non-executable script: $script\n\tAttempting with bash: /bin/bash $script\n"
		/bin/bash "$script" || echo "Failed to run: $script"
	fi
done

chmod +x /etc/helios/services.d/custom.sh
