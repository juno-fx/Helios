# Custom Wallpaper

In this example, we will add a custom wallpaper to the Helios root filesystem and build it into Alpine, Debian, and RHEL based images.

---

# Update Default Wallpaper

Download your favorite wallpaper and replace the `common/root/usr/share/backgrounds/background.jpg` file with your custom image. This file will be used as the default wallpaper for all distros.

# Build the Image
To build the image with your custom wallpaper included, you can run the following command:

```shell
make alpine-3
```

This command will build the Alpine 3 image with your custom wallpaper. You can replace `alpine-3` with any other distro supported by Helios to build those images with your custom wallpaper as well.