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

fc-cache -f -v

# LD_PRELOAD fix
mv /usr/bin/thunar /usr/bin/thunar-real
mv /usr/bin/sudo /usr/bin/sudo-real

# Run common ansible playbooks if they exist
if [ -d "/tmp/playbooks/common" ]; then
    echo "Running common Ansible playbooks..."

    # Install ansible if not present
    if ! command -v ansible-playbook &>/dev/null; then
        pip install --break-system-packages ansible || pip install ansible
    fi

    # Run playbooks from common playbooks directory
    for playbook in /tmp/playbooks/common/*.yml; do
        [ -f "$playbook" ] && ansible-playbook "$playbook" --connection=local
    done

    # Clean up ansible to keep container lean
    pip uninstall -y ansible 2>/dev/null || true
    rm -rf /root/.cache/pip 2>/dev/null || true
fi

rm -rfv /tmp/*