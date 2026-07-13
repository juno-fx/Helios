# Docker Run

Helios can be deployed using Docker Run, allowing you to run the Helios container quickly for testing.

## GPU Support

Helios is designed to support GPU acceleration. An example of this is to mount and access an NVIDIA GPU using the `nvidia-docker` runtime. 
Ensure you have the NVIDIA Container Toolkit installed to use this feature.

An example command to run Helios with GPU support is:

!!! note "Launch Configuration"

    Be sure to also include all required environment variables as is specified in [Launch Configuration](deploy-usage.md).

```bash
docker run -d \
  --gpus all \
  --name my-helios-container \
  -p 3000:3000 \
  helios:v0.0.0-noble
```

## DCV Remote Protocol

Helios supports [Amazon DCV (NICE DCV)](deploy-usage.md#dcv) as an alternative to the default Selkies protocol.
Set `REMOTE_PROTOCOL=dcv` to enable DCV mode.

### Web Browser Access (DCV)

The DCV web client is served on port 3000, same as Selkies. No additional ports needed:

```bash
docker run -d \
  --name my-helios-dcv \
  -e USER=myuser \
  -e UID=1000 \
  -e GID=1000 \
  -e REMOTE_PROTOCOL=dcv \
  -p 3000:3000 \
  helios:v0.0.0-noble
```

### Native Client Access (DCV)

For the [DCV native client](https://docs.aws.amazon.com/dcv/latest/adminguide/client.html),
set `PASSWORD` and expose port 8443 for TCP and QUIC (UDP):

```bash
docker run -d \
  --name my-helios-dcv \
  -e USER=myuser \
  -e UID=1000 \
  -e GID=1000 \
  -e REMOTE_PROTOCOL=dcv \
  -e PASSWORD=mypassword \
  -p 3000:3000 \
  -p 8443:8443 \
  -p 8443:8443/udp \
  helios:v0.0.0-noble
```

Connect using the native client with address `<host>:8443` and username `myuser`.

!!! info "DCV Licensing"

    See [DCV Licensing](deploy-usage.md#dcv) in the Launch Configuration for details on
    EC2 auto-license, demo mode, and BYOL with `DCV_LICENSE_FILE`.

## Custom Event Scripts

In this example, we will mount a custom set of event scripts using Docker Run instead of baking them into the image. This allows for easier updates and modifications without needing to rebuild the image.

## Run the Container with Custom Scripts

Run the Docker container with the custom scripts mounted. You can use the following command:

!!! note "Launch Configuration"

    Be sure to also include all required environment variables as is specified in [Launch Configuration](deploy-usage.md).

```bash
docker run -d \
  --name my-helios-container \
  -v /path/to/my-custom-init.sh:/etc/helios/init.d/my-custom-init.sh \
  -v /path/to/my-custom-service.sh:/etc/helios/services.d/custom.sh \
  -v /path/to/my-custom-idle.sh:/etc/helios/idle.d/custom.sh \
  -p 3000:3000 \
  helios:v0.0.0-noble
```
