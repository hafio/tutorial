# Registering Podman Containers as systemd Services

Two approaches are covered:

1. **`podman generate systemd`** — legacy, deprecated in Podman 4.4+ but still widely used.
2. **Quadlet** — the modern, recommended approach (Podman 4.4+).

Both support **rootful** (system-wide, runs as root) and **rootless** (per-user) modes.

---

## 1. `podman generate systemd` (Legacy)

### Rootful

```bash
# Create and start the container first
sudo podman run -d --name <container_name> <image>

# Generate the unit file
sudo podman generate systemd --new --name <container_name> --files

# Move it into the system unit directory
sudo mv container-<container_name>.service /etc/systemd/system/

# Reload and enable
sudo systemctl daemon-reload
sudo systemctl enable --now container-<container_name>.service
```

### Rootless

```bash
# Ensure the user systemd directory exists
mkdir -p ~/.config/systemd/user

# Create and start the container first
podman run -d --name <container_name> <image>

# Generate the unit file
podman generate systemd --new --name <container_name> --files

# Move it into the user unit directory
mv container-<container_name>.service ~/.config/systemd/user/

# Reload and enable
systemctl --user daemon-reload
systemctl --user enable --now container-<container_name>.service

# Allow user services to run without an active login session
loginctl enable-linger $USER
```

### Key flags

| Flag | Purpose |
|------|---------|
| `--new` | Unit recreates the container on each start (recommended). Without it, the unit manages an existing container. |
| `--files` | Writes `.service` files to the current directory instead of stdout. |
| `--name` | Use the container name instead of its ID in the unit file. |
| `--restart-policy` | Set restart policy (default `on-failure`). |

### Status check

```bash
# Rootful
sudo systemctl status container-<container_name>.service

# Rootless
systemctl --user status container-<container_name>.service
```

---

## 2. Quadlet (Recommended, Podman 4.4+)

Quadlet lets you describe containers declaratively in `.container` files. systemd generates the corresponding `.service` units at boot/reload — you never hand-write or regenerate them.

### ⚠️ Do NOT run `podman run` when using Quadlet

With Quadlet, **you never invoke `podman run` (or `podman pull`, `podman create`) yourself**. The `.container` file *is* the declaration — Quadlet builds the full `podman run ...` command and places it in the generated `.service` unit's `ExecStart=`. systemd executes it when you start the service.

| Task | With `podman generate systemd` | With Quadlet |
|------|-------------------------------|--------------|
| Create the container | `podman run -d --name ...` (you) | Declared in `.container` file |
| Pull the image | `podman pull` (you) | Automatic on first start, or via `Pull=` / `.image` unit |
| Start it | `systemctl start ...` | `systemctl start ...` |
| Update config | Re-run `podman run` + regenerate unit | Edit `.container`, `daemon-reload`, restart |

**Rule of thumb:** anything that **creates, starts, stops, or removes** a Quadlet-managed container must go through `systemctl`, never `podman`. Read-only commands (`podman ps`, `podman logs`, `podman inspect`) are fine for debugging. If you `podman rm` a Quadlet container, systemd will recreate it on the next start.

### File locations

| Mode | Directory |
|------|-----------|
| Rootful | `/etc/containers/systemd/` |
| Rootless | `~/.config/containers/systemd/` |

### Example: `myapp.container`

```ini
[Unit]
Description=My Application Container
After=network-online.target
Wants=network-online.target

[Container]
Image=docker.io/library/nginx:latest
ContainerName=myapp
PublishPort=8080:80

# Multiple volumes — repeat the key, one mount per line
Volume=/srv/myapp/html:/usr/share/nginx/html:Z
Volume=/srv/myapp/conf:/etc/nginx/conf.d:ro,Z
Volume=myapp-cache.volume:/var/cache/nginx
Volume=/srv/myapp/logs:/var/log/nginx:Z

# Multiple environment variables — repeat the key, one per line
Environment=TZ=UTC
Environment=APP_ENV=production
Environment=LOG_LEVEL=info
Environment=DATABASE_URL=postgres://db:5432/myapp

AutoUpdate=registry

[Service]
Restart=always
TimeoutStartSec=900

[Install]
WantedBy=multi-user.target default.target
```

