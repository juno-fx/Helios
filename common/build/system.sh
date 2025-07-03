#!/bin/bash

set -e

# install uv
wget -qO- https://astral.sh/uv/install.sh | sh
mv -v /root/.local/bin/uv* /usr/local/bin/

sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
mkdir -p /opt/etc/
cp -r /root/.oh-my-zsh /opt/etc/oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions /opt/etc/oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /opt/etc/oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git /opt/etc/oh-my-zsh/custom/plugins/zsh-you-should-use


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
