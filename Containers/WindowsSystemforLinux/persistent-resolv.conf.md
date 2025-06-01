> use `sudo` if require
> 
Remove soft link `rm -f /etc/resolve.conf`

Update `/etc/resolve.conf` with the below content:
```ini
nameserver 1.1.1.1
nameserver 8.8.8.8
options edns0 trust-ad
search .
```

Update `/etc/wsl.conf`
```ini
[boot]
systemd=true

[network]
generateResolvConf = false
```

Make `/etc/resolve.conf` immutable `chattr +i /etc/resolv.conf`