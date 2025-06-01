Refer to [BookStack Docker Hub](https://hub.docker.com/r/linuxserver/bookstack) for additional information. Below are steps I have followed to get BookStack running in a docker container.

# Parameters

Decide the following parameters:
- Database Root Password `MARIADB_ROOT_PASSWORD` `DB_HOST`
- Database Name `MARIADB_DATABASE` `DB_DATABASE`
- Database Username `MARIADB_USER` `DB_USERNAME`
- Database Password `MARIADB_PASSWORD` `DB_PASSWORD`
- Application URL `APP_URL`
- Application Key `APP_KEY` - to be generated
- Persistent storage folder for `/config` - it is recommended to use persistent storage instead. `.env` will also reside in this folder

# Pre-requisites

- ## Crontab database backup container

Refer to [Crontab Custom Image](https://bookstack.handy:26654/books/custom-docker-images/page/crontab) to create a custom docker image to run MariaDB backup jobs via crontab.

- ## `APP_KEY`

Generate `APP_KEY` with `docker run -it --rm --entrypoint /bin/bash lscr.io/linuxserver/bookstack:latest appkey` and store in `docker-compose.yaml` or `.env` file. Below example stores it in `.env`

- ## Persistent Storage Folder

This folder will be used to store all images, uploads, etc files used by BookStack. If persistent storage folder is not used, container image will become big. Backups/Restores should also be considered - potentially easier to perform backups on container external storage instead.

- ## `APP_URL`

This must be exactly the same as how you intend to access BookStack. For whatever reason, BookStack stores links, files, pages, etc. with absolute paths so if this is not correct, the pages will not load properly.

Additionally, if you choose to follow the same local installation as per below, you would need to update `hosts` for local URLs. The example below uses `https://local-BookStack:26654` as the `APP_URL`.

# Required Configuration Files

- ## `bookstack.env` Common `.env` file for all services
> This `.env` file is created to consolidate all `.env` variables for BookStack Project across `app`, `db`, `db-backup`. You can choose to use a single `.env` or an individual `.env` per container service.

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

- ## `docker-compose.yaml` to create/delete/start/stop containers
> - BookStack port `80` is not mapped as I do not intend to access BookStack via HTTP
> - MariaDB automatically runs any `sql` files placed in `/docker-entrypoint-initdb.d` hence explains the `volumes` required to automatically restore any previous installation of BookStack

```yaml
name: Project_BookStack

services:
  db:
    container_name: BookStack-MariaDB
    image: mariadb:latest
    ports:
      - 14306:3306
    env_file: bookstack.env
    volumes:
      - "./backup/bookstack.sql:/docker-entrypoint-initdb.d/bookstack.sql"

  app:
    container_name: BookStack-app
    image: linuxserver/bookstack:latest
    ports:
      - 26654:443
    env_file: bookstack.env
    volumes:
      - "./config:/config"
    depends_on:
      - db

  db-backup:
    container_name: BookStack-backup
    image: hamlyn/db-cron-backup:latest
    env_file: bookstack.env
    volumes:
      - "./crontab/backup.sh:/usr/local/bin/backup.sh"
      - "./crontab/entrypoint.sh:/usr/local/bin/entrypoint.sh"
      - "./crontab/crontab:/etc/crontabs/root"
      - "./backup/bookstack.sql:/backup/bookstack.sql"
    depends_on:
      - db
```

- ## `config/www/.env` `.env` file for BookStack App
> - `.env` should be placed inside persistent storage `www` folder
> - This installation does not make use of email features. This `.env` also references the variables defined in `bookstack.env` loaded as part of container environment `env_file` parameter.

``` ini
# This file, when named as ".env" in the root of your BookStack install
# folder, is used for the core configuration of the application.
# By default this file contains the most common required options but
# a full list of options can be found in the '.env.example.complete' file.

# NOTE: If any of your values contain a space or a hash you will need to
# wrap the entire value in quotes. (eg. MAIL_FROM_NAME="BookStack Mailer")

# Application key
# Used for encryption where needed.
# Run `php artisan key:generate` to generate a valid key.
APP_KEY=${APP_KEY}

# Application URL
# This must be the root URL that you want to host BookStack on.
# All URLs in BookStack will be generated using this value
# to ensure URLs generated are consistent and secure.
# If you change this in the future you may need to run a command
# to update stored URLs in the database. Command example:
# php artisan bookstack:update-url https://old.example.com https://new.example.com
APP_URL=${APP_URL}

# Database details
DB_HOST=${DB_HOST}
DB_DATABASE=${DB_NAME}
DB_USERNAME=${DB_USER}
DB_PASSWORD=${DB_PASS}

# Mail system to use
# Can be 'smtp' or 'sendmail'
MAIL_DRIVER=smtp

# Mail sender details
MAIL_FROM_NAME="BookStack"
MAIL_FROM=bookstack@example.com

# SMTP mail options
# These settings can be checked using the "Send a Test Email"
# feature found in the "Settings > Maintenance" area of the system.
# For more detailed documentation on mail options, refer to:
# https://www.bookstackapp.com/docs/admin/email-webhooks/#email-configuration
MAIL_HOST=localhost
MAIL_PORT=587
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

# Setup

After completing the above steps, run `docker-compose up -d` in the same directory where your `docker-compose.yaml` is located.

You should be able to access BookStack via `https://local-bookstack.com:26654` or value as per `APP_URL`
