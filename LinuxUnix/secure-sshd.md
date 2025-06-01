Update SSHD configuration file (usually `/etc/ssh/sshd_config`) to have the following:

| Configuration | Description |
| - | - |
| `Port 12345` | change sshd port to non-default |
| `PasswordAuthentication no` | disable password authentication |
| `PubkeyAuthentication yes` | enable ssh key authentication |
| `PermitRootLogin no` | disable ssh direct root login |
| `Match Address 1.2.3.4`<br>`  PermitRootLogin prohibit-password` | only allow root ssh key login from specific hosts |