### Rootful

```bash
# Drop the file in the system Quadlet directory
sudo cp myapp.container /etc/containers/systemd/

# Regenerate units from Quadlet files
sudo systemctl daemon-reload

# Start the service (unit name = <filename>.service)
sudo systemctl start myapp.service

# Check status
sudo systemctl status myapp.service
```

> Units from `[Install]` sections are enabled automatically when placed in the Quadlet directory; you only need `start`, not `enable`.

### Rootless

```bash
# Ensure the directory exists
mkdir -p ~/.config/containers/systemd/

# Drop the file in
cp myapp.container ~/.config/containers/systemd/

# Regenerate user units
systemctl --user daemon-reload

# Start the service
systemctl --user start myapp.service

# Allow the service to run without an active login session
loginctl enable-linger $USER
```

### Debugging Quadlet generation

Preview the generated `.service` without installing it:

```bash
# Rootful
/usr/libexec/podman/quadlet -dryrun

# Rootless
/usr/libexec/podman/quadlet -dryrun -user
```

### Other Quadlet unit types

| Extension | Purpose |
|-----------|---------|
| `.container` | Single container |
| `.pod` | A pod (group of containers) |
| `.network` | A podman network |
| `.volume` | A podman volume |
| `.kube` | Deploy from a Kubernetes YAML |
| `.image` | Pre-pull an image |
| `.build` | Build an image from a Containerfile |

---

## Choosing Between the Two

| Consideration | `generate systemd` | Quadlet |
|---------------|-------------------|---------|
| Podman version | Any | 4.4+ |
| Upstream status | Deprecated | Recommended |
| Config style | Imperative (`podman run` → generate) | Declarative (`.container` file) |
| Regeneration after changes | Re-run `generate systemd` | Just `daemon-reload` |
| Readability | Verbose `ExecStart=podman run ...` | Clean, INI-style sections |
| Portability | Unit file is self-contained | Requires Quadlet on target host |

**Use Quadlet for new deployments.** Keep `generate systemd` only for compatibility with older Podman releases or existing unit files you don't want to migrate yet.

---

## Common Operations (Both Approaches)

```bash
# View logs
journalctl -u <service_name>                 # rootful
journalctl --user -u <service_name>          # rootless

# Restart
systemctl restart <service_name>             # rootful (sudo)
systemctl --user restart <service_name>      # rootless

# Disable & remove
systemctl disable --now <service_name>
rm <unit_or_quadlet_file>
systemctl daemon-reload
```

---

## Quadlet Parameter Reference

All keys supported by Quadlet, grouped by unit-file section. Keys marked **(required)** must be present. Keys that accept multiple values are set by repeating the key on its own line (e.g. multiple `Volume=` or `Environment=` entries).

Source: `podman-systemd.unit(5)` man page.

### `[Container]` section (`.container` files)

