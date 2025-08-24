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
