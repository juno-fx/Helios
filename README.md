# Helios
Optimized Kasm Desktops for general use

## Features

- **Lightweight**: Minimal resource usage for efficient performance.
- **WebRTC Support**: Seamless audio and video streaming capabilities. (Non-RHEL distros)
- **Multi-Monitor Support**: Enhanced productivity with multiple displays.
- **Audio Support**: High-quality audio streaming for a better user experience.

## Kasm Setup

We try our best to keep the latest version of Kasm installed so we get all the latest features and bug fixes.

- **Kasm VNC**: [e647af5e281735d1c7fc676ca089201aeae7130a](https://github.com/kasmtech/KasmVNC/tree/e647af5e281735d1c7fc676ca089201aeae7130a)
- **Kasm Web Client**: [bed156c565f7646434563d2deddd3a6c945b7727](https://github.com/kasmtech/noVNC/tree/bed156c565f7646434563d2deddd3a6c945b7727)
- **Linux Server KClient**: [master](https://github.com/linuxserver/kclient/commits/master/)

## Distros

### [Ubuntu 24.04 (Noble)](https://hub.docker.com/_/ubuntu/tags?name=noble)

- Size: 1.48 GB
- X Server: 21.1.4 (Custom)


### [Ubuntu 22.04 (Jammy)](https://hub.docker.com/_/ubuntu/tags?name=jammy)

- Size: 1.48 GB
- X Server: 21.1.4 (Custom)


### [Kali Linux (Rolling Release)](https://hub.docker.com/r/kalilinux/kali-rolling)

> [!TIP]  
> We don't install any default Kali tools in this image. Please follow the instructions in the [Kali Linux Docker Image documentation](https://www.kali.org/docs/containers/official-kalilinux-docker-images/) to install them.

- Size: 1.74 GB (This does not include the Kali tools which make the image much larger)
- X Server: 21.1.4 (Custom)


### [Rocky Linux (9)](https://hub.docker.com/_/rockylinux/tags?name=9)

> [!WARNING]  
> Currently WebRTC is not supported on Rocky Linux due to upstream limitations with Kasm. This may change in the future.

- Size: 1.82 GB
- X Server: 1.20.14 (Custom)


### [Alma Linux (9)](https://hub.docker.com/_/almalinux/tags?name=9)

> [!WARNING]  
> Currently WebRTC is not supported on Alma Linux due to upstream limitations with Kasm. This may change in the future.

- Size: 1.61 GB 
- X Server: 1.20.14 (Custom)

## Contributing

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