| Key | Description |
|-----|-------------|
| `AddCapability` | Add Linux capabilities beyond the default Podman set. |
| `AddDevice` | Attach a host device node into the container (optional permissions). |
| `AddHost` | Add a `hostname:ip` mapping to `/etc/hosts`. |
| `Annotation` | Set OCI annotations as `key=value`. |
| `AutoUpdate` | Enable auto-updates (`registry` or `local`). |
| `AppArmor` | AppArmor confinement profile. |
| `CgroupsMode` | cgroups mode (Quadlet defaults to `split`). |
| `ContainerName` | Container name (default `systemd-<unit>`). |
| `ContainersConfModule` | Load a `containers.conf(5)` module. Repeatable. |
| `DNS` | DNS nameserver. Repeatable. |
| `DNSOption` | Custom DNS option. Repeatable. |
| `DNSSearch` | Custom DNS search domain. Repeatable. |
| `DropCapability` | Remove capabilities from the default set. |
| `Entrypoint` | Override the image's ENTRYPOINT. |
| `Environment` | Set an env var in the container. Repeatable. |
| `EnvironmentFile` | Load env vars from a file. |
| `EnvironmentHost` | Inherit the host's environment. |
| `Exec` | Arguments appended to the container command. |
| `ExposeHostPort` | Expose a host port to the container. |
| `GIDMap` | GID mapping for a new user namespace. |
| `GlobalArgs` | Args inserted between `podman` and `run`. |
| `Group` | Numeric GID inside the container. |
| `GroupAdd` | Additional groups for the primary user. |
| `HealthCmd` | Healthcheck command. |
| `HealthInterval` | Interval between healthchecks. |
| `HealthLogDestination` | Destination for healthcheck logs. |
| `HealthMaxLogCount` | Max number of healthcheck log attempts stored. |
| `HealthMaxLogSize` | Max character length of a stored healthcheck log. |
| `HealthOnFailure` | Action when container becomes unhealthy. |
| `HealthRetries` | Retries before marking unhealthy. |
| `HealthStartPeriod` | Bootstrap time before failures count. |
| `HealthStartupCmd` | Startup healthcheck command. |
| `HealthStartupInterval` | Interval for startup healthcheck. |
| `HealthStartupRetries` | Attempts before startup healthcheck restarts container. |
| `HealthStartupSuccess` | Successful runs needed for startup healthcheck to pass. |
| `HealthStartupTimeout` | Max time for startup healthcheck to complete. |
| `HealthTimeout` | Max time per healthcheck run. |
| `HostName` | Hostname inside the container. |
| `HttpProxy` | Pass host proxy env vars into the container. |
| `Image` | **(required)** Image reference. |
| `IP` | Static IPv4 address. |
| `IP6` | Static IPv6 address. |
| `Label` | OCI label `key=value`. Repeatable. |
| `LogDriver` | Podman log driver. |
| `LogOpt` | Logging option. Repeatable. |
| `Mask` | Colon-separated paths to mask (make inaccessible). |
| `Memory` | Memory limit. |
| `Mount` | Filesystem mount (long-form `--mount` syntax). Repeatable. |
| `Network` | Network to attach to. Repeatable. |
| `NetworkAlias` | Network-scoped alias. Repeatable. |
| `NoNewPrivileges` | Disable privilege escalation. |
| `Notify` | Enable `sd_notify` or wait for healthy status. |
| `PidsLimit` | Container PID limit. |
| `Pod` | Link to a Quadlet `.pod` unit. |
| `PodmanArgs` | Args appended to the end of `podman run`. |
| `PublishPort` | Publish a port (`host:container`). Repeatable. |
| `Pull` | Image pull policy. |
| `ReadOnly` | Make image read-only. |
| `ReadOnlyTmpfs` | Mount a tmpfs when `ReadOnly=true`. |
| `ReloadCmd` | Run `podman exec` on `systemctl reload`. |
| `ReloadSignal` | Send signal to the main process on `systemctl reload`. |
| `Retry` | Pull retries on HTTP error. |
| `RetryDelay` | Delay between pull retries. |
| `Rootfs` | Run from a rootfs directory instead of an image. |
| `RunInit` | Include a minimal init (`tini`) in the container. |
| `SeccompProfile` | Seccomp profile path. |
| `Secret` | Mount a Podman secret as file or env var. |
| `SecurityLabelDisable` | Disable SELinux labelling. |
| `SecurityLabelFileType` | SELinux file type. |
| `SecurityLabelLevel` | SELinux level. |
| `SecurityLabelNested` | Allow nested SELinux labels. |
| `SecurityLabelType` | SELinux process type. |
| `ShmSize` | Size of `/dev/shm`. |
| `StartWithPod` | Start after the associated pod is up. |
| `StopSignal` | Signal used to stop. |
| `StopTimeout` | Seconds before SIGKILL. |
| `SubGIDMap` | Named `/etc/subgid` map. |
| `SubUIDMap` | Named `/etc/subuid` map. |
| `Sysctl` | Namespaced kernel parameter. Repeatable. |
| `Timezone` | Container timezone. |
| `Tmpfs` | Tmpfs mount. Repeatable. |
| `UIDMap` | UID mapping for a new user namespace. |
| `Ulimit` | `name=soft:hard`. Repeatable. |
| `Unmask` | Colon-separated paths to unmask, or `ALL`. |
| `User` | Numeric UID inside the container. |
| `UserNS` | User namespace mode. |
| `Volume` | Mount (`src:dst[:opts]`). Repeatable. |
| `WorkingDir` | Working directory inside the container. |

