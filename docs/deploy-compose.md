# Docker Compose

As with the docker run example, Helios can also be deployed using Docker Compose, which allows for more complex configurations and easier management of multiple containers.

## GPU Support

Helios is designed to support GPU acceleration. An example of this is to mount and access an NVIDIA GPU using the `nvidia-docker` runtime. Ensure you have the NVIDIA Container Toolkit installed to use this feature.

An example command to run Helios with GPU support using Docker Compose is:

Create a `docker-compose.yaml` file with the following content:

!!! note "Launch Configuration"

    Be sure to also include all required environment variables as is specified in [Launch Configuration](deploy-usage.md).

```yaml
services:
  helios:
    image: helios:v0.0.0-noble
    container_name: my-helios-container
    ports:
      - "3000:3000"
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - capabilities: [gpu]
```

Now, you can launch the container with GPU support:

```bash
docker compose up -d
```

## DCV Remote Protocol

Helios supports [Amazon DCV (NICE DCV)](deploy-usage.md#dcv) as an alternative to the default Selkies protocol.
Set `REMOTE_PROTOCOL=dcv` to enable DCV mode.

### Web Browser Access (DCV)

The DCV web client is served on port 3000, same as Selkies:

```yaml
services:
  helios:
    image: helios:v0.0.0-noble
    container_name: my-helios-dcv
    environment:
      - USER=myuser
      - UID=1000
      - GID=1000
      - REMOTE_PROTOCOL=dcv
    ports:
      - "3000:3000"
    restart: unless-stopped
```

### Native Client Access (DCV)

For the [DCV native client](https://docs.aws.amazon.com/dcv/latest/adminguide/client.html),
set `PASSWORD` and expose port 8443 for TCP and QUIC (UDP):

```yaml
services:
  helios:
    image: helios:v0.0.0-noble
    container_name: my-helios-dcv
    environment:
      - USER=myuser
      - UID=1000
      - GID=1000
      - REMOTE_PROTOCOL=dcv
      - PASSWORD=mypassword
    ports:
      - "3000:3000"
      - "8443:8443"
      - "8443:8443/udp"
    restart: unless-stopped
```

!!! info "DCV Licensing"

    See [DCV Licensing](deploy-usage.md#dcv) in the Launch Configuration for details on
    EC2 auto-license, demo mode, and BYOL with `DCV_LICENSE_FILE`.

## Custom Event Scripts

In this example, we will mount a custom set of event scripts using docker compose instead of baking them into the image. This allows for easier updates and modifications without needing to rebuild the image.

## Create a Compose File

Create a `compose.yaml` file with the following content:

!!! note "Launch Configuration"

    Be sure to also include all required environment variables as is specified in [Launch Configuration](deploy-usage.md).

```yaml
services:
  helios:
    image: helios:v0.0.0-noble
    container_name: my-helios-container
    volumes:
      - /path/to/my-custom-init.sh:/etc/helios/init.d/my-custom-init.sh
      - /path/to/my-custom-service.sh:/etc/helios/services.d/custom.sh
      - /path/to/my-custom-idle.sh:/etc/helios/idle.d/custom.sh
    restart: unless-stopped
```

Launch the container with the custom scripts mounted:

```bash
docker compose up -d
```