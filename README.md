[![Build Status](https://travis-ci.org/appkr/lemp-base.svg?branch=18.04)](https://travis-ci.org/appkr/lemp-base)

# LEMP Base Docker Image

## 1. What is this?

LEMP in one container.

I know this is not a docker-way though, I believe it is overwhelming for PHP or Docker beginners to understand the concept of cluster, which consists of multiple containers. I couldn't find working one in the Internet, supporting Ubuntu, Nginx, PHP & FPM, and MySQL just in one image. Really.

`latest` tag is linked to `16.04`

tag|Ubuntu|PHP|MySQL
---|---|---|---
16.04|16.04|7.0|5.7
18.04|18.04|7.2|5.7

## 2. Quick Start

To download the already built image from docker hub and run it (You have to provide `<your-container-name>`):

```sh
~ $ docker run -d \
    --name <your-container-name>
    -v `pwd`/html:/var/www/html \
    -v `pwd`/data:/var/lib/mysql \
    -p 80:80 \
    -p 3306:3306 \
    -p 9001:9001 \
    -p 10001:10001 \
    appkr/lemp-base:18.04
```

If `80` and `3306` ports are not available on your host machine, you can map it like `-p 8000:80 -p 33060:3306`.

## 3. Test

- `http://localhost` to open a index page in document root of nginx.
- `$ mysql --h127.0.0.1 -uroot -P3306 -p` (Default password: `secret`).
- `http://localhost:9001` to open the supervisor dashboard (Default account: `homestead`/`secret`).
- Xdebug port is set to `10001`

## 4. Your Own Build

To build your own image:

```sh
~/ $ git clone git@github.com:appkr/lemp-base.git
~/ $ cd lemp-base
~/lemp-base $ docker build \
    --tag <name-your-image>:<tag> \
    .
```

To run your own build:

```sh
~/lemp-base $ docker run -d \
    --name <name-your-container>
    -v `pwd`/html:/var/www/html \
    -v `pwd`/data:/var/lib/mysql \
    -p 80:80 \
    -p 3306:3306 \
    -p 9001:9001 \
    -p 10001:10001 \
    <name-your-image>:<tag>
```

## 5. Troubleshooting

While building the Dockerfile, most of the errors were aroused from MySQL.

-   The first thing you have to look into is the logs. MySQL log lives in `/var/log/mysql/error.log`

-   "No directory, logging in with HOME=/" This happens when mysql user's home directory is not designated. Run `usermod -d /var/lib/mysql/ mysql` in the docker machine.

-   "Fatal error: Can't open and lock privileges table: Table 'mysql.user' does'nt exists" This happens when there is not `mysql.user` table. Stop the running container, remove all the content of local mounted volume for `/var/lib/mysql`(e.g. `data`), and then restart the container.

-   If MySQL `root@%` user was not correctly created:

    ```bash
    ~/any $ docker exec -it <container_name_or_hash> \
        mysql -v -e "CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%'; FLUSH PRIVILEGES;"
    ```

-   If MySql socket was not correctly created:

    ```bash
    ~/any $ docker exec -it <container_name_or_hash> \
        supervisorctl stop all \
        && rm -rf $MYSQL_DATA_DIR/* $MYSQL_PID_DIR \
        && bash /entrypoint.sh \
        && supervisorctl restart all
    ```

-   In most cases, starting from scratch is much easier. To do that run the following commands and re-iterate from the beginning:

    ```bash
    # Clean up the MySql data directory
    ~/lemp-base $ rm -rf data/*
    
    # Stop running container and remove it
    ~/any $ docker <container_name_or_hash> && docker rm <container_name_or_hash>
    
    # Remove image
    ~/any $ docker rmi --force <image_name_or_hash>
    ```

