# Custom Idle

In this example, we will create a custom idle script for Alpine, Debian, and RHEL based images to run a specific command when the system is idle.

## Update `common/root/etc/helios/idle.d/custom.sh`

Modify the existing `common/root/etc/helios/idle.d/custom.sh` script. This script will be executed when the system is idle.

```bash
#!/bin/bash

set -e

echo "Running custom idle script..."

# Add your custom commands here
echo "Custom idle script completed."
```

Make sure to give the script executable permissions:

```bash
chmod +x common/root/etc/helios/idle.d/custom.sh
```

## Build the Image

To build the image with the custom idle script included, you can run the following command:

```shell
make alpine-3
```

This command will build the Alpine 3 image with the custom idle script installed. You can replace `alpine-3` with any other distro supported by Helios to build those images with the custom idle script as well.