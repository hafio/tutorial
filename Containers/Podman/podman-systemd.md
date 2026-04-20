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
