FROM php:8.1.0-fpm-alpine3.15

MAINTAINER Phil Taylor <phil@phil-taylor.com>

RUN apk update

RUN apk add --no-cache \
    wget                    \
    ca-certificates         \
    runit                   \
    libpng-dev              \
    gmp-dev                 \
    icu-dev                 \
    zlib-dev                \
    libxml2-dev             \
    libzip-dev              \
    sudo                    \
    curl                    \
    git                     \
    postfix                 \
    procps                  \
    gnupg                   \
    nginx                   \
    nginx-mod-http-nchan    \
    icu                     \
    && apk add --no-cache --virtual .build-deps m4 libbz2 perl pkgconf dpkg-dev libmagic file libgcc dpkg libstdc++ binutils gmp isl libgomp libatomic mpc1 gcc libc-dev musl-dev autoconf g++ re2c make build-base php-phpdbg\
    && apk upgrade \
    && update-ca-certificates \
    && wget https://pecl.php.net/get/redis-5.3.5RC1.tgz && pecl install redis-5.3.5RC1.tgz                                                    \
    && docker-php-ext-configure zip \
    && docker-php-ext-install gd gmp shmop opcache bcmath intl pdo_mysql pcntl soap zip \
    && apk del --no-cache build-base .build-deps \
    && rm -rf /var/cache/apk/*                                                          \
    && rm -rf /var/cache/fontcache/*                                                    \
    && rm -Rf /usr/local/bin/phpdbg \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini                             \
    && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /usr/local/etc/php/php.ini   \
    && sed -i 's/post_max_size = 8M/post_max_size = 65M/g' /usr/local/etc/php/php.ini               \
    && sed -i 's/log_errors = On/log_errors = Off/g' /usr/local/etc/php/php.ini                     \
    && sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /usr/local/etc/php/php.ini       \
    && echo '[global]' > /usr/local/etc/php-fpm.d/zz-docker.conf                           \
    && echo 'error_log = /proc/self/fd/2' >> /usr/local/etc/php-fpm.d/zz-docker.conf                    \
    && echo 'log_limit = 8192' >> /usr/local/etc/php-fpm.d/zz-docker.conf                    \
    && echo 'daemonize = no' >> /usr/local/etc/php-fpm.d/zz-docker.conf                    \
    && echo 'log_level = alert' >> /usr/local/etc/php-fpm.d/zz-docker.conf                    \
    && echo '[www]' >> /usr/local/etc/php-fpm.d/zz-docker.conf                             \
    && echo 'listen=9000' >> /usr/local/etc/php-fpm.d/zz-docker.conf                       \
    && echo ';access.log=' >> /usr/local/etc/php-fpm.d/zz-docker.conf                       \
    && echo 'clear_env = no' >> /usr/local/etc/php-fpm.d/zz-docker.conf                       \
    && echo 'catch_workers_output = yes' >> /usr/local/etc/php-fpm.d/zz-docker.conf                       \
    && echo 'decorate_workers_output = no' >> /usr/local/etc/php-fpm.d/zz-docker.conf                       \
    && echo 'realpath_cache_size=2048M' > /usr/local/etc/php/conf.d/pathcache.ini           \
    && echo 'realpath_cache_ttl=7200' >> /usr/local/etc/php/conf.d/pathcache.ini            \
    && echo '[opcache]' > /usr/local/etc/php/conf.d/opcache.ini                             \
    && echo 'opcache.enable_cli = 1' >> /usr/local/etc/php/conf.d/opcache.ini    \
    && echo 'opcache.memory_consumption = 512M' >> /usr/local/etc/php/conf.d/opcache.ini    \
    && echo 'opcache.max_accelerated_files = 1000000' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && echo "default_socket_timeout=1200" >> /usr/local/etc/php/php.ini                         \
    && mkdir -p /run/nginx/         \
    && mkdir -p /var/log/nginx/     \
    && rm -Rf /tmp/pear             \
    && rm -Rf /usr/local/etc/php-fpm.d/docker.conf             \
    && rm -rf /var/cache/apk/* \
    && rm -Rf /usr/src/php
