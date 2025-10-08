# Kubernetes

Helios also supports deployment using Kubernetes, which allows for more complex configurations and easier management of multiple containers. This is particularly useful for production environments where scalability and reliability are key.

## GPU Support

Helios is designed to support GPU acceleration in Kubernetes. An example of this is to mount and access an NVIDIA GPU using the `Nvidia GPU Operator`. Ensure you have the NVIDIA Container Toolkit installed and configured in your Kubernetes cluster to use this feature.

An example command to run Helios with GPU support in Kubernetes is:

!!! note "Launch Configuration"

    Be sure to also include all required environment variables as is specified in [Launch Configuration](deploy-usage.md).

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-helios-deployment
spec:
    replicas: 1
    selector:
        matchLabels:
          app: my-helios-app
    template:
        metadata:
            labels:
                app: my-helios-app
        spec:
            containers:
              - name: helios-container
                image: helios:v0.0.0-noble
                ports:
                - containerPort: 3000
                resources:
                    limits:
                        nvidia.com/gpu: "1" # Request one GPU
```

## Custom Event Scripts

In this example, we will mount a custom set of event scripts using Kubernetes instead of baking them into the image. This allows for easier updates and modifications without needing to rebuild the image.

### Create a Kubernetes Deployment

Create the following deployment with the following content:

!!! note "Launch Configuration"

    Be sure to also include all required environment variables as is specified in [Launch Configuration](deploy-usage.md).

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-helios-config
data:
  my-custom-idle.sh: |
    #!/bin/sh
    echo "Helios has hit the idle timeout!"
  
  my-custom-init.sh: |
    #!/bin/sh
    echo "Hello from my custom init script!"
  
  my-custom-service.sh: |
    #!/bin/bash

    set -e

    echo
    echo "Helios Custom Service Initialization"
    echo
    /path/to/my/custom/script.sh
    /path/to/my/other/custom/script.sh
    sleep infinity
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-helios-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-helios-app
  template:
    metadata:
      labels:
        app: my-helios-app
    spec:
      containers:
      - name: helios-container
        image: helios:v0.0.0-noble
        ports:
          - containerPort: 3000
        volumeMounts:
          - name: custom-scripts
            mountPath: /etc/helios/init.d/my-custom-init.sh
            subPath: my-custom-init.sh
          - name: custom-services
            mountPath: /etc/helios/services.d/custom.sh
            subPath: my-custom-service.sh
          - name: custom-idle
            mountPath: /etc/helios/idle.d/custom.sh
            subPath: my-custom-idle.sh
      volumes:
        - name: custom-scripts
          configMap:
            name: my-helios-config
            defaultMode: 0777
        - name: custom-services
          configMap:
            name: my-helios-config
            defaultMode: 0777
        - name: custom-idle
          configMap:
            name: my-helios-config
            defaultMode: 0777
```
