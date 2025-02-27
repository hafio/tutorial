## Overview

Common Docker CLI commands. Refer to [CLI Cheat Sheet](https://docs.docker.com/get-started/docker_cheatsheet.pdf)

#### Images

| Description | Command |
| - | - |
| Build image <br> &nbsp; Optional no caching | `docker build -t [image name]` <br> &nbsp; `--no-cache` |
| List images | `docker images` |
| Delete image | `docker rmi [image name/id]` |
| Delete unused images | `docker image prune` |
| Load image from archive | `docker load -i [file/URL] [image name[:tag]]` <br> (don't use `docker image import` as it does not include file args) |
| Save image | `docker image save [image name[:tag]] -o [filename]` or <br> `docker image save [image name[:tag]] > [filename]` |
| Duplicate image | `docker image tag [source image name[:tag]] [target image name[:tag]]` |

#### Containers

| Description | Command |
| - | - |
| List all running containers <br> &nbsp; Optional all (default is only running containers) | `docker ps` <br> &nbsp; `--all` <br> &nbsp;  |
| Create container from image <br> &nbsp; Optional specify container name <br> &nbsp; Optional run in background <br> &nbsp; Optional port mapping | `docker run [image name]` <br> &nbsp; `--name [container name]` <br> &nbsp; `-d` <br> &nbsp; `-p [host port]:[container port]` |
| Start existing container | `docker start [container name/id]` |
| Stop existing container | `docker stop [container name/id]` |
| Remove container <br> &nbsp; Optional forced| `docker rm [container name]` <br> &nbsp; `-f` |
| Show container logs <br> &nbsp; Optional tail (last lines) <br> &nbsp; Optional follow (equivalent to `tail -n`) | `docker logs [container name]` <br> &nbsp; `-n [lines]` <br> &nbsp; `-f` |
| Open shell inside container | `docker exec -it [container name] bash` |
| Inspect container | `docker inspect [container name/id]` |
| Show containers stats (top) | `docker container stats` |