### `[Pod]` section (`.pod` files)

| Key | Description |
|-----|-------------|
| `AddHost` | `hostname:ip` entry in `/etc/hosts`. |
| `ContainersConfModule` | Load a `containers.conf` module. |
| `DNS` | DNS nameserver for pod containers. |
| `DNSOption` | Custom DNS option. |
| `DNSSearch` | Custom DNS search domain. |
| `ExitPolicy` | Pod exit policy when the last container exits. |
| `GIDMap` | GID map for new user namespace. |
| `GlobalArgs` | Args inserted between `podman` and `pod create`. |
| `HostName` | Hostname shared by all pod containers. |
| `IP` | Static IPv4 address. |
| `IP6` | Static IPv6 address. |
| `Label` | OCI label. |
| `Network` | Network for the pod. |
| `NetworkAlias` | Network-scoped alias. |
| `PodmanArgs` | Args appended to `podman pod create`. |
| `PodName` | Pod name (default `systemd-<unit>`). |
| `PublishPort` | Publish a port. |
| `ServiceName` | Override generated `.service` name. |
| `ShmSize` | `/dev/shm` size. |
| `StopTimeout` | Seconds to wait for graceful stop. |
| `SubGIDMap` | Named `/etc/subgid` map. |
| `SubUIDMap` | Named `/etc/subuid` map. |
| `UIDMap` | UID map for new user namespace. |
| `UserNS` | User namespace mode. |
| `Volume` | Volume shared by the pod. |

### `[Volume]` section (`.volume` files)

| Key | Description |
|-----|-------------|
| `ContainersConfModule` | Load a `containers.conf` module. |
| `Copy` | Copy image-mountpoint contents into the volume on create. |
| `Device` | Device path backing the volume. |
| `Driver` | Volume driver (e.g. `local`, `image`). |
| `GlobalArgs` | Args inserted between `podman` and `volume create`. |
| `Group` | Owner GID/group name. |
| `Image` | Backing image when `Driver=image`. |
| `Label` | OCI label. |
| `Options` | `mount(8) -o` options. |
| `PodmanArgs` | Args appended to `podman volume create`. |
| `Type` | `mount(8) -t` filesystem type. |
| `User` | Owner UID/user name. |
| `VolumeName` | Volume name (default `systemd-<unit>`). |

### `[Network]` section (`.network` files)

| Key | Description |
|-----|-------------|
| `ContainersConfModule` | Load a `containers.conf` module. |
| `DisableDNS` | Disable the DNS plugin. |
| `DNS` | DNS nameserver for containers on the network. |
| `Driver` | `bridge`, `macvlan`, or `ipvlan`. |
| `Gateway` | Subnet gateway. |
| `GlobalArgs` | Args inserted between `podman` and `network create`. |
| `InterfaceName` | Bridge interface or parent device. |
| `Internal` | Restrict external access. |
| `IPAMDriver` | `host-local`, `dhcp`, or `none`. |
| `IPRange` | Allocate IPs from this range. |
| `IPv6` | Enable dual-stack IPv6. |
| `Label` | OCI label. |
| `NetworkDeleteOnStop` | Delete network when the service stops. |
| `NetworkName` | Network name (default `systemd-<unit>`). |
| `Options` | Driver-specific options. |
| `PodmanArgs` | Args appended to `podman network create`. |
| `Subnet` | Subnet in CIDR notation. |

### `[Image]` section (`.image` files)

| Key | Description |
|-----|-------------|
| `AllTags` | Pull every tagged image in the repo. |
| `Arch` | Override image architecture. |
| `AuthFile` | Registry auth file path. |
| `CertDir` | Directory of TLS certificates. |
| `ContainersConfModule` | Load a `containers.conf` module. |
| `Creds` | `username:password` for the registry. |
| `DecryptionKey` | `key:passphrase` for encrypted images. |
| `GlobalArgs` | Args inserted between `podman` and `image pull`. |
| `Image` | **(required)** Image reference to pull. |
| `ImageTag` | FQIN for archive-sourced images. |
| `OS` | Override image OS. |
| `PodmanArgs` | Args appended to `podman image pull`. |
| `Policy` | Pull policy. |
| `Retry` | Pull retries on HTTP error. |
| `RetryDelay` | Delay between retries. |
| `TLSVerify` | Require HTTPS + valid certs. |
| `Variant` | Override architecture variant. |

