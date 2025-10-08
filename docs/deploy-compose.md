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