# Root Filesystem

Helios provides rootfs modifications for each distro as well as common modifications that apply to all distros.

## Structure
The repository is laid out as follows:

```
common
└── root <- Modified rootfs for all distros
<distro>
└── root <- Distro specific rootfs
```

## Common Rootfs

The `common/root` directory contains files that are shared across all distros. This includes configuration files, 
scripts, and other resources that are common to the Helios environment. This is where we normally place shared 
themes and other common files that should be present in all distros. 

## Distro Specific Rootfs

Each distro has its own `root` directory that contains files specific to that distro. This allows for customization
of the root filesystem for each distribution while still maintaining a common base. For example, we may want to modify
repository sources for a specific distro or disable snap preferences in only Ubuntu distros.