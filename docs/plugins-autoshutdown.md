# Auto shutdown plugin

Juno supplies an official [Terra](https://juno-fx.github.io/Orion-Documentation/latest/terra/intro/) plugin for automatically shutting down idle workstations after a configurable amount of time.

## Install the plugin

The [plugin](https://github.com/juno-fx/Terra-Official-Plugins/tree/main/plugins/helios-auto-shutdown) can be installed from the official Terra repository. The plugin itself requires no configuration other than which project to enable it in.

![shutdown plugin image](./assets/autoshutdown.png)

## Setup the workload

In order for the workstations to shutdown we need to configure two settings on the Helios workload.

### IDLE_TIME environment variable

On the Helios workload configuration screen you are given the option to add `env variables`. Add one with the name `IDLE_TIME` configured to the amount of **minutes** you would like to wait before an idle workstation is shutdown. For example set this to `60` to shutdown after an hour.

![environment setup](./assets/shutdown_env.png)

### Enable API access within the workstation

In order for the workstation to be gracefully shutdown we need to allow the workstation to access the shutdown API endpoint. This is handled automatically and securely, all you need to do is set the setting `enableAPI` to `True` in the workload configuration window.

![enableAPI setting](./assets/shutdown-api.png)

Thats it! Your idle workstations will now automatically shutdown as per your configured time.