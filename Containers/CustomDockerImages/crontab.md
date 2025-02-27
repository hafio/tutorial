## Overview

Create your own `crontab` image using `alpine:latest` as the base image.

This **custom image is specifically meant to backup MariaDB database (single)** but can be repurposed / modified / tweaked for other purposes.

This image contains a cron job that will run `backup.sh` (to backup a specific MariaDB database) on an hourly (can be changed) basis. The backup job will also run once when the container is stopped (Linux `SIGTERM` & `SIGINT`).

## `crontab` Required Files

- ##### `docker-compose.yaml`
```yaml
name: Project_db-cron-backup

services:
  cron-backup:
    build:
      context: .
      dockerfile: Dockerfile
    image: hamlyn/db-cron-backup:latest
```
> image name and tag is specified in `Dockerfile`

- ##### `Dockerfile`
```dockerfile
FROM alpine:latest

# Install necessary packages and cron
RUN apk --no-cache add mariadb-client bash coreutils tzdata openrc

# Copy backup script and apply executable permissions
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Copy entrypoint.sh and apply executable permissions
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create log directories
RUN mkdir -p /var/log && touch /var/log/cron.log

# Entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 
```
  
- ##### `backup.sh`
```bash
#!/bin/bash

# Default variables to use if container variables are not provided

MYSQL_USER="bookstack"
MYSQL_PASS="bookstack"
MYSQL_HOST="BookStack-MariaDB"	# The service name of the MariaDB container
MYSQL_DBNM="bookstack"
MYSQL_PORT="3306"				# default port number
BACKUP_DIR="/backup"
BACKUP_FILENAME="bookstack.sql"
TIMEZONE="Asia/Singapore"
ERR_LOG=/var/log/backup.err

# Checks to see if container variables are provided

if [[ -z ${DB_USER} ]]; then
	DB_USER=${MYSQL_USER}
fi
if [[ -z ${DB_PASS} ]]; then
	DB_PASS=${MYSQL_PASS}
fi
if [[ -z ${DB_HOST} ]]; then
	DB_HOST=${MYSQL_HOST}
fi
if [[ -z ${DB_NAME} ]]; then
	DB_NAME=${MYSQL_DBNM}
fi
if [[ -z ${DB_PORT} ]]; then
	DB_PORT=${MYSQL_PORT}
fi
if [[ -z ${DB_BACKUP_DIR} ]]; then
	DB_BACKUP_DIR=${BACKUP_DIR}
fi
if [[ -z ${DB_BACKUP_FILENAME} ]]; then
	DB_BACKUP_FILENAME=${BACKUP_FILENAME}
fi
if [[ -z ${TZ} ]]; then
	TZ=${TIMEZONE}
fi

# Create backup directory if it doesn't exist
mkdir -p ${DB_BACKUP_DIR}

# Perform the backup
TZ=${TZ} date +"%d-%b-%Y %a %H:%M:%S%z" > ${ERR_LOG}
mariadb-dump -h ${DB_HOST} -u ${DB_USER} -p${DB_PASS} -P ${DB_PORT} ${DB_NAME} > ${DB_BACKUP_DIR}/${DB_BACKUP_FILENAME} 2>> ${ERR_LOG}
DUMP_PROC_EXIT=$?
# Optional: Remove old backups (e.g., keep last 7 backups)
#find "$BACKUP_DIR" -type f -name "backup_*.sql" -mtime +7 -exec rm -f {} \;

DATE=`TZ=${TZ} date +"%d-%b-%Y %a %H:%M:%S%z"`

if [[ ${DUMP_PROC_EXIT} -eq 0 ]] && [[ `grep -i error /var/log/backup.err | wc -l` -eq 0 ]]; then
	echo "[${DATE}] Backup completed: ${DB_BACKUP_DIR}/${DB_BACKUP_FILENAME}"
else
	echo "[${DATE}] Backup failed"
fi
```

- ##### `entrypoint.sh`
```bash
#!/bin/bash

cleanup() {
	echo "[`TZ=${TZ} date +"%d-%b-%Y %a %H:%M:%S%z"`] Container stopping..."
	echo "[`TZ=${TZ} date +"%d-%b-%Y %a %H:%M:%S%z"`] Performing last backup"
	echo ""
	/usr/local/bin/backup.sh
}

trap cleanup SIGTERM SIGINT

echo "[`TZ=${TZ} date +"%d-%b-%Y %a %H:%M:%S%z"`] Container starting..."
crond -f -L /var/log/cron.log &

wait $!
```

- ##### `crontab`
```cron filename="crontab"
0 * * * * /usr/local/bin/backup.sh > /var/log/backup.log 2>&1
1 * * * * tail -n 10 /var/log/cron.log > /tmp/cron.log && mv /tmp/cron.log /var/log/cron.log
```
> cron job is scheduled to run every hour on the 0th minute (e.g. 0100, 0200, 0300, etc.)
> 
> second line is used to trim `crontab` logs to limit log filesize. `tail -n [lines]` change `[lines]` to desired number of lines to keep in log file. It runs at the 1st minute of every hour (e.g. 0101, 0201, 0301, etc.)

