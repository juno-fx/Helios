# Helios AGENTS.md

## Identity

Helios — containerized XFCE desktop workstation images. Multi-distro base images for Selkies WebRTC remote desktop. By Juno Innovations. Docker Hub: `junoinnovations/helios`.

This is a **base image** repo, not a full-featured desktop. Users extend via `FROM`. Changes should target: new distros, build optimizations, Helios stack upgrades.

## Documentation

Refer to `docs/` directory at repo root for project docs. Works fully airgap — no network needed. Also published at: https://juno-fx.github.io/Helios/

Agent can crawl `docs/*.md` for details on: deployment, package management, rootfs, build hooks, event hooks, customization, contributing.

## Repo layout

```
/
├── Dockerfile              # Single build entrypoint (DON'T modify casually)
├── Makefile                # make {distro}, make docs, make format, make build-all
├── compose.yml             # Local dev with docker compose
├── devbox.json             # Devbox dev environment
├── mkdocs.yml              # Documentation site config
├── docs/                   # MkDocs source — all project documentation
├── hack/
│   └── packages.py         # Flattens YAML pkg specs → per-distro .list files
├── packages/
│   ├── system.yaml          # Cross-distro package mappings
│   ├── inherit.yaml         # Inheritance graph
│   ├── selkies.yaml         # Selkies build deps
│   └── frontend.yaml        # Frontend build deps
├── common/
│   ├── build/
│   │   ├── system.sh        # Shared setup (theme, fonts, LD_PRELOAD wrappers)
│   │   ├── frontend.sh      # Selkies web frontend build (Alpine)
│   │   └── selkies/         # Selkies deps + cleanup (debian & rhel variants)
│   └── root/                # Shared rootfs overlay
│       ├── etc/
│       ├── opt/
│       ├── usr/
│       └── ...
├── {distro}/
│   ├── build/system.sh      # Distro-specific package install + config
│   └── root/                # Distro-specific rootfs overlay
│
│   # Supported distros:
│   bookworm/  sid/  kali/  jammy/  noble/  rocky-9/  alma-9/
│
└── .github/workflows/
```

## Build system

- **Single Dockerfile** at root — the one true build entrypoint. Uses `ARG IMAGE` / `ARG SRC`.
- **Makefile targets**: each distro e.g. `make noble` → `docker compose build --build-arg SRC=noble ...`
- **Package generation**: `make packages` → `python hack/packages.py` flattens YAML specs into `/lists/{distro}.list`
- **Build stages**: distro base → s6 overlay → selkies frontend → package lists → distro system.sh → common system.sh → selkies install → s6 init → rootfs overlays

## Init system

**s6-overlay v3.2.1.0.** Services in `common/root/etc/s6-overlay/s6-rc.d/`. DAG-style dependency chaining.

Service dependency order: `init-video → svc-pulseaudio → svc-xvfb → init-selkies → svc-selkies → svc-desktop → svc-nginx → helios`

## Runtime event hooks

| Hook dir | Trigger |
|---|---|
| `/etc/helios/init.d/` | Before user creation |
| `/etc/helios/services.d/custom.sh` | After user + system init |
| `/etc/helios/idle.d/custom.sh` | On idle timeout (xssstate) |
| `/etc/helios/shutdown.d/custom.sh` | On container shutdown |

## Package management

Centralized cross-distro package mapping in `packages/system.yaml`. Each entry has distro-specific keys:
```yaml
- common: package_name          # Installed on all distros
  debian: pkg_name              # Debian-family only
  rhel: pkg_name                # RHEL-family only
  ubuntu: pkg_name              # Ubuntu-only override
  alpine: pkg_name              # Alpine-only
  selkies: pkg_name             # Selkies build deps
  frontend: pkg_name            # Frontend build deps
```

Inheritance in `packages/inherit.yaml`:
- `ubuntu` ← `common` + `debian`
- `debian` ← `common`
- `rhel` ← `common`
- `selkies` ← `selkies` + `selkies-debian`
- `selkies-rhel` ← `selkies` + `selkies-rhel`

## Deployment

| Method | Ports | Key env vars |
|---|---|---|
| Docker run | 3000 (HTTPS), 3001 | USER, UID, GID, PASSWORD, SUDO, PREFIX, IDLE_TIME, DISABLE_VGL, SELKIES_FRAMERATE, DESKTOP_FILES |
| Docker Compose | via compose.yml | |
| Kubernetes | ConfigMap for event hooks | |

