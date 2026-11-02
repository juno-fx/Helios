# Contributing

[Documentation](https://juno-fx.github.io/Helios/contributing/)

## Ansible Playbook Hooks

Helios supports placing Ansible playbooks in designated hook directories that run during container build phases.

### Directory Structure

Place playbooks in directories matching the distro build args:

- `common/playbooks/` - playbooks running on ALL distros
- `bookworm/playbooks/` - Debian bookworm-specific
- `noble/playbooks/` - Ubuntu noble-specific
- `jammy/playbooks/` - Ubuntu jammy-specific
- `rocky-9/playbooks/` - Rocky Linux 9 / RHEL 9-specific
- `alma-9/playbooks/` - AlmaLinux 9-specific
- `sid/playbooks/` - Debian sid-specific
- `kali/playbooks/` - Kali rolling-specific

### Execution

Playbooks run with `--connection=local` during the container build phase. Ansible is auto-installed during build and cleaned up after execution to keep containers lean.

### Adding Playbooks

Place YAML playbooks in the appropriate directory. Playbooks must use `hosts: localhost` and `connection: local`.

### Execution Order

Distro-specific playbooks run first, then common playbooks. This matches the Dockerfile build phase order.

### Keeping Containers Lean

Ansible is installed during build and removed after playbook execution. Temporary files are cleaned up within the same build layer.
