# Package Management

To streamline cross-distro package management, Helios uses a centralized `packages/system.yaml` system. This allows each logical package to be mapped to its appropriate name for each Linux distribution, while also enabling distros to inherit shared definitions from one or more package groups.

### Migrate from `packages.yaml`

Previously, Helios used a singular `packages.yaml` file which had all packages defined. With new system builds required, it became
clear that the packaging system can be used to also track build dependencies. The following changes have been made:

- The old `packages.yaml` file has been renamed to `packages/system.yaml`.
- The `inherit` section has now been pulled out into its own file `packages/inherit.yaml`.
- Support for custom lists is now supported. i.e. `packages/my-list.yaml`. You then can add this to the `packages/inherit.yaml`.

---

## Structure of `packages/system.yaml`

### `packages` Section

Each item in the `packages` array defines a **single logical package**, and includes distro-specific keys for the corresponding package names:

```yaml
packages:
  - debian: mesa-va-drivers        # VA-API support for Debian
    rhel: mesa-va-drivers          # Same package name for RHEL

  - debian: libx11-6
    rhel: libX11

  - debian: extra-debian-only-pkg
```

This format enables clean mapping between distros for the same logical dependency, and avoids repeating similar entries in multiple places.

### `packages/inherit.yaml` Section

This section defines which **groups of package mappings** each distro should inherit from.

```yaml
inherit:
  ubuntu:
    - common
    - debian
  debian:
    - common
  rhel:
    - common
```

In this example:

- **Ubuntu** inherits all packages defined under the `common` and `debian` groups.
- **RHEL**, **Debian**, and **Alpine** all inherit from the `common` group.
- Each distro may also have its own explicitly defined packages.

---

## Package List Generation

A preprocessing step flattens the data into a list of packages, combining:

1. All package mappings from the inherited groups
2. Any mappings explicitly defined for that distro

Each distro’s final list is saved as:

```
/lists/<name>.list
```

For example, `/lists/ubuntu.list` will include packages from:
- The `common` group
- The `debian` group
- Any Ubuntu-specific entries (if present)

---

### Build Integration

These generated lists are used directly in the image build process. Example from `alma-9/build/system.sh`:

```bash
dnf install -y --allowerasing --setopt=install_weak_deps=False --best \
  $(cat /lists/rhel.list) \
  fastfetch
```

This example installs the complete set of packages for a RHEL-based image (including inherited packages from `common`).