## Versioning

`v0.0.0-codename` (e.g., `v0.0.0-noble`). Managed via `bumpversion.toml` — updates Dockerfile + README.

## Dev setup

```bash
devbox shell              # Activates venv + installs deps
make docs                 # mkdocs serve for doc site
make format               # shfmt on bash scripts
make packages             # Regenerate package lists
make noble                # Build + run noble distro
```

## Hard rules (from CONTRIBUTING.md)

1. **NOTHING distro-specific in Dockerfile** — use `common/` or distro-specific `build/system.sh`
2. **All builds through root Dockerfile only** — no alternative Dockerfiles
3. **Dockerfile changes require detailed justification** — the hooks/rootfs/packages system covers all customization needs
4. **PR template** requires: code format, linting, tests, docs, no merge conflicts

## Tech stack

- **Desktop**: XFCE4 (xfwm4, thunar, xfce4-panel, whiskermenu, xfce4-terminal)
- **Remote access**: Selkies WebRTC (pinned commit), Xvfb, VirtualGL
- **Audio**: PulseAudio
- **Frontend proxy**: Nginx
- **Theme**: Orchis dark orange compact + Cascadia Code font
- **Build tools**: bash, Python (yaml), Make, Docker, Devbox

## Examples

### Add a common package (all distros)

Edit `packages/system.yaml`, add entry under `packages`:

```yaml
# Installed on every distro
- common: nano
```

Then run `make packages` to regenerate the lists, then `make {distro}` to rebuild.

### Add a Debian-only / RHEL-only package

```yaml
# Only on Debian family
- debian: age

# Only on RHEL family
- rhel: htop
```

Due to inheritance, `ubuntu` inherits from `debian`, so the `debian` key covers Ubuntu too. RHEL-only maps to both rocky-9 and alma-9.

### Add a distro-specific package override

Ubuntu needs its own package name where Debian uses a different one:

```yaml
- debian: firefox-esr
  ubuntu: firefox
```

### Replace the desktop background

1. Place your image at `common/root/usr/share/backgrounds/background.jpg` (overwrite the existing file).
2. The XFCE desktop config at `common/root/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml` already references `/usr/share/backgrounds/background.jpg` — no XML change needed if filename stays the same.
3. Rebuild: `make noble` (or any distro).

For a different filename, update the `last-image` value in that XML file (appears on all monitors × workspaces).

### Brand the Selkies web manifest

Edit `common/root/etc/s6-overlay/s6-rc.d/init-selkies/start.sh`. The PWA manifest is written inline:

```bash
echo "{
  \"name\": \"YourBrand\",
  \"short_name\": \"YourBrand\",
  ...
  \"background_color\": \"#yourcolor\",
  \"theme_color\": \"#yourcolor\",
  ...
}" >/usr/share/selkies/www/manifest.json
```

### Add an init hook (runs at container start)

Create an executable script at `common/root/etc/helios/init.d/99-my-setup.sh`:

```bash
#!/bin/bash
# Runs before user creation
echo "Custom init" > /var/log/my-init.log
```

Hooks are auto-chmod'd if not executable. Failures are logged but don't block startup.

### Add an idle hook (auto-shutdown, maintenance)

Create or modify `common/root/etc/helios/idle.d/custom.sh`:

```bash
#!/bin/bash
echo "Container idle — running maintenance"
# e.g., sync logs, clean temp files, or shutdown
```

Triggered when `xssstate` reports idle exceeding `IDLE_TIME` env var.

### Add a build hook (image build-time)

Write a script at `common/build/system.sh` (shared) or `{distro}/build/system.sh` (per-distro):

```bash
#!/bin/bash
set -e
echo "Custom build step"
apt install --no-install-recommends -y my-tool   # Debian
# or: dnf install -y my-tool                      # RHEL
```

This runs during `docker build`, after base packages install but before cleanup.

## What agent should NEVER do

- Modify Dockerfile without explicit deep-reasoned justification
- Add distro-specific logic to common layer without using inheritance pattern
- Change pinned Selkies commit without verifying upstream compatibility
- Use `git commit` / `git push` — version control operations reserved for user
- Add emojis unless explicitly requested
- Create documentation files unless explicitly requested
- Use `cd path && cmd` — use `workdir` param instead
- Run any command before reading the file first
- Create new files when editing existing ones suffices
