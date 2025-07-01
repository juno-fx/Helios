# Custom Build Hooks

Helios allows you to customize the build process by adding custom scripts that run at 
specific points during the image build. This is useful for tasks like installing additional 
software, modifying configurations, or running custom commands. The process of building a
system like this can be very complex with many moving parts, so we provide a simple way to
hook into that process for clean reproducible builds.

## Repository Layout

The repository is laid out as follows:

```
common
└── build <- Common build scripts
    └── system.sh <- Common custom system build script
<distro>
└── build <- Distro specific build scripts
    └── system.sh <- Distro specific custom system build script
```

!!! note

    It is worth noting that there are many other scripts in the `common/build` and 
    `<distro>/build` directories that are run during the build process. 99% of the 
    time, you will not need to ever modify these scripts as they are used to build 
    the base container image and the KasmVNC server. However, if you do need to
    modify them, you can do so. The `system.sh` scripts are the ones that are run
    after the KasmVNC server and custom X server have been built and installed,
    and are used to install the distro specific packages and dependencies that are
    needed to finalize the image.

### Build Order

The build order is very important so you know when a script will be run and what it will do.

1. `common/build/novnc.sh` is run to build the noVNC client. (This is standard across all distros)
2. `<distro>/build/kasm.sh` is run to install the distro specific packages and dependencies to build the KasmVNC server and the custom X server.
3. `common/build/turbo.sh` is run to build the custom libjpeg-turbo required by KasmVNC server. (This is standard across all distros)
4. `common/build/kasm.sh` is run to build the KasmVNC server. (This is standard across all distros)
5. `<distro>/build/xorg.sh` is run to build the X server. Depending on the distro, it will change which X version is built. This is the case for RHEL distros for example.
6. `<distro>/build/kclient.sh` is run to install Node for the distro. This changes per distro as some distros have different package managers or versions of Node available.
7. `common/build/kclient.sh` is run to build the kclient client. (This is standard across all distros)
    
    !!! note

         We do apply a helios.patch to the kclient that removes the fileserver functionality as well as automatically enable audio by default.

    !!! warning

         The kclient is patched on RHEL distros to disable the webrtc functionality as it is not supported on RHEL distros.

8. `common/build/package.sh` is run in the build stage to generate the rootfs containing, kclient, KasmVNC server, custom X server, and noVNC client.
9. `<distro>/build/system.sh` is run to install the distro specific packages and dependencies.
10. `common/build/system.sh` is run to install the packages and dependencies common to all distros to finalize the deliverable image.
11. We then copy the packaged rootfs from the build stage to a fresh flattened image which "installs" Kasm
12. `common/root` is copied into the image to provide the common rootfs files.
13. `<distro>/root` is then copied into a fresh image with all distro specific files and configurations.
