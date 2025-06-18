
## 🤝 Contributing

Contributions to Helios are welcome! We just ask that you evaluate what you actually need to adjust. This repo is not
meant to provide a fully built desktop with all the bells and whistles. It is meant to provide a base image
that others can build on top of. That means most changes to Helios should be geared towards adding new distros,
optimizing the build process, or upgrading part of the Helios stack. If you have a specific use case that requires
a change to Helios, please open an issue or a pull request with a detailed explanation of the change and why it is
necessary.
 
- [Build Process](#build-process)
- [Repository Layout](#repository-layout)
- [Build Order](#build-order)
- [Shared Configuration Changes](#shared-configuration-changes)
- [Distro Specific Configuration Changes](#distro-specific-configuration-changes)
- [Custom Dependencies](#custom-dependencies)
- [Development Workflow](#development-workflow)
    - [Pre-requisites](#pre-requisites)
    - [Workflow](#workflow)

### Build Process

All builds are run through a single Dockerfile which is at the root of the repository. This describes the standard
procedure to build a Helios container. There are a few rules.

1. NOTHING distro specific should ever be added to the Dockerfile.
    - The only exception is the Ubuntu stage which generates the snakeoil certificates which are then copied into the common rootfs. This is used to satisfy the requirement for KasmVNC to launch on RHEL based distros.
2. All builds MUST be run through the Dockerfile at the root of the repository. This ensures that the build process is consistent across all distros and all versions are uniform.
3. The Dockerfile is heavily monitored for changes and any proposed changes will require a very detailed explanation of why the change is necessary and how it will affect the build process. As of right now, there is no reason to modify the Dockerfile as it provides hooks in the rest of the repo to do anything you want.

### Repository Layout

The repository is laid out as follows.

```
common
├── build <- Common build scripts for all distros
└── root <- Modified rootfs for all distros
<distro>
├── build <- Distro specific build scripts
└── root <- Distro specific rootfs
```

### Package Changes

We recommend you follow the [Unified Package Management System](README.md#-unified-package-management).

### Build Order

1. `common/build/novnc.sh` is run to build the noVNC client. (This is standard across all distros)
2. `<distro>/build/kasm.sh` is run to install the distro specific packages and dependencies to build the KasmVNC server and the custom X server.
3. `common/build/turbo.sh` is run to build the custom libjpeg-turbo required by KasmVNC server. (This is standard across all distros)
4. `common/build/kasm.sh` is run to build the KasmVNC server. (This is standard across all distros)
5. `<distro>/build/xorg.sh` is run to build the X server. Depending on the distro, it will change which X version is built. This is the case for RHEL distros for example.
6. `<distro>/build/kclient.sh` is run to install Node for the distro. This changes per distro as some distros have different package managers or versions of Node available.
7. `common/build/kclient.sh` is run to build the kclient client. (This is standard across all distros)

   > We do apply a helios.patch to the kclient that removes the fileserver functionality as well as automatically enable audio by default.

8. `common/build/package.sh` is run in the build stage to generate the rootfs containing, kclient, KasmVNC server, custom X server, and noVNC client.
9. `<distro>/root` is then copied into a fresh image with all distro specific files and configurations.
10. We then copy the packaged rootfs from the build stage to a fresh flattened image which "installs" Kasm
11. `<distro>/build/system.sh` is run to install the distro specific packages and dependencies to finalize the deliverable image.
12. `common/root` is copied into the image to provide the common rootfs files.

### Shared Configuration Changes

You can modify the shared configuration files in the `common/root` directory to customize the resulting rootfs.
For example, you can reference the `common/root/etc/kasm/kasmvnc.conf` file to change the default settings for KasmVNC.

### Distro Specific Configuration Changes

You can modify the distro specific configuration files in the `<distro>/root` directory to customize the resulting rootfs
for that specific distro. For example, you can reference the `<distro>/root/etc/skel/.bashrc` file to change the default
settings for the shell on that specific distro.

### Development Workflow

Development on Helios is meant to be as easy as possible.

#### Pre-requisites

1. **Devbox**: Install Devbox from their official [website](https://www.jetify.com/docs/devbox/installing_devbox/)

#### Workflow

1. Clone this repository and change into the directory.
2. Run `devbox shell` to enter the development environment.
3. Run `make <distro>` to build the desired distro. For example, `make noble` will build the Ubuntu 24.04 image.
4. Open your browser at `http://localhost:3000` to access the Kasm web client.
5. Formatting your changes is done by running `make format`.

> [!TIP]
> The make targets essentially launch `docker compose`. If you need to try other deployment configurations, such as 
> accessing a local graphics card, you can modify the `compose.yml` file in the root of the repository and run 
> `make <distro>` to start the container with your custom configuration. Please make sure to change this file back to 
> the original state before committing your changes.

