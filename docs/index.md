# Welcome

<span class="theme-aware-image">
  <img src="assets/logos/helios/helios-light.png" class="light-only" alt="Helios Logo">
  <img src="assets/logos/helios/helios-dark.png" class="dark-only" alt="Helios Logo">
</span>

 
Helios is Juno's containerized workstation. It packages a full Linux desktop (applications, GPU access, and user configuration) into an image. Download it and run it standalone, or launch it in about 60 seconds on an Orion cluster. Orion is customer-hosted, so every workstation runs on your hardware.
 
Instead of provisioning a physical workstation per user, administrators define a workstation image once and deliver it on demand. Users get a consistent desktop in a browser. Administrators maintain one image instead of dozens of machines.
---

## What Helios Does

- **A Linux image you can download.** Helios is a Linux desktop image. Pull it from the [Helios repository](https://github.com/juno-fx/Helios) and run it standalone, with or without Orion.
- **About 60 seconds to launch.** On Orion, a workstation that used to take hours to provision is ready in about a minute.
- **GPU access by slicing.** Orion slices GPUs, so several Helios workstations can share one card. Resources return to the pool when a session ends.
- **Browser-based.** Connect from a browser. No client install, no VPN client, no IT ticket via [Juno Orion](https://docs.juno-innovations.com/Orion-Documentation/latest/)
- **Extensible base images.** Add your own software, licenses, and configuration with standard Dockerfile patterns.
- **Open source images.** Official Helios images are open source, and contributions are welcome.
---

## Who Uses Helios

**VFX artists and animators** launch a workstation with tools like Houdini, Nuke, and Blender on shared GPU infrastructure, without touching a physical machine.
 
**Researchers and scientists** get a reproducible environment with pre-installed libraries and GPU access, without waiting on IT.
 
**Developers** spin up isolated, GPU-enabled development environments that match production.
 
**System administrators** define workstation standards once, which ends configuration drift, license sprawl, and per-seat provisioning.
---

## How Helios runs on Orion
 
Helios workstations are scheduled workloads on Orion, so:
 
- Compute is allocated on demand. GPUs are not held for workstations nobody is using.
- Administrators manage workstation images in Orion Admin, next to every other workload type.
- Users launch workstations themselves from an Orion Workspace, without an IT ticket.
- Workstations, render jobs, and ML training runs draw from the same GPU pool.
---

## Get started
 
- [Launch Configuration](https://docs.juno-innovations.com/Helios/deploy-usage/): deploy Helios on your Orion cluster
- [Building Workstations](https://docs.juno-innovations.com/Helios/getting-started/): create and customize workstation images
- [Contributing](https://docs.juno-innovations.com/Helios/contributing/): add images or improve the base
- [Orion Documentation](https://docs.juno-innovations.com/Orion-Documentation/latest/): the unified compute plane Helios runs on
- [Orion Apps (formerly Terra)](https://docs.juno-innovations.com/Terra-Official-Plugins/): launch Helios from the app catalog
Questions? Email [sales@juno-innovations.com](mailto:sales@juno-innovations.com).
---

*Questions? Visit [juno-innovations.com](https://juno-innovations.com) or reach out at [sales@juno-innovations.com](mailto:sales@juno-innovations.com).*
