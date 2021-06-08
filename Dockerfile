# docker build . --no-cache --tag philetaylor/base-nginx-php
# docker push philetaylor/base-nginx-php
# test: docker run -it --rm philetaylor/base-nginx-php  sh
# 458Mb 363MB

FROM php:8-fpm-alpine3.13

MAINTAINER Phil Taylor <phil@phil-taylor.com>

# RUN sed -i -e 's/v[[:digit:]]\..*\//edge\//g' /etc/apk/repositories

RUN apk update

RUN apk add --no-cache \
    wget                    \
    ca-certificates         \
    supervisor              \
    libpng-dev              \
    gmp-dev                 \
    icu-dev                 \
    zlib-dev                \
    libxml2-dev             \
    libzip-dev              \
    sudo                    \
    curl                    \
    htop                    \
    httpie                  \
    postfix                 \
    procps                  \
    gnupg                   \
    nginx                   \
    nginx-mod-http-nchan    \
    icu                     \
    && apk add --no-cache --virtual .build-deps m4 libbz2 perl pkgconf dpkg-dev libmagic file libgcc dpkg libstdc++ binutils gmp isl libgomp libatomic mpc1 gcc libc-dev musl-dev autoconf g++ re2c make build-base php-phpdbg \
    && update-ca-certificates \
    && wget https://pecl.php.net/get/redis-5.3.4.tgz && pecl install redis-5.3.4.tgz                                                    \
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
    && echo '[global]' > /usr/local/etc/php/conf.d/zz-docker.conf                           \
    && echo 'daemonize = no' >> /usr/local/etc/php/conf.d/zz-docker.conf                    \
    && echo '[www]' >> /usr/local/etc/php/conf.d/zz-docker.conf                             \
    && echo 'listen=9000' >> /usr/local/etc/php/conf.d/zz-docker.conf                       \
    && echo 'realpath_cache_size=2048M' > /usr/local/etc/php/conf.d/pathcache.ini           \
    && echo 'realpath_cache_ttl=7200' >> /usr/local/etc/php/conf.d/pathcache.ini            \
    && echo '[opcache]' > /usr/local/etc/php/conf.d/opcache.ini                             \
    && echo 'opcache.memory_consumption = 512M' >> /usr/local/etc/php/conf.d/opcache.ini    \
    && echo 'opcache.max_accelerated_files = 1000000' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && echo "default_socket_timeout=1200" >> /usr/local/etc/php/php.ini                         \
    && mkdir -p /run/nginx/         \
    && mkdir -p /var/log/nginx/     \
    && rm -Rf /tmp/pear             \
    && rm -rf /var/cache/apk/* \
    && rm -Rf /usr/src/php
