# Custom Services

In this example, we will create a custom service for Alpine, Debian, and RHEL based images to run a specific command as a service.

## Update `common/root/etc/helios/services.d/custom.sh`

Modify the existing `common/root/etc/helios/services.d/custom.sh` script. This script is triggered during the boot up process in Helios.

```bash
#!/bin/bash

set -e

echo "Running custom service script..."

# Add your custom commands here
echo "Custom service script completed."
```

!!! note

    You can use this to launch multiple services as well. Just keep in mind that this script is the entrypoint that is triggered from `s6`.


Make sure to give the script executable permissions:
```bash
chmod +x common/root/etc/helios/services.d/custom.sh
```

## Build the Image

To build the image with the custom service script included, you can run the following command:

```shell
make alpine-3
```

This command will build the Alpine 3 image with the custom service script installed. You can replace `alpine-3` with any other distro supported by Helios to build those images with the custom service script as well.
