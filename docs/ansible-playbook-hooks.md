# Custom Ansible

Helios allows teams with existing Ansible playbooks to place them in the repo and have them run during container build phases. Playbooks support both per-distro hook locations and a common location that runs on all distros.

## Directory Structure

```
common/playbooks/          Playbooks that run on ALL distros
bookworm/playbooks/       Playbooks for Debian bookworm distro
noble/playbooks/          Playbooks for Ubuntu noble distro
jammy/playbooks/          Playbooks for Ubuntu jammy distro
rocky-9/playbooks/        Playbooks for Rocky Linux 9 / RHEL 9
alma-9/playbooks/         Playbooks for AlmaLinux 9
sid/playbooks/            Playbooks for Debian sid
kali/playbooks/           Playbooks for Kali rolling
```

**Rationale**: Directory names match the `SRC` build args used by the Dockerfile and Makefile, ensuring consistency with the existing build system.

## How It Works During Build

1. **Dockerfile copies playbooks into container**:
   - `${SRC}/playbooks` → `/tmp/playbooks/distro/` (distro-specific)
   - `common/playbooks` → `/tmp/playbooks/common/` (common for all distros)

2. **Distro-specific `build/system.sh` runs** → executes `/tmp/playbooks/distro/*.yml` playbooks

3. **Common `build/system.sh` runs** → executes `/tmp/playbooks/common/*.yml` playbooks

4. **Anifecycle**: Ansible auto-installed via pip during build, playbooks executed, then cleaned up within the same build layer to keep containers lean

## Adding Playbooks

### Common Playbooks (run on all distros)

Place playbook in `common/playbooks/site.yml`:

```yaml
- name: Common Ansible playbook for all distros
  hosts: localhost
  connection: local
  become: false

  tasks:
    - name: Display common playbook execution
      debug:
        msg: "Running common Ansible playbook on all distros"
```

### Distro-Specific Playbooks

Place playbook in `{distro}/playbooks/site.yml` (e.g., `rocky-9/playbooks/site.yml`):

```yaml
- name: Rocky Linux 9 Ansible playbook
  hosts: localhost
  connection: local
  become: false

  tasks:
    - name: Display playbook execution
      debug:
        msg: "Running Rocky Linux 9-specific Ansible playbook"
```

### Playbook Requirements

- `hosts: localhost` - targets the build host
- `connection: local` - runs on the build host during Docker build
- `become: false` - no privilege escalation needed for build-time configuration

## Execution Order

Distro-specific playbooks run **first**, then common playbooks run on top. This matches the Dockerfile build phase order (distro-first → common-on-top) and supports the workflow: "put a playbook for rocky-9 in the rocky-9 folder and also add a playbook in common which will be run on all distros."

## Keeping Containers Lean

- Ansible is auto-installed via pip if not present in the build environment
- After playbook execution, `pip uninstall -y ansible` and `/tmp/` cleanup remove ansible
- This ensures ansible and temporary files do not persist in the final container image

## Migration Path for Existing Ansible Users

Teams with existing playbooks can:

1. Place playbooks in the appropriate hook directories
2. Adjust playbooks with `hosts: localhost` and `connection: local` if needed
3. Add installation of any required Ansible collections within the playbooks
4. Start with just common playbooks, then add distro-specific playbooks as needed

The system gracefully handles empty directories - if no playbooks exist in a directory, no execution occurs and the build continues without error.