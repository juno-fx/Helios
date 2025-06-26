
# Guidelines

Contributions to Helios are welcome! We just ask that you evaluate what you actually need to adjust. This repo is not
meant to provide a fully built desktop with all the bells and whistles. It is meant to provide a base image
that others can build on top of. That means most changes to Helios should be geared towards adding new distros,
optimizing the build process, or upgrading part of the Helios stack. If you have a specific use case that requires
a change to Helios, please open an issue or a pull request with a detailed explanation of the change and why it is
necessary. 

There are a few rules.

1. NOTHING distro specific should ever be added to the Dockerfile.
    - The only exception is the Ubuntu stage which generates the snakeoil certificates which are then copied into the common rootfs. This is used to satisfy the requirement for KasmVNC to launch on RHEL based distros.
2. All builds MUST be run through the Dockerfile at the root of the repository. This ensures that the build process is consistent across all distros and all versions are uniform.
3. The Dockerfile is heavily monitored for changes and any proposed changes will require a very detailed explanation of why the change is necessary and how it will affect the build process. As of right now, there is no reason to modify the Dockerfile as it provides hooks in the rest of the repo to do anything you want.