## `crontab` Build

**Make sure all above required files are in the same folder.**

Execute `docker-compose build --no-cache --pull`, output should be similar to:
> Alternatively can execute `docker build -t hamlyn/db-cron-backup:latest --no-cache --pull .` for building without `docker-compose`.

```
[+] Building 4.2s (12/12) FINISHED                                             docker:desktop-linux
 => [cron-backup internal] load build definition from Dockerfile                               0.0s
 => => transferring dockerfile: 488B                                                           0.0s
 => [cron-backup internal] load metadata for docker.io/library/alpine:latest                   0.0s
 => [cron-backup internal] load .dockerignore                                                  0.0s
 => => transferring context: 2B                                                                0.0s
 => CACHED [cron-backup 1/6] FROM docker.io/library/alpine:latest                              0.0s
 => [cron-backup internal] load build context                                                  0.0s
 => => transferring context: 1.83kB                                                            0.0s
 => [cron-backup 2/6] RUN apk --no-cache add mariadb-client bash coreutils tzdata openrc       2.9s
 => [cron-backup 3/6] COPY backup.sh /usr/local/bin/backup.sh                                  0.1s
 => [cron-backup 4/6] RUN chmod +x /usr/local/bin/backup.sh                                    0.3s
 => [cron-backup 5/6] RUN mkdir -p /var/log && touch /var/log/cron.log                         0.4s
 => [cron-backup 6/6] COPY crontab /etc/crontabs/root                                          0.1s
 => [cron-backup] exporting to image                                                           0.5s
 => => exporting layers                                                                        0.4s
 => => writing image sha256:2ea72951a5ad2e62398652fa245c37bc6e335de455546e304d50438ac2a34639   0.0s
 => => naming to docker.io/hamlyn/db-cron-backup:latest                                        0.0s
 => [cron-backup] resolving provenance for metadata file                                       0.0s
```
Docker image should show up in your image list for you to use. You can reference image name:tag in your other `docker-compose.yaml` files.

## Run

#### Docker Environment Variables

- `DB_HOST` Container name or docker compose project service name
- `DB_USER` Database login username
- `DB_PASS` Database username's password
- `DB_NAME` Database name
- `DB_PORT` Database port (defaulted to 3306)
- `DB_BACKUP_DIR` Directory for backup
- `DB_BACKUP_FILENAME` SQL backup filename
- `TZ` Timezone for logs timestamp (optional)
> if any of the above parameters is not specified as part of the docker environment, the values within `backup.sh` will be used instead.

#### Pre-requisite Files

- ##### `.env` file usage

instead of specifying the environment variables individually in `docker-compose.yaml` or runtime arguments `-e`, you can use `env_file` within `docker-compose.yaml`

The below example is a common `.env` file (actual filename is `bookstack.env`) used for BookStack project shared across BookStack and MariaDB:

```ini
DB_USER=bookstack
DB_PASS=bookstack
DB_HOST=db
DB_NAME=bookstack
DB_PORT=3306
DB_BACKUP_DIR=/backup
DB_BACKUP_FILENAME=bookstack.sql
TZ=Asia/Singapore

[DB]
MARIADB_ROOT_PASSWORD=hamlyn
MARIADB_DATABASE=${DB_NAME}
MARIADB_USER=${DB_USER}
MARIADB_PASSWORD=${DB_PASS}

[APP]
APP_KEY=base64:6xjjoBtsSa2DwGbAXCA2KUxu2YZVItC4iQ3ghicmwgQ=
APP_URL=https://bookstack.handy:26654
DB_HOST=${DB_HOST}
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}
PUID=1000
PGID=1000
TZ=${TZ}
```

- ##### `docker-compose.yaml`
```yaml
name: Project_BookStack

services:
  db:
    ...

  app:
    ...

  db-backup:
    container_name: BookStack-backup
    image: hamlyn/db-cron-backup:latest
    env_file: bookstack.env
    volumes:
      - "./crontab/backup.sh:/usr/local/bin/backup.sh"
      - "./crontab/crontab:/etc/crontabs/root"
      - "./backup/bookstack.sql:/backup/bookstack.sql"
    depends_on:
      - db
```
> `backup.sh` and `crontab` are mounted from persistent folder so it can be changed easily.
>
> **Note:** every change to crontab schedule will require a container restart `docker-compose restart db-backup`
>
> Refer to BookStack project for full `docker-compose.yaml`. `depends_on` in above example is **optional**

- ##### Other files required for runtime

`backup.sh` and `crontab` are stored in `crontab` folder in the above example as per `docker-compose.yaml`. Update `docker-compose.yaml` if files are stored elsewhere (relative/absolute path).
```
<current directory>
|- docker-compose.yaml
|- bookstack.env
|- crontab
   |- backup.sh
   |- crontab
|- backup
   |- bookstack.sql
```

#### Starting the container via `docker-compose`

Execute `docker-compose up -d` in "current directory" as per above directory structure