### `[Kube]` section (`.kube` files)

| Key | Description |
|-----|-------------|
| `AutoUpdate` | Enable auto-updates. |
| `ConfigMap` | Path to a ConfigMap YAML. |
| `ContainersConfModule` | Load a `containers.conf` module. |
| `ExitCodePropagation` | `all`, `any`, or `none`. |
| `GlobalArgs` | Args inserted between `podman` and `kube play`. |
| `KubeDownForce` | Include volumes on `kube down`. |
| `LogDriver` | Log driver for containers. |
| `Network` | Network override. |
| `PodmanArgs` | Args appended to `podman kube play`. |
| `PublishPort` | Publish a port. |
| `SetWorkingDirectory` | Working dir = YAML or unit file location. |
| `UserNS` | User namespace mode. |
| `Yaml` | **(required)** Path to the Kubernetes YAML. |

### `[Build]` section (`.build` files)

| Key | Description |
|-----|-------------|
| `Annotation` | Image annotation `key=value`. |
| `Arch` | Override image architecture. |
| `AuthFile` | Registry auth file. |
| `BuildArg` | Build-time argument `key=value`. |
| `ContainersConfModule` | Load a `containers.conf` module. |
| `DNS` | DNS nameserver for the build container. |
| `DNSOption` | Custom DNS option. |
| `DNSSearch` | DNS search domain. |
| `Environment` | Add value to image metadata (not a runtime env var). |
| `File` | Containerfile path or URL. |
| `ForceRM` | Always remove intermediate containers. |
| `GlobalArgs` | Args inserted between `podman` and `build`. |
| `GroupAdd` | Additional groups in the build container. |
| `IgnoreFile` | Alternate `.containerignore`. |
| `ImageTag` | **(required)** Name/tag for the built image. |
| `Label` | Image label. |
| `Network` | Network for `RUN` instructions. |
| `PodmanArgs` | Args appended to `podman build`. |
| `Pull` | Pull policy for base images. |
| `Retry` | Pull retries on HTTP error. |
| `RetryDelay` | Delay between retries. |
| `Secret` | Build-time secret. |
| `SetWorkingDirectory` | Build context directory. |
| `Target` | Multi-stage target. |
| `TLSVerify` | Require HTTPS + valid certs. |
| `Variant` | Override architecture variant. |
| `Volume` | Mount during `RUN` instructions. |

### `[Artifact]` section (`.artifact` files)

| Key | Description |
|-----|-------------|
| `Artifact` | **(required)** Fully qualified artifact name to pull. |
| `AuthFile` | Registry auth file. |
| `CertDir` | TLS certificate directory. |
| `ContainersConfModule` | Load a `containers.conf` module. |
| `Creds` | `username:password`. |
| `DecryptionKey` | `key:passphrase` for encrypted artifacts. |
| `GlobalArgs` | Args inserted between `podman` and `artifact pull`. |
| `PodmanArgs` | Args appended to `podman artifact pull`. |
| `Quiet` | Suppress output. |
| `Retry` | Pull retries on HTTP error. |
| `RetryDelay` | Delay between retries. |
| `ServiceName` | Override generated `.service` name. |
| `TLSVerify` | Require HTTPS + valid certs. |

### `[Quadlet]` section (all unit types)

| Key | Description |
|-----|-------------|
| `DefaultDependencies` | Add Quadlet's default network dependencies to the unit (default `true`). |

### Standard systemd sections

Quadlet units may also contain the usual `[Unit]`, `[Service]`, and `[Install]` sections — Quadlet passes these through verbatim to the generated `.service`. Common keys to know:

- **`[Unit]`**: `Description`, `After`, `Wants`, `Requires`, `PartOf`.
- **`[Service]`**: `Restart`, `RestartSec`, `TimeoutStartSec`, `TimeoutStopSec`.
- **`[Install]`**: `WantedBy`, `RequiredBy`.

> Do **not** set `ExecStart`/`ExecStop` yourself — Quadlet generates those from the container/pod/volume/etc. section.
