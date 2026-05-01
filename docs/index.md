# Welcome

<span class="theme-aware-image">
  <img src="assets/logos/helios/helios-light.png" class="light-only" alt="Helios Logo">
  <img src="assets/logos/helios/helios-dark.png" class="dark-only" alt="Helios Logo">
</span>

Helios is Juno's containerized workstation product. It packages a full desktop environment (applications, GPU drivers, and user configuration) into a container image that deploys in 60 seconds on any Orion cluster.

Instead of provisioning dedicated workstations per user, Helios lets administrators define workstation images once and deliver them on demand. Users get a consistent, GPU-accelerated desktop. Administrators get one image to maintain instead of dozens of physical machines.

---

## What Helios Does

- **Containerized desktop delivery** — Full Linux desktop environments packaged as OCI-compliant container images
- **60-second launch** — A workstation that previously took hours to provision is ready in under a minute
- **GPU-accelerated** — NVIDIA, AMD, and Intel GPU pass-through for DCC tools, ML frameworks, and scientific software
- **Orion-native** — Runs directly on Juno Orion clusters; inherits Orion's scheduling, resource allocation, and GPU management
- **Standalone-compatible** — Runs as a standalone container outside Orion for development and testing
- **Extensible base images** — Extend official Helios images with your own software, licenses, and configuration using standard Dockerfile patterns
- **Community-maintained** — Official images are open source; contributions are welcome

---

## Who Uses Helios

**VFX artists and animators** — Launch a DCC workstation (Houdini, Nuke, Blender) on shared GPU infrastructure without touching a physical machine.

**Researchers and scientists** — Get a reproducible compute environment with pre-installed libraries and GPU access, without IT provisioning delays.

**Developers** — Spin up isolated, GPU-enabled development environments that match production exactly.

**System administrators** — Define workstation standards once. Eliminate configuration drift, license sprawl, and per-seat provisioning overhead.

---

## Orion Integration

Helios workstations run as scheduled workloads on Orion. This means:

- Workstations are allocated compute resources dynamically; GPUs aren't reserved when no one is using them
- Administrators manage workstation images alongside other workload types in the Orion admin console
- Terra marketplace integration allows users to launch Helios workstations self-service, without an IT ticket
- A Helios workstation shares the same GPU pool as rendering jobs and ML training runs; utilization applies across the full cluster

---

## Get Started

- [Launch Configuration](deploy-usage/) — deploy Helios on your Orion cluster
- [Building Workstations](getting-started/) — create and customize workstation images
- [Contributing](contributing/) — add images or improve the base
- [Orion Documentation](https://juno-fx.github.io/Orion-Documentation/) — the compute plane Helios runs on
- [Terra Plugins](https://juno-fx.github.io/Terra-Official-Plugins/) — deploy Helios via the Terra marketplace

---

*Questions? Visit [juno-innovations.com](https://juno-innovations.com) or reach out at [sales@juno-innovations.com](mailto:sales@juno-innovations.com).*
