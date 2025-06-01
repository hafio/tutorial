# Download & Installation

Refer to [MiniKube Getting Started](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download)

Download executable from above link or follow download+installation instructions from above link.

Install (double-click .exe for Windows).

Launch terminal.

`minikube` should be available, otherwise follow instructions on how to add to environment variable `PATH` from above link.

# Starting `minikube`

To start in default settings `minikube start`
> - 1 worker node
> - cluster name = minikube
> - namespace = default

Otherwise, consider using `minikube start --nodes [nodes] -p [name]` to start a new cluster
> - `--nodes` for number of worker nodes
> - `-p` for cluster name
> - `--memory` for RAM size in MB (default 2048)
> - `--cpus` for # of CPUs (default 2)

`minikube` should automatically be able to select the right virtualization technology (e.g. docker, virtual box, etc.)

output:
```
PS C:\Users\hamly\OneDrive\Geek\bookstack> minikube start --nodes 10 -p docker-mk
✨  Automatically selected the docker driver. Other choices: virtualbox, ssh Build 26100.2161
📌  Using Docker Desktop driver with root privileges
👍  Starting "docker-mk" primary control-plane node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔗  Configuring CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass

👍  Starting "docker-mk-m02" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2
    ▪ NO_PROXY=192.168.49.2
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
🔎  Verifying Kubernetes components...

👍  Starting "docker-mk-m03" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2,192.168.49.3
    ▪ NO_PROXY=192.168.49.2,192.168.49.3
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3
🔎  Verifying Kubernetes components...

👍  Starting "docker-mk-m04" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
🔎  Verifying Kubernetes components...

👍  Starting "docker-mk-m05" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5
🔎  Verifying Kubernetes components...

👍  Starting "docker-mk-m06" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6
🔎  Verifying Kubernetes components...

👍  Starting "docker-mk-m07" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7
🔎  Verifying Kubernetes components...

👍  Starting "docker-mk-m08" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8
🔎  Verifying Kubernetes components...

👍  Starting "docker-mk-m09" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8,192.168.49.9
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8,192.168.49.9
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8,192.168.49.9
🔎  Verifying Kubernetes components...

👍  Starting "docker-mk-m10" worker node in "docker-mk" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🌐  Found network options:
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8,192.168.49.9,192.168.49.10
    ▪ NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8,192.168.49.9,192.168.49.10
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
    ▪ env NO_PROXY=192.168.49.2
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8,192.168.49.9
    ▪ env NO_PROXY=192.168.49.2,192.168.49.3,192.168.49.4,192.168.49.5,192.168.49.6,192.168.49.7,192.168.49.8,192.168.49.9,192.168.49.10
🔎  Verifying Kubernetes components...
🏄  Done! kubectl is now configured to use "docker-mk" cluster and "default" namespace by default
```

Refer to [Minikube FAQ](https://minikube.sigs.k8s.io/docs/faq/) too.

# Metric Server

Execute `minikube -p [cluster name] addons enable metrics-server` to enable kubernetes metrics.

# Container Storage Interface (CSI) Driver

Execute `minikube addons enable csi-hostpath-driver` to enable storage provisioning for multi-node minikube clusters.

Execute `minikube addons enable volumesnapshots` too (required by csi-hostpath-driver)

```
minikube addons enable volumesnapshots -p [cluster name]
minikube addons enable csi-hostpath-driver -p [cluster name]
```