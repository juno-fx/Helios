# Custom Init

In this example, we will create a custom init script for Alpine, Debian, and RHEL based images to run a specific command at startup.

## Update `common/root/etc/helios/init.d/`

To add a custom init script, you can create a new file in the `common/root/etc/helios/init.d/` directory. For example, let's create a script named `custom-init.sh`:

```bash
#!/bin/bash

set -e

echo "Running custom init script..."

# Add your custom commands here
echo "Custom init script completed."
```

Make sure to give the script executable permissions:

```bash
chmod +x common/root/etc/helios/init.d/custom-init.sh
```

## Build the Image

To build the image with the custom init script included, you can run the following command:

```shell
make alpine-3
```

This command will build the Alpine 3 image with the custom init script installed. You can replace `alpine-3` with any other distro supported by Helios to build those images with the custom init script as well.
