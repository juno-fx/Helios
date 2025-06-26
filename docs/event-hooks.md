# Custom Event Hooks

Helios allows you to hook into different events during the runtime of the container. The following
hooks are available:

- **`init`**: This is run before everything else in the container. It is useful for setting up system files at runtime before user creation. You can also use this hook to initialize things like AD federation via something like SSSD.
- **`services`**: This is run after the user is created and the system is initialized. It is useful for starting custom services that need to run in the container.
- **`idle`**: This is run when the container has been idle. Idle is defined by `xssstate` being idle for a certain amount of time. This tracks mouse and keyboard activity. You can use this hook to run custom scripts when the container is idle, such as auto shutdown.

## Installing Event Hooks

You have a few options for installing event hooks. You can mount them in to the container at runtime, or you can include them in the rootfs during the build process.
Juno for example, mounts a custom `idle` script into the container at runtime to auto shutdown the container after a certain amount of time being idle. This is done 
by mounting the script into the container at `/etc/helios/idle.d/custom.sh`.

We have seen other users include a custom `init` script in the rootfs during the build process which will trigger a SSSD setup for AD federation. This is done by adding a script to the `common/root/etc/helios/init.d/` directory.

## init.d Directory

The `init.d` directory is where you can place your custom scripts that will be run during the `init` event. You can create a script in this directory and it will be executed when the container starts. The script should be executable and can contain any commands you need to run at startup.

!!! note

    If the script is not executable, Helios will try to make it executable. If it fails, it will then try to pass the script directly to bash to execute it. If this all fails, it will log an error and skip the script. This will NOT stop the container from starting, but it will log an error message.

## services.d Directory

The `services.d` directory is a little different from the `init.d` directory. Because of how `s6-overlay` works, we can't dynamically launch services on demand. Because of this, we execute the existing `custom.sh` script in the `services.d` directory. This script should contain the commands to start your custom services. It is executed after the user is created and the system is initialized.

!!! note

    It is worth noting that this does mean you are responsible for monitoring and restarting your own services if they fail.

## idle.d Directory

Like the `services.d` directory, the `idle.d` directory is executed by the `custom.sh` script. This script should contain the commands to run when the container is idle. The script is executed when the container has been idle for a certain amount of time, as defined by `xssstate`. You can use this hook to run custom scripts when the container is idle, such as auto shutdown or other maintenance tasks.
