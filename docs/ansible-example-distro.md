# Custom Distro-Specific

Place playbooks in `{distro}/playbooks/` to run only for that distro.

## Directory Structure

```
devel/Helios/bookworm/playbooks/site.yml   # Debian bookworm
devel/Helios/noble/playbooks/site.yml      # Ubuntu noble
devel/Helios/rocky-9/playbooks/site.yml   # Rocky Linux 9 / RHEL 9
devel/Helios/alma-9/playbooks/site.yml    # AlmaLinux 9
devel/Helios/sid/playbooks/site.yml       # Debian sid
devel/Helios/kali/playbooks/site.yml      # Kali rolling
devel/Helios/jammy/playbooks/site.yml     # Ubuntu jammy
```

## Usage

The distro-specific playbook executes before the common playbook. This order ensures distro-specific customization happens first, then common playbooks run on top.

## Requirements

```
hosts: localhost
connection: local
become: false
```

## Example

```yaml
- name: Rocky Linux 9 Ansible playbook
  hosts: localhost
  connection: local
  become: false

  tasks:
    - name: Install RHEL 9 package
      ansible.builtin.package:
        name: tmux
        state: present
```