# 🚀 Helios

Helios provides base images for multiple key Linux distributions, optimized to be as small as possible to:

- Reduce pull times  
- Minimize the attack surface  
- Lower data transfer costs  

These images are lightweight, efficient, and ready to use across environments like Docker, Kubernetes, and more.

Some key points about Helios:

- **Base Images**: Designed as base images for Kasm-compatible deployments.  
- **Extremely Minimal Desktops**: Images are intentionally minimal; avoid adding software directly. Instead, extend via the `FROM` instruction in your Dockerfile.

## 📚 Table of Contents

- 🚀 [Features](#✨-features)  
- ⚙️ [Kasm Setup](#⚙️-kasm-setup)
- 🐧 [Distros Overview](#🐧-distros-overview)  
  - Alpine  
    - [Alpine 3](#alpine-3)  
  - Debian  
    - [Debian 12 (Bookworm)](#debian-12-bookworm)  
    - [Debian Rolling (Trixie/Sid)](#debian-rolling-trixie-sid)  
    - [Kali Linux (Rolling Release)](#kali-linux-rolling-release)  
  - Ubuntu  
    - [Ubuntu 24.04 (Noble)](#ubuntu-2404-noble)  
    - [Ubuntu 22.04 (Jammy)](#ubuntu-2204-jammy)  
  - RHEL  
    - [Rocky Linux 9](#rocky-linux-9)  
    - [Alma Linux 9](#alma-linux-9)
- 🏷️ [Versioning](#%EF%B8%8F-versioning)
- ⚡ [Usage](#usage)  
  - Deployment  
    - [`Docker`](#docker)  
    - [`Docker Compose`](#docker-compose)  
    - [`Kubernetes`](#kubernetes)
- 🛠️ [Customizing Helios](#customizing-helios)  
  - [Unified Package Management](#-unified-package-management)  
  - [Using `FROM`](#%EF%B8%8F-using-from)  
  - [Event Hooks](#%EF%B8%8F-event-hooks)  
    - [Using `FROM`](#%EF%B8%8F-using-from-1)  
    - [Mounting Scripts Dynamically](#-mounting-scripts-dynamically)
- 🤝 [Contributing](CONTRIBUTING.md)
  - 📜 [Code of Conduct](CODE_OF_CONDUCT.md)
- 🙏 [Acknowledgements](#acknowledgements)

---

## ✨ Features

- **Lightweight**: Minimal resource usage for efficient performance.  
- **WebRTC Support**: Seamless audio and video streaming (available on non-RHEL distros).  
- **Multi-Monitor Support**: Enhanced productivity with multiple displays.  
- **Audio Support**: High-quality audio streaming for improved user experience.  
- **VirtualGL Support**: Hardware-accelerated 3D graphics using `vglrun`.

---

## ⚙️ Kasm Setup

We maintain the latest versions of Kasm components to ensure access to the newest features and bug fixes:

- **Kasm VNC**: [v1.3.4](https://github.com/kasmtech/KasmVNC/tree/release/1.3.4)  
- **Kasm Web Client**: [Commit bed156c](https://github.com/kasmtech/noVNC/tree/bed156c565f7646434563d2deddd3a6c945b7727)  
- **Kasm Binaries**: v1.15.0  
- **Linuxserver.io KClient**: [Latest master branch](https://github.com/linuxserver/kclient/commits/master/)

---

## 🐧 Distros Overview

Explore the supported Linux distributions with their versions, image sizes, and X Server details.

---

### Alpine

#### [Alpine 3](https://hub.docker.com/_/alpine/tags?name=3)

- **Size:** 1.16 GB  
- **X Server:** 1.20.14 (Custom)

---

### Debian Family

#### [Debian 12 (Bookworm)](https://hub.docker.com/_/debian/tags?name=bookworm)

- **Size:** 1.67 GB  
- **X Server:** 21.1.4 (Custom)

#### [Debian Rolling (Trixie/Sid)](https://hub.docker.com/_/debian/tags?name=sid)

- **Size:** 1.72 GB  
- **X Server:** 21.1.4 (Custom)

#### [Kali Linux (Rolling Release)](https://hub.docker.com/r/kalilinux/kali-rolling)

> [!TIP]  
> No default Kali tools are installed in this image. Please refer to the [Kali Linux Docker Image documentation](https://www.kali.org/docs/containers/official-kalilinux-docker-images/) for installing them.

- **Size:** 1.72 GB (Excludes Kali tools which increase image size)  
- **X Server:** 21.1.4 (Custom)

---

### Ubuntu Variants

#### [Ubuntu 24.04 (Noble)](https://hub.docker.com/_/ubuntu/tags?name=noble)

- **Size:** 1.46 GB  
- **X Server:** 21.1.4 (Custom)

#### [Ubuntu 22.04 (Jammy)](https://hub.docker.com/_/ubuntu/tags?name=jammy)

- **Size:** 1.34 GB  
- **X Server:** 21.1.4 (Custom)

---

### Red Hat Ecosystem

#### [Rocky Linux 9](https://hub.docker.com/_/rockylinux/tags?name=9)

> [!WARNING]  
> WebRTC is currently **not supported** on Rocky Linux due to upstream Kasm limitations. This may change in the future.

- **Size:** 1.86 GB  
- **X Server:** 1.20.14 (Custom)

#### [Alma Linux 9](https://hub.docker.com/_/almalinux/tags?name=9)

> [!WARNING]  
> WebRTC is currently **not supported** on Alma Linux due to upstream Kasm limitations. This may change in the future.

- **Size:** 1.61 GB  
- **X Server:** 1.20.14 (Custom)

## 🏷️ Versioning

Helios uses its own versioning scheme independent of the underlying distro versions. The format is: `v0.0.0-codename` where `codename` represents the underlying distro. This allows tracking Helios changes separately from distro updates.

### Examples

| Helios Version    | Distro               |
|-------------------|----------------------|
| `v0.0.0-bookworm` | Debian 12 (Bookworm) |
| `v0.0.0-alpine-3` | Alpine (3)           |
| `v0.0.0-noble`    | Ubuntu 24.04         |
| `v0.0.0-jammy`    | Ubuntu 22.04         |
| `v0.0.0-kali`     | Kali Linux           |
| `v0.0.0-rocky-9`  | Rocky Linux          |
| `v0.0.0-alma-9`   | Alma Linux           |

---

### Additional Tags

- **Unstable builds** (from the `main` branch): Intended for testing and development only. These builds **may contain bugs or incomplete features**.

  Examples:
  - `unstable-bookworm` (Debian 12)
  - `unstable-alpine-3` (Alpine 3)
  - `unstable-noble` (Ubuntu 24.04)
  - `unstable-jammy` (Ubuntu 22.04)
  - `unstable-kali` (Kali Linux)
  - `unstable-rocky-9` (Rocky Linux)
  - `unstable-alma-9` (Alma Linux)

- **Testing builds** (from the `testing` branch): For testing new features before merging into `main`. Also **may contain bugs or incomplete features**.

  Examples:
  - `testing-noble` (Ubuntu 24.04)
  - `testing-bookworm` (Debian 12)
  - `testing-alpine-3` (Alpine 3)
  - `testing-jammy` (Ubuntu 22.04)
  - `testing-kali` (Kali Linux)
  - `testing-rocky-9` (Rocky Linux)
  - `testing-alma-9` (Alma Linux)





## Usage

### Environment Variables

Environment variables are used to configure the Helios container. The following environment variables are available:

| Name          | Value                                                                             | Required |
|---------------|-----------------------------------------------------------------------------------|----------|
| USER          | Name of the user                                                                  | X        |
| UID           | POSIX compliant uid for the user                                                  | X        |
| GID           | POSIX compliant gid for the user                                                  |          |
| PASSWORD      | Password set for the user                                                         |          |
| IDLE_TIME     | Trigger the idle hook after x time                                                |          |
| DESKTOP_FILES | Paths seperated by ":". For example, `/some/path/1/*.desktop:/some/*/2/*.desktop` |          |

> [!CAUTION]
> Desktop file scraping isn't supported in Alpine Linux.

> [!TIP]  
> The `GID` will match the `UID` if not specified.

> [!TIP]  
> The `UID` and `GID` are NOT the user that is launching and running the container. 
> Because of s6, the container always starts and runs as root. It then uses s6 to run the desktop using the specified 
> user using those environment variables. This is done to ensure that the desktop has the correct permissions and 
> ownership on things like the home directory and other files. This helps with things like Network Shares as well.

> [!CAUTION]
> Helios DOES NOT provide any authentication for connecting to the workstation. This means that anyone who can
> connect to the http endpoint can access the desktop as that user. For proper security, we recommend using a 
> reverse proxy with authentication in front of Helios. This can be done using Nginx, Traefik, or any other 
> reverse proxy that supports authentication.
> 
> Security is a very important part of any deployment and it isn't a one size fits all solution. Instead of shipping
> Helios with a specific authentication method, we leave it up to the user to implement their own security measures
> that best fit their deployment. This allows for more flexibility and customization in how Helios is used.

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
```

## Customizing Helios


### 📦 Unified Package Management

To streamline cross-distro package management, Helios uses a centralized `packages.yaml` system. This allows each logical package to be mapped to its appropriate name for each Linux distribution, while also enabling distros to inherit shared definitions from one or more package groups.

---

#### 🔧 Structure of `packages.yaml`

##### `packages` Section

Each item in the `packages` array defines a **single logical package**, and includes distro-specific keys for the corresponding package names:

```yaml
packages:
  - debian: mesa-va-drivers        # VA-API support for Debian
    rhel: mesa-va-drivers          # Same package name for RHEL
    alpine: mesa-va-gallium        # Different package name for Alpine

  - debian: libx11-6
    rhel: libX11
    alpine: libx11

  - debian: extra-debian-only-pkg
```

This format enables clean mapping between distros for the same logical dependency, and avoids repeating similar entries in multiple places.

##### `inherit` Section

This section defines which **groups of package mappings** each distro should inherit from.

```yaml
inherit:
  ubuntu:
    - common
    - debian
  alpine:
    - common
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

#### 📤 Package List Generation

A preprocessing step flattens the data into a list of distro-specific packages, combining:

1. All package mappings from the inherited groups
2. Any mappings explicitly defined for that distro

Each distro’s final list is saved as:

```
/tmp/lists/<distro>.list
```

For example, `/tmp/lists/ubuntu.list` will include packages from:
- The `common` group
- The `debian` group
- Any Ubuntu-specific entries (if present)

---

#### 🧱 Build Integration

These generated lists are used directly in the image build process. Example from [`alma-9/build/system.sh`](https://raw.githubusercontent.com/juno-fx/Helios/refs/heads/48-unify-package-list-clean/alma-9/build/system.sh):

```bash
dnf install -y --allowerasing --setopt=install_weak_deps=False --best \
  $(cat /tmp/lists/rhel.list) \
  fastfetch
```

This example installs the complete set of packages for a RHEL-based image (including inherited packages from `common`).

---

#### ✅ Benefits

- 🔄 **Cross-distro compatibility**: One source of truth for logical packages across platforms
- 🔧 **Easier maintenance**: Update a single YAML file instead of multiple build scripts
- ♻️ **Reusability**: Define shared groups (`common`, `debian`, etc.) and reuse across distros
- 🔍 **Transparency**: Final package lists are explicitly generated and easy to inspect

---

### 🏗️ Using `FROM`

Helios images can be used as a base in your own Dockerfiles with the `FROM` instruction.

For example, to build on top of the Ubuntu 24.04 Helios image:

```dockerfile
FROM helios:v0.0.0-noble

RUN apt-get update && \
    apt-get install -y htop
```

You can then push your custom image to a private registry and deploy it in Kasm-compatible environments.

---

#### ✅ Benefits

- 🚀 **Quick Start**: Leverage prebuilt, tested base images to speed up your container builds.
- 🔄 **Consistency**: Builds start from a known, reliable foundation, reducing surprises.
- 🔧 **Customizability**: Easily extend Helios images to fit your specific application or environment needs.
- 📦 **Compatibility**: Seamlessly integrate with Kasm and other container orchestration platforms.

---

### ⚙️ Event Hooks

Helios uses the [s6 overlay](https://github.com/just-containers/s6-overlay) init system from [just-containers](https://github.com/just-containers).  
This allows us to hook into the container boot sequence to run custom scripts and services. The design is heavily inspired by the excellent work from [Linuxserver IO](https://www.linuxserver.io/).

> [!TIP]  
> The init hook executes **before** the user environment is fully set up, but you have full access to environment variables and the filesystem.

---

#### 🛠️ Custom Services

Custom services are managed through the `/etc/helios/services.d` directory. You can add your own by either:

- Overriding `/etc/helios/services.d/custom.sh` in your Dockerfile  
- Mounting your scripts into the container

These services will run in the background as part of the container lifecycle.

---

#### 🏗️ Using `FROM`

You can extend Helios images by adding your custom init scripts and services in your Dockerfile:

```dockerfile
FROM helios:v0.0.0-noble

# Custom init script
COPY ./my-custom-init.sh /etc/helios/init.d/my-custom-init.sh

# Custom service
COPY ./my-custom-service.sh /etc/helios/services.d/custom.sh

# Custom idle script
COPY ./my-custom-idle.sh /etc/helios/idle.d/custom.sh
```

---

#### 🔌 Mounting Scripts Dynamically

Alternatively, mount scripts at runtime via Docker or Kubernetes volume mounts. This lets you add or update scripts without rebuilding the image — great for development and testing.

Example Docker run command:

```shell
docker run -d \
  --name my-helios-container \
  -v /path/to/my-custom-init.sh:/etc/helios/init.d/my-custom-init.sh \
  -v /path/to/my-custom-service.sh:/etc/helios/services.d/custom.sh \
  -v /path/to/my-custom-idle.sh:/etc/helios/idle.d/custom.sh \
  helios:v0.0.0-noble
```

Example Kubernetes ConfigMap and Deployment snippet to mount the scripts:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-helios-config
data:
  my-custom-idle.sh: |
    #!/bin/sh
    echo "Helios has hit the idle timeout!"
  
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
          - name: custom-idle
            mountPath: /etc/helios/idle.d/custom.sh
            subPath: my-custom-idle.sh
      volumes:
        - name: custom-scripts
          configMap:
            name: my-helios-config
        - name: custom-services
          configMap:
            name: my-helios-config
        - name: custom-idle
          configMap:
            name: my-helios-config
```

---

#### ✅ Benefits

- 🔄 **Flexible Initialization**: Run custom scripts and services at different points in the container lifecycle.  
- ⚡ **Extensibility**: Easily add or override functionality without modifying core images.  
- 🚧 **Rapid Development**: Test changes by mounting scripts without rebuilding images.  
- 🛠️ **Compatibility**: Leverages widely adopted `s6-overlay`, ensuring robust process supervision.  
- 🔍 **Transparency**: Clear, maintainable hook system inspired by best practices in container init systems.


---

## Contributing

Feel free to read our [CONTRIBUTING](CONTRIBUTING.md).

## Acknowledgements

Helios is built on the shoulders of giants. We would like to acknowledge the following projects and teams for inspiring us:

- [Kasm](https://www.kasmweb.com/kasmvnc) for providing the base VDI solution for our containerized desktops.
- [Linuxserver.io](https://www.linuxserver.io/) for their incredible work which heavily inspires our workflow.
- [just-containers](https://github.com/just-containers/) for the awesome s6 overlay init system.
