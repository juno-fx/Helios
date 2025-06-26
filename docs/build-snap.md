# Disable Firefox Snap

In this example, we will disable the Firefox Snap package in Helios by using the system.sh build script for Ubuntu Noble.

## Update `noble/build/system.sh`

To disable the Firefox Snap package, you can modify the `noble/build/system.sh` script to remove the apt snap preference for Firefox.

```bash
#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

cat >/etc/apt/preferences.d/firefox-no-snap <<EOL
Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1
EOL

sed -i '/locale/d' /etc/dpkg/dpkg.cfg.d/excludes
apt update
apt upgrade -y
apt install -y gnupg curl wget
wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey |
	gpg --dearmor >/etc/apt/trusted.gpg.d/VirtualGL.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/VirtualGL.gpg] https://packagecloud.io/dcommander/virtualgl/any/ any main" >/etc/apt/sources.list.d/virtualgl.list
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt update

...rest of the install commands...
```

This script creates a preference file that sets the priority of the Firefox Snap package to -1, effectively disabling it. The rest of the script remains unchanged, allowing you to continue installing other packages as needed.

## Build the Image

To build the image with the modified system script, you can run the following command:

```bash
make noble
```

This command will build the Ubuntu Noble image with the Firefox Snap package disabled. 