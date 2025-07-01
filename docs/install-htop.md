# Add htop

In this example, we will add htop to the package management system and build it into alpine/debian/rhel based images.

---

## Update `packages.yaml`

### `packages` Section

Each item in the `packages` array defines a **single logical package**, and includes distro-specific keys for the corresponding package names:

```yaml
packages:
  - common: htop
```

This maps `htop` to the common package name, which will be used across all distros.

### Build the Image

To build the image with htop included, you can run the following command:

```shell
make alpine-3
```

This command will build the Alpine 3 image with htop installed. You can replace `alpine-3` with any other distro supported by Helios to build those images with htop as well.
