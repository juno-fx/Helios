# Shared Theme

In this example, we will use the `common/build/system.sh` script to build a shared theme into Alpine, Debian, and RHEL based images.

## Update `common/build/system.sh`

To add a shared theme, you can modify the `common/build/system.sh` script to include the necessary commands for installing the theme. For example, if you want to install a GTK theme, you might add:

```bash
#!/bin/bash

set -e

echo "Common System Tools"

# install custom theme
cd /tmp/
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh -d /usr/share/themes -c dark -t orange -n Orchis -i ubuntu -s compact

# install font
mkdir -pv /usr/share/fonts/cascadia-code
cd /tmp
wget https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip
unzip CascadiaCode-2407.24.zip
mv -v otf/static/* /usr/share/fonts/cascadia-code/
rm -rfv /tmp/*
fc-cache -f -v
```

This script clones a theme repository, installs the theme to the appropriate directory, and also 
installs a custom font. You can modify the commands to suit your specific theme and font requirements.

## Build the Image

To build the image with the shared theme included, you can run the following command:

```shell
make alpine-3
```

This command will build the Alpine 3 image with the shared theme installed. You can replace `alpine-3` with any other distro supported by Helios to build those images with the shared theme as well.
