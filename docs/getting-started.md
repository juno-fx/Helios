# Getting Started

## Prerequisites

To get started with Helios, you need to have the following prerequisites:

- **Docker**: Docker is used to build the workstations. Install Docker from the [Docker website](https://docs.docker.com/get-docker/).
- **Devbox**: Devbox is used to manage development environments. You can install it from the [Devbox website](https://www.jetify.com/docs/devbox/installing_devbox/).
- **Git**: Ensure you have Git installed to clone the repository. You can download it from the [Git website](https://git-scm.com/downloads).

## Repository Setup

To set up your Helios repository, follow these steps:

1. **Clone the Helios Repository**: This repository contains the tooling needed to build and modify Helios.

    <!-- termynal -->
    
    ```shell
    $ git clone https://github.com/juno-fx/Helios
    $ cd Helios
    $ git checkout 999-my-branch
    ```

2. **Activate Devbox**: Juno ships a full Devbox environment to help you get started quickly. Activate it by running:

    <!-- termynal -->
    
    ```shell
    $ devbox shell
    Starting a devbox shell...
    Requirement already satisfied: uv in ./.venv/lib/python3.12/site-packages (0.7.9)
    
    [notice] A new release of pip is available: 24.3.1 -> 25.1.1
    [notice] To update, run: pip install --upgrade pip
    Audited 4 packages in 1ms
    ```

3. **Launch Basic Workstation**: Juno provides a `Makefile` target that is pre-configured for each Helios distro. You can launch the basic workstation by running:

    <!-- termynal -->
    
    ```shell
    $ make alpine-3
    ```



## Helios Structure

The repository is laid out as follows.

```
common
├── build <- Common build scripts for all distros
└── root <- Modified rootfs for all distros
<distro>
├── build <- Distro specific build scripts
└── root <- Distro specific rootfs
packages.yaml <- Package definitions for the Unified Package Management System
```

