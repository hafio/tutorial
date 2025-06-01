# Overview

Refer to [https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro)

You can install any linux distribution onto WSL by means of using docker images.

# Saving Docker Images

## Option 1: Export docker images from images

```
docker image save [image name] -o [output tar filename]
```

## Option 2: Export docker images from containers

Ensure containers are not running

```
docker export [container name or id] -o [output tar filename]
```

# Importing into WSL

```
wsl --import [Distro Name] [Installation Directory] [image tar file]
```

Output should be:
```
Import in progress, this may take a few minutes.
The operation completed successfully.
```

# Verify

Running `wsl -l -v` should give you

```
  NAME              STATE           VERSION
* Ubuntu-24.04      Running         2
  docker-desktop    Running         2
  RHEL9             Stopped         2
```
> `RHEL9` is the custom linux I have installed in this example

# Run it for the first time to complete setup

Run `wsl -d [distro name]`