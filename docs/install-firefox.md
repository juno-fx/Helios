# Add Firefox

In this example, we will add Firefox to the package management system and build it into alpine/debian/rhel based images.

---

## Update `packages.yaml`

### `packages` Section

Each item in the `packages` array defines a **single logical package**, and includes distro-specific keys for the corresponding package names:

```yaml
packages:
  - noble: firefox
    jammy: firefox
    debian: firefox-esr
    kali: firefox-esr
    alpine: firefox
    sid: firefox-esr
    rhel: firefox
```

We map Firefox to the appropriate package names for each distro. For example, `firefox` for Alpine and RHEL, and `firefox-esr` for Debian, Kali, and Sid.

### Build the Image

To build the image with Firefox included, you can run the following command:

```shell
make alpine-3
```

This command will build the Alpine 3 image with Firefox installed. You can replace `alpine-3` with any other distro supported by Helios to build those images with Firefox as well.
