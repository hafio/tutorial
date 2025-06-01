# SOCKS Proxy

```bash
ssh -D [local port] [remote username]@[remote host]
```
> - `-D` creates a dynamic port forward on the local port

Configure your browser to use `localhost:[local port]` as a `SOCKS5` proxy.

With this setup, all your browser traffic will be routed through the SSH tunnel, allowing you to access webpages as if you were browsing from the jump host.

**Note**: DNS resolution is usually still handled locally. If required to use `[remote host]`'s DNS resolution, update browser configuration to use remote DNS (not every browser supports this).

# Local Port Forwarding - Single

```bash
ssh -NL [local port]:[remote host]:[remote port] [remote username]@[remote host]
```

> - `-f` background execution - **not recommended** to be used as you will need to do `ps -ef` to locate the process to kill/terminate later
> - `-L` local port forwarding
> - `-N` no command execute remotely, keeping tunnel open. <br>**Note**: the sequence at which `-N` appears is important as it would determine which ssh session to apply to.

Whatever traffic you send to `localhost:[local port]` will end up in `[remote host]:[remote port]` via the SSH tunnel.

# Local Port Forwarding - Multiple

```bash
ssh -N \
  -L [local port A]:[remote host]:[remote port A] \
  -L [local port B]:[remote host]:[remote port B] \
  -L [local port C]:[remote host]:[remote port C] \
  [remote username]@[remote host]
```

# Local + Remote Port Forwarding - Single

<div drawio-diagram="18"><img src="https://bookstack.handy:26654/uploads/images/drawio/2024-11/drawing-1-1732246627.png"></div>

```bash
ssh -L [local port]:[host b]:[host b port] [host a username]@[host a] -t ssh [host b username]@[host b] -N
```

> - `-f` background execution - **not recommended** to be used as you will need to do `ps -ef` to locate the process to kill/terminate later
> - `-L` local port forwarding
> - `-t` commands to execute on remote host
> - `-N` no command execute remotely, keeping tunnel open. <br>**Note**: the sequence at which `-N` appears is important as it would determine which ssh session to apply to.

# Local + Remote Port Forwarding - Multiple

```bash
ssh -N \
  -L [local port A]:[host b]:[host b port A] \
  -L [local port B]:[host b]:[host b port B] \
  -L [local port C]:[host b]:[host b port C] \
  [host a username]@[host a] \
  -t ssh [host b username]@[host b] -N
```

# Different SSH Ports

If remote hosts are not using conventional ssh ports:

```bash
ssh -p [remote host ssh port] \
  -NL [local port]:[remote host]:[remote port] \
  [remote username]@[remote host]
```
```bash
ssh -p [host a ssh port] \
  -L [local port]:[host b]:[host b port] \
  [host a username]@[host a] \
  -t ssh -p [host b ssh port] [host b username]@[host b] -N
```

# Using `.ssh/config`

Using `.ssh/config` allows you to configure *implicit* proxy/jump host to remote host.

## Option A - specify port forwarding on command line

- `.ssh/config`
```yaml
Host [host-a]
  User [host a username]
  HostName [host-a]
  Port 22

Host [host-b]
  User [host b username]
  HostName [host b]
  Port 22
  ProxyJump [host a]
```

Execute `ssh -L [local port]:[host b]:[host b port] [host b] -N`

## Option B - specify port forwarding in `.ssh/config`

- `.ssh/config`
```yaml
Host [host-a]
  User [host a username]
  HostName [host-a]
  Port 22

Host [host-b]
  User [host b username]
  HostName [host b]
  Port 22
  ProxyJump [host a]
  LocalForward [local port A] [host b]:[host b port A]
  LocalForward [local port B] [host b]:[host b port B]
  LocalForward [local port C] [host b]:[host b port C]
```

Execute `ssh [host b] -N`