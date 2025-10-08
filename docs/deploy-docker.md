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
