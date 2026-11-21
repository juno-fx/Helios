#!/bin/bash
# Example init script for Helios with Ansible support

echo "Example init script for Helios"

# Run Ansible playbook if present in /etc/helios/playbooks/
if [ -d "/etc/helios/playbooks" ]; then
    echo "Running Ansible playbooks from /etc/helios/playbooks..."
    
    # Install ansible if not present
    if ! command -v ansible-playbook &>/dev/null; then
        pip install --break-system-packages ansible 2>/dev/null || true
    fi
    
    # Run playbooks
    for playbook in /etc/helios/playbooks/*.yml; do
        [ -f "$playbook" ] && ansible-playbook "$playbook" --connection=local || true
    done
    
    # Clean up ansible
    pip uninstall -y ansible 2>/dev/null || true
    rm -rf /root/.cache/pip 2>/dev/null || true
fi