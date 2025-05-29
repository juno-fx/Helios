# Helios
Optimized Kasm Desktops for general use

## Features

- **Lightweight**: Minimal resource usage for efficient performance.
- **WebRTC Support**: Seamless audio and video streaming capabilities. (Non-RHEL distros)
- **Multi-Monitor Support**: Enhanced productivity with multiple displays.

## Distros

### Ubuntu 22.04 (Jammy)

- Size: 1.48 GB
- X Server: 21.1.4 (Custom)

### Ubuntu 24.04 (Noble)

- Size: 1.48 GB
- X Server: 21.1.4 (Custom)

### Kali Linux (Rolling Release)

> [!NOTE]  
> We don't install any default Kali tools in this image. Please follow the instructions in the [Kali Linux Docker Image documentation](https://www.kali.org/docs/containers/official-kalilinux-docker-images/) to install them.

- Size: 1.74 GB (This does not include the Kali tools which make the image much larger)
- X Server: 21.1.4 (Custom)

### Rocky Linux (9)

> [!DANGER]  
> Currently WebRTC is not supported on Rocky Linux due to upstream limitations with Kasm. This may change in the future.

- Size: 1.82 GB
- X Server: 1.20.14 (Custom)


### Alma Linux (9)

> [!DANGER]  
> Currently WebRTC is not supported on Alma Linux due to upstream limitations with Kasm. This may change in the future.

- Size: 1.61 GB 
- X Server: 1.20.14 (Custom)
