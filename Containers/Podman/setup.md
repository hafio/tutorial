# Overview

Podman is a daemon-less CLI API tool designed to be compatible with docker containers and features yet has its own additional features (e.g. pods).

# Installation

## Windows
Refer to [https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md](https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md)

## Linux / WSL

```bash
apt get -y install podman
```

# Virtual Machines (Windows)

On windows, you would need to have a virtual machine becaused podman is meant to run linux applications only
```bash
podman machine init --cpus [numer of cpu] --disk-size [GiB] --now -v [volume mount source:volume mount target]
```
> This can also be done via Podman Desktop (Settings > Resources)

On WSL (or Linux), this step is **not required**.