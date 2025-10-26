# Launch Configuration

## Environment Variables

Environment variables are used to configure the Helios container. The following environment variables are available:

| Name              | Value                                                                                                                                    | Required |
|-------------------|------------------------------------------------------------------------------------------------------------------------------------------|----------|
| USER              | Name of the user                                                                                                                         | X        |
| UID               | POSIX compliant uid for the user                                                                                                         | X        |
| GID               | POSIX compliant gid for the user                                                                                                         |          |
| PASSWORD          | Password set for the user                                                                                                                |          |
| IDLE_TIME         | Trigger the idle hook after x time                                                                                                       |          |
| DISABLE_VGL       | Disable VirtualGL Wrapper around the entire desktop session. You will need to manually run applications that require it via `vglrun`     |          |
| DESKTOP_FILES     | Paths separated by `:`. For example, `/some/path/1/*.desktop:/some/*/2/*.desktop`                                                        |          |
| PREFIX            | Prefix for URL for use behind a reverse proxy                                                                                            |          |
| SELKIES_FRAMERATE | Set framerate as a range (e.g., `15-60`) or a fixed value (e.g., `30`)                                                                   |          |


When using the Orion Platform, you can configure them in the [Templates](https://juno-fx.github.io/Orion-Documentation/genesis/workstations/)
User-related settings are already configured automatically by the platform. The Templates are there to adjust settings such as your framerate.

As we rely on Selkies, many of the environment variables provided by the upstream will be respected.
You can find official Selkies documentation here: https://selkies-project.github.io/selkies/usage/#command-line-options-and-environment-variables

!!! info 

    The `GID` will match the `UID` if not specified.

!!! info "UID and GID"

    The `UID` and `GID` are NOT the user that is launching and running the container. 
    Because of s6, the container always starts and runs as root. It then uses s6 to run the desktop using the specified 
    user using those environment variables. This is done to ensure that the desktop has the correct permissions and 
    ownership on things like the home directory and other files. This helps with things like Network Shares as well.


!!! danger "Authentication"

    Helios DOES NOT provide any authentication for connecting to the workstation. This means that anyone who can
    connect to the http endpoint can access the desktop as that user. For proper security, we recommend using a 
    reverse proxy with authentication in front of Helios. This can be done using Nginx, Traefik, or any other 
    reverse proxy that supports authentication.

    Security is a very important part of any deployment and it isn't a one size fits all solution. Instead of shipping
    Helios with a specific authentication method, we leave it up to the user to implement their own security measures
    that best fit their deployment. This allows for more flexibility and customization in how Helios is used.

    When using the [Orion Platform](https://juno-fx.github.io/Orion-Documentation/), Authentication and authorization is handled by the product, ensuring the security of your deployment.

## Endpoints

Helios provides 1 endpoint for accessing the desktop:

| Endpoint              | Description                   |
|-----------------------|-------------------------------|
| `{PREFIX}/`           | The main interactive endpoint |


## Ports

Helios exposes the following ports:

| Port | Description        |
|------|--------------------|
| 3000 | HTTPS Desktop Port |
