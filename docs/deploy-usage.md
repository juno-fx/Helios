# Launch Configuration

## Environment Variables

Environment variables are used to configure the Helios container. The following environment variables are available:

| Name              | Value                                                                                                                                                                                        | Required |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| USER              | Name of the user                                                                                                                                                                             | X        |
| UID               | POSIX compliant uid for the user                                                                                                                                                             | X        |
| GID               | POSIX compliant gid for the user                                                                                                                                                             |          |
| PASSWORD          | Password set for the user. Required for DCV native client direct-connect (port 8443)                                                                                                         |          |
| IDLE_TIME         | Trigger the idle hook after x minutes (only required when the [auto shutdown plugin](https://github.com/juno-fx/Terra-Official-Plugins/tree/main/plugins/helios-auto-shutdown) is installed) |          |
| DISABLE_VGL       | Disable VirtualGL Wrapper around the entire desktop session. You will need to manually run applications that require it via `vglrun`                                                         |          |
| DESKTOP_FILES     | Paths separated by `:`. For example, `/some/path/1/*.desktop:/some/*/2/*.desktop`                                                                                                            |          |
| PREFIX            | Prefix for URL for use behind a reverse proxy                                                                                                                                                |          |
| SELKIES_FRAMERATE | Set framerate as a range (e.g., `15-60`) or a fixed value (e.g., `30`)                                                                                                                       |          |
| SUDO              | Grant `SUDO` to the user on the container                                                                                                                                                    |          |
| REMOTE_PROTOCOL   | Remote desktop protocol: `selkies` (default) or `dcv`                                                                                                                                        |          |
| DCV_LICENSE_FILE  | Path to a DCV license file for non-EC2 usage. Falls back to auto-license on EC2 or 30-day demo otherwise.                                                                                   |          |
| DCV_DIRECT_PORT   | Port for the DCV native client direct-connect endpoint. Default `8443`. Requires `PASSWORD` to be set.                                                                                       |          |


When using the Orion Platform, you can configure them in the [Templates](https://juno-fx.github.io/Orion-Documentation/genesis/workstations/)
User-related settings are already configured automatically by the platform. The Templates are there to adjust settings such as your framerate.

When using `REMOTE_PROTOCOL=selkies` (the default), many of the environment variables provided by the upstream Selkies project will be respected.
You can find official Selkies documentation here: https://selkies-project.github.io/selkies/usage/#command-line-options-and-environment-variables

!!! info 

    The `GID` will match the `UID` if not specified.

!!! info "UID and GID"

    The `UID` and `GID` are NOT the user that is launching and running the container. 
    Because of s6, the container always starts and runs as root. It then uses s6 to run the desktop using the specified 
    user using those environment variables. This is done to ensure that the desktop has the correct permissions and 
    ownership on things like the home directory and other files. This helps with things like Network Shares as well.


!!! danger "Authentication"

    When using `REMOTE_PROTOCOL=selkies`, Helios DOES NOT provide any authentication for the web endpoint. This means that anyone who can
    connect to the http endpoint can access the desktop as that user. For proper security, we recommend using a 
    reverse proxy with authentication in front of Helios. This can be done using Nginx, Traefik, or any other 
    reverse proxy that supports authentication.

    When using `REMOTE_PROTOCOL=dcv`, the web endpoint (port 3000) is also unauthenticated. However, setting `PASSWORD`
    enables a separate password-authenticated endpoint on port 8443 for native DCV clients. The web endpoint remains
    open — use a reverse proxy for access control.

    Security is a very important part of any deployment and it isn't a one size fits all solution. Instead of shipping
    Helios with a specific authentication method, we leave it up to the user to implement their own security measures
    that best fit their deployment. This allows for more flexibility and customization in how Helios is used.

    When using the [Orion Platform](https://juno-fx.github.io/Orion-Documentation/), Authentication and authorization is handled by the product, ensuring the security of your deployment.

## Endpoints

Helios provides the following endpoints for accessing the desktop:

### Selkies mode (`REMOTE_PROTOCOL=selkies`)

| Endpoint              | Description                   |
|-----------------------|-------------------------------|
| `{PREFIX}/`           | Web-based desktop (port 3000) |

### DCV mode (`REMOTE_PROTOCOL=dcv`)

| Endpoint                        | Description                                          |
|---------------------------------|------------------------------------------------------|
| `{PREFIX}/`                     | Web-based desktop via browser (port 3000, no auth)   |
| `<host>:<DCV_DIRECT_PORT>`      | Native DCV client direct-connect (port 8443, PAM auth via `PASSWORD`) |

The DCV direct-connect endpoint uses both TCP and QUIC (UDP) for lower-latency streaming.
Connect using the [DCV native client](https://docs.aws.amazon.com/dcv/latest/adminguide/client.html)
with the address `<host>:<DCV_DIRECT_PORT>` and username `<USER>`.

## Ports

Helios exposes the following ports:

| Port | Protocol | Description                    |
|------|----------|--------------------------------|
| 3000 | TCP      | HTTPS Desktop (Selkies or DCV) |
| 8443 | TCP+UDP  | DCV native client direct-connect (when `REMOTE_PROTOCOL=dcv` and `PASSWORD` is set) |

## Remote Protocols

### Selkies (default)

Selkies is a WebRTC-based remote desktop protocol. It provides a web-based client that works
in any modern browser without additional software. Selkies is the default and recommended
protocol for browser-based access.

### DCV

[Amazon DCV (NICE DCV)](https://aws.amazon.com/hpc/dcv/) is an alternative remote desktop
protocol that supports both web browser and native client access.

DCV key characteristics:

- **Console sessions only** — DCV connects to the same Xvfb display as Selkies. Both
  protocols show the same desktop.
- **Web access** — Served on port 3000 behind nginx, same as Selkies. The web endpoint
  is unauthenticated.
- **Native client** — A separate dcvserver instance on port 8443 provides
  password-authenticated access for the [DCV native client](https://docs.aws.amazon.com/dcv/latest/adminguide/client.html).
  Requires `PASSWORD` to be set.
- **iframe embedding** — DCV web client supports iframe embedding from any origin (CORS
  headers are set, `X-Frame-Options` is stripped).
- **No GPU sharing** — DCV-GL is installed but the console session does not use it.
  GPU acceleration is handled by VirtualGL (same as Selkies).

!!! info "DCV Licensing"

    DCV requires a license. Helios handles licensing automatically:
    
    - **On EC2** uses the free built-in EC2 license.
    - **Without a license** starts a 30-day demo license on first run.
    - **BYOL** set `DCV_LICENSE_FILE` to the path of your license file.
    
    The demo license is generated at container start via the DCV package postinst
    script. This ensures each container gets its own valid license state.

!!! warning "EC2 IMDS Hop Limit"

    On EC2, DCV fetches its free license from the Instance Metadata Service
    (IMDS) at `169.254.169.254`. Containers in a separate network namespace
    (bridge/overlay) add one extra hop. The default IMDS hop limit of `1`
    drops their requests, causing DCV license checkout to fail.

    **Host networking** (`--network host`) — no extra hop. Default hop limit
    works. No change needed.

    - **Bridge/overlay/EKS/Fargate** — IMDS needs hop limit ≥ 2:

    - **Karpenter** — add to `EC2NodeClass.spec.metadataOptions`:
      ```yaml
      httpPutResponseHopLimit: 2
      ```
    - **EKS managed node groups / launch templates** — set
      `MetadataOptions.HttpPutResponseHopLimit` to `2`.
    - **Plain Docker / ECS EC2** — apply to the instance:
      ```bash
      aws ec2 modify-instance-metadata-options \
        --instance-id <id> \
        --http-put-response-hop-limit 2
      ```

!!! info "DCV Audio"

    DCV uses the same PulseAudio null-sink setup as Selkies. Desktop audio is captured
    from the output monitor and streamed to the client. Microphone input arrives via
    the DCV agent's virtual microphone (`AWS-Virtual-Microphone`).
