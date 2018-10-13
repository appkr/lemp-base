FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive
ENV MYSQL_DATA_DIR=/var/lib/mysql
ENV MYSQL_PID_DIR=/var/run/mysqld
ENV MYSQL_ROOT_PASSWORD=root

#-------------------------------------------------------------------------------
# Install Packages
#-------------------------------------------------------------------------------

RUN { \
    echo mysql-community-server mysql-community-server/data-dir select ''; \
    echo mysql-community-server mysql-community-server/root-pass password ''; \
    echo mysql-community-server mysql-community-server/re-root-pass password ''; \
    echo mysql-community-server mysql-community-server/remove-test-db select false; \
} | debconf-set-selections

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        mysql-server \
        mysql-client \
        curl \
        locales \
        supervisor \
        ca-certificates \
        vim \
        php-fpm \
        php-cli \
        php-gd \
        php-mcrypt \
        php-mysql \
        php-curl \
        php-mbstring \
        php-sqlite3 \
        php-xdebug \
        php-xml \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#-------------------------------------------------------------------------------
# Install utf8 locales
#-------------------------------------------------------------------------------

RUN locale-gen en_US.UTF-8

#-------------------------------------------------------------------------------
# Copy Settings
#-------------------------------------------------------------------------------

COPY files /

#-------------------------------------------------------------------------------
# Enable nginx site
#-------------------------------------------------------------------------------

RUN mkdir -p /var/run/php
RUN sed -i "s/listen = .*/listen = 127.0.0.1:9000/" /etc/php/7.0/fpm/pool.d/www.conf
RUN ln -nfs /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

#-------------------------------------------------------------------------------
# Install Composer
#-------------------------------------------------------------------------------

# Doing a composer job in the host machine is best practice.
# If you need a composer in container, you can mount your local composer
#  to the container at run time, like:
#  docker run ... -v `which composer`:/usr/local/bin/composer ...

#RUN curl -sS https://getcomposer.org/installer | php -- \
#        --install-dir=${COMPOSER_HOME:-/usr/local/bin} \
#        --filename=composer \
#    && echo "" >> /root/.profile \
#    && echo 'export PATH="\$PATH:~/.composer/vendor/bin"' >> /root/.profile

#-------------------------------------------------------------------------------
# Set Volumes to Mount and Etc
#-------------------------------------------------------------------------------

VOLUME ["/var/www/html", "/var/lib/mysql"]
EXPOSE 80 9001 3306
WORKDIR /var/www/html
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]