# Helios
Optimized Kasm Desktops for general use

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Kasm Setup](#kasm-setup)
- [Distros](#distros)
  - Debian
    - [Debian 12 (Bookworm)](#debian-12-bookworm)
    - [Debian Rolling (Trixie/Sid)](#debian-rolling-trixie-sid)
    - [Kali Linux (Rolling Release)](#kali-linux-rolling-release)
  - Ubuntu
    - [Ubuntu 24.04 (Noble)](#ubuntu-2404-noble)
    - [Ubuntu 22.04 (Jammy)](#ubuntu-2204-jammy)
  - RHEL
    - [Rocky Linux (9)](#rocky-linux-9)
    - [Alma Linux (9)](#alma-linux-9)
- [Versioning](#versioning)
- [Usage](#usage)
    - [Deployment](#deployment)
        - [Docker](#docker)
        - [Docker Compose](#docker-compose)
        - [Kubernetes](#kubernetes)
- [Customizing Helios](#customizing-helios)
    - [Using FROM](#using-from)
    - [Event Hooks](#event-hooks)
        - [Using FROM](#using-from-1)
        - [Mounting](#mounting)
- [Contributing](#contributing)
    - [Build Process](#build-process)
    - [Repository Layout](#repository-layout)
    - [Build Order](#build-order)
    - [Shared Configuration Changes](#shared-configuration-changes)
    - [Distro Specific Configuration Changes](#distro-specific-configuration-changes)
    - [Custom Dependencies](#custom-dependencies)
    - [Development Workflow](#development-workflow)
        - [Pre-requisites](#pre-requisites)
        - [Workflow](#workflow)
- [Acknowledgements](#acknowledgements)

## Overview

Helios provides base images for multiple key Linux distributions, optimized to be as small as possible to reduce pull 
times, minimize attack surface and reduce data transfer costs. These images are designed to be lightweight, efficient, 
and ready for use in various environments such as Docker, Kubernetes, and more. Some key points about Helios:

- **Base Images**: Helios containers are meant to be used as a base image for Kasm compatible deployments.
- **Extremely Minimal Desktops**: The images are designed to be as minimal as possible. No additional software should ever be added the these images. Instead, you should use the `FROM` instruction in your Dockerfile to build on top of Helios images.

## Features

- **Lightweight**: Minimal resource usage for efficient performance.
- **WebRTC Support**: Seamless audio and video streaming capabilities. (Non-RHEL distros)
- **Multi-Monitor Support**: Enhanced productivity with multiple displays.
- **Audio Support**: High-quality audio streaming for a better user experience.
- **VirtualGL Support**: Hardware-accelerated graphics for 3D applications is supported using `vglrun`.

## Kasm Setup

We try our best to keep the latest version of Kasm installed so we get all the latest features and bug fixes.

- **Kasm VNC**: [e647af5e281735d1c7fc676ca089201aeae7130a](https://github.com/kasmtech/KasmVNC/tree/e647af5e281735d1c7fc676ca089201aeae7130a)
- **Kasm Web Client**: [bed156c565f7646434563d2deddd3a6c945b7727](https://github.com/kasmtech/noVNC/tree/bed156c565f7646434563d2deddd3a6c945b7727)
- **Kasm Binaries**: 1.15.0
- **Linuxserver.io KClient**: [master](https://github.com/linuxserver/kclient/commits/master/)

## Distros

### Debian

#### [Debian 12 (Bookworm)](https://hub.docker.com/_/debian/tags?name=bookworm)

- Size: 1.68 GB
- X Server: 21.1.4 (Custom)

#### [Debian Rolling (Trixie/Sid)](https://hub.docker.com/_/debian/tags?name=sid)

- Size: 1.79 GB
- X Server: 21.1.4 (Custom)

#### [Kali Linux (Rolling Release)](https://hub.docker.com/r/kalilinux/kali-rolling)

> [!TIP]  
> We don't install any default Kali tools in this image. Please follow the instructions in the [Kali Linux Docker Image documentation](https://www.kali.org/docs/containers/official-kalilinux-docker-images/) to install them.

- Size: 1.73 GB (This does not include the Kali tools which make the image much larger)
- X Server: 21.1.4 (Custom)

### Ubuntu

#### [Ubuntu 24.04 (Noble)](https://hub.docker.com/_/ubuntu/tags?name=noble)

- Size: 1.48 GB
- X Server: 21.1.4 (Custom)


#### [Ubuntu 22.04 (Jammy)](https://hub.docker.com/_/ubuntu/tags?name=jammy)

- Size: 1.48 GB
- X Server: 21.1.4 (Custom)


### RHEL

#### [Rocky Linux (9)](https://hub.docker.com/_/rockylinux/tags?name=9)

> [!WARNING]  
> Currently WebRTC is not supported on Rocky Linux due to upstream limitations with Kasm. This may change in the future.

- Size: 1.82 GB
- X Server: 1.20.14 (Custom)


#### [Alma Linux (9)](https://hub.docker.com/_/almalinux/tags?name=9)

> [!WARNING]  
> Currently WebRTC is not supported on Alma Linux due to upstream limitations with Kasm. This may change in the future.

- Size: 1.61 GB 
- X Server: 1.20.14 (Custom)

## Versioning

Helios ships its own version that is independent of the underlying distro version. The version is in the format 
`v0.0.0-noble`, where `noble` is the codename of the underlying distro. This allows us to track changes and updates to 
Helios independently of the underlying distro. Some further examples of the versioning scheme are:

- `v0.0.0-bookworm` for Debian 12 (Bookworm)
- `v0.0.0-noble` for Ubuntu 24.04
- `v0.0.0-jammy` for Ubuntu 22.04
- `v0.0.0-kali` for Kali Linux
- `v0.0.0-rocky-9` for Rocky Linux
- `v0.0.0-alma-9` for Alma Linux

Helios also ships `unstable` builds which are built directly off of the `main` branch. These builds are meant for
testing and development purposes only. They are not meant for production use and may contain bugs or incomplete features.

- `unstable-bookworm` for the latest unstable build of Debian 12
- `unstable-noble` for the latest unstable build of Ubuntu 24.04
- `unstable-jammy` for the latest unstable build of Ubuntu 22.04
- `unstable-kali` for the latest unstable build of Kali Linux
- `unstable-rocky-9` for the latest unstable build of Rocky Linux
- `unstable-alma-9` for the latest unstable build of Alma Linux

Helios also ships a `testing` tag which is built from the `testing` branch. This branch is meant for testing new 
features and changes before they are merged into the `main` branch. The `testing` tag is meant to be used for testing 
purposes only and may contain bugs or incomplete features.

- `testing-noble` for the latest testing build of Ubuntu 24.04
- `testing-jammy` for the latest testing build of Ubuntu 22.04
- `testing-kali` for the latest testing build of Kali Linux
- `testing-rocky-9` for the latest testing build of Rocky Linux
- `testing-alma-9` for the latest testing build of Alma Linux


## Usage

### Environment Variables

Environment variables are used to configure the Helios container. The following environment variables are available:

| Name     | Value                                               | Required |
|----------|-----------------------------------------------------|----------|
| USER     | Name of the user                                    | X        |
| PASSWORD | Password that will be set to access the workstation | X        |
| UID      | POSIX compliant uid for the user                    | X        |
| GID      | POSIX compliant gid for the user                    |          |

> [!TIP]  
> The `GID` will match the `UID` if not specified.

> [!TIP]  
> The `UID` and `GID` are NOT the user that is launching and running the container. 
> Because of s6, the container always starts and runs as root. It then uses s6 to run the desktop using the specified 
> user using those environment variables. This is done to ensure that the desktop has the correct permissions and 
> ownership on things like the home directory and other files. This helps with things like Network Shares as well.

### Ports

Helios exposes the following ports:

| Port | Description       |
|------|-------------------|
| 3000 | HTTP Desktop Port |

### Deployment

Helios is meant to be launched in a number of different ways. It works as a standalone docker container as well as being
k8s ready. The following examples show how to run Helios in different environments.


#### Docker
You can run Helios in a Docker container using the following command:

```shell
docker run -d \
  --name helios \
  -p 3000:3000 \
  -e USER=bob \
  -e UID=1000 \
  -e GID=1000 \
  -e PASSWORD=password \
  helios:v0.0.0-noble
``` 

#### Docker Compose

You can also use Docker Compose to run Helios. Create a `docker-compose.yml` file with the following content:

```yaml
services:
   helios:
      image: helios:v0.0.0-noble
      hostname: "helios"
      container_name: helios
      environment:
         - USER=helios
         - UID=1000
         - GID=1000
         - PASSWORD=password
      ports:
         - "3000:3000"
```

#### Kubernetes

You can run Helios in a Kubernetes cluster using the following manifest:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
   name: helios
spec:
   serviceName: helios
   replicas: 1
   selector:
      matchLabels:
         app: helios
   template:
      metadata:
         labels:
            app: helios
      spec:
         containers:
            - name: helios
              image: helios:v0.0.0-noble
              ports:
                 - containerPort: 3000
              env:
                 - name: USER
                   value: "helios"
                 - name: UID
                   value: "1000"
                 - name: GID
                   value: "1000"
                 - name: PASSWORD
                   value: "password"
```

## Customizing Helios

### Using FROM

You can use the `FROM` instruction in your Dockerfile to build on top of Helios images. For example, if you want to build
on top of the Ubuntu 24.04 image, you can do the following:

```dockerfile
FROM helios:v0.0.0-noble

RUN apt-get update && \
    apt-get install -y htop
```

You can then push it to a private registry and use it in your Kasm compatible deployments.

### Event Hooks

Helios uses the [s6 overlay](https://github.com/just-containers/s6-overlay) init system from [just-containers](https://github.com/just-containers).
This allows us to tap into the boot sequence of the container and run custom scripts and even custom services. This is
heavily inspired by the incredible team at [Linuxserver IO](https://www.linuxserver.io/).

> [!TIP]  
> The init hook executes before all else. So the user is not present yet on the system, but you have full access to the environment variables and the filesystem.

Custom services are executed via the `/etc/helios/services.d` directory. You can add your own custom services by overriding
the `/etc/helios/services.d/custom.sh` file in your Dockerfile or by mounting it into the container. There you can launch 
your own custom services that will run in the background.

#### Using FROM

As mentioned above, you can use the `FROM` instruction to add in your custom init scripts and services.

```dockerfile
FROM helios:v0.0.0-noble

# custom init script
COPY ./my-custom-init.sh /etc/helios/init.d/my-custom-init.sh

# custom service
COPY ./my-custom-service.sh /etc/helios/services.d/custom.sh
```

#### Mounting

Finally, you can dynamically mount the scripts via docker or kubernetes mounts by just mapping the sciripts to the
`/etc/helios/init.d` or `/etc/helios/services.d` directories. This allows you to have custom scripts and services without
the need to rebuild the image. This is useful for testing and development purposes.

```shell
docker run -d \
  --name my-helios-container \
  -v /path/to/my-custom-init.sh:/etc/helios/init.d/my-custom-init.sh \
  -v /path/to/my-custom-service.sh:/etc/helios/services.d/custom.sh \
  helios:v0.0.0-noble
```

You can achive the same a number of ways in Kubernetes. For example, you can use a ConfigMap to mount the scripts into the container.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-helios-config
data:
    my-custom-init.sh: |
        #!/bin/sh
        echo "Hello from my custom init script!"
    
    my-custom-service.sh: |
        #!/bin/bash
        
        set -e
        
        echo
        echo "Helios Custom Service Initialization"
        echo
        /path/to/my/custom/script.sh
        /path/to/my/other/custom/script.sh
        sleep infinity
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-helios-deployment
spec:
    replicas: 1
    selector:
        matchLabels:
           app: my-helios-app
    template:
        metadata:
           labels:
               app: my-helios-app
        spec:
           containers:
           - name: helios-container
             image: helios:v0.0.0-noble
             ports:
               - containerPort: 3000
             volumeMounts:
              - name: custom-scripts
                mountPath: /etc/helios/init.d/my-custom-init.sh
                subPath: my-custom-init.sh
              - name: custom-services
                mountPath: /etc/helios/services.d/custom.sh
                subPath: my-custom-service.sh
           volumes:
           - name: custom-scripts
             configMap:
               name: my-helios-config
           - name: custom-services
             configMap:
               name: my-helios-config
```

## Contributing

Contributions to Helios are welcome! We just ask that you evaluate what you actually need to adjust. This repo is not
meant to provide a fully built desktop with all the bells and whistles. It is meant to provide a base image
that others can build on top of. That means most changes to Helios should be geared towards adding new distros,
optimizing the build process, or upgrading part of the Helios stack. If you have a specific use case that requires
a change to Helios, please open an issue or a pull request with a detailed explanation of the change and why it is
necessary.

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

### Shared Configuration Changes

You can modify the shared configuration files in the `common/root` directory to customize the resulting rootfs.
For example, you can reference the `common/root/etc/kasm/kasmvnc.conf` file to change the default settings for KasmVNC.

### Distro Specific Configuration Changes

You can modify the distro specific configuration files in the `<distro>/root` directory to customize the resulting rootfs
for that specific distro. For example, you can reference the `<distro>/root/etc/skel/.bashrc` file to change the default
settings for the shell on that specific distro.

### Custom Dependencies

If you would like to pre-install different packages, you can modify the `<distro>/build/system.sh` file to add the packages
you want to install. For example, the Kali Linux image doesn't ship with any of the Kali tools by default. You can add them
to the `system.sh` file to have them pre-installed in the image.

```shell
...
apt-get update
apt-get install -y kali-linux-headless
...
```

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


## Acknowledgements

Helios is built on the shoulders of giants. We would like to acknowledge the following projects and teams for inspiring us:

- [Kasm](https://www.kasmweb.com/kasmvnc) for providing the base VDI solution for our containerized desktops.
- [Linuxserver.io](https://www.linuxserver.io/) for their incredible work which heavily inspires our workflow.
- [just-containers](https://github.com/just-containers/) for the awesome s6 overlay init system.
