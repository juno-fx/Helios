# Custom Common

Place playbooks in `common/playbooks/` to run on ALL distros.

## Directory

```
devel/Helios/common/playbooks/site.yml
```

## Usage

The common playbook executes after distro-specific playbooks, providing common configuration applied to all Helios container images.

## Requirements

```
hosts: localhost
connection: local
become: false
```

## Example

```yaml
- name: Common Ansible playbook for all distros
  hosts: localhost
  connection: local
  become: false

  tasks:
    - name: Install common package
      ansible.builtin.package:
        name: tmux
        state: present
```