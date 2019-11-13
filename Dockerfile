# docker build . --no-cache --tag registry.myjoomla.com/base-nginx-php
# docker push registry.myjoomla.com/base-nginx-php
# test: docker run -it --rm registry.myjoomla.com/base-nginx-php sh
# 458Mb 363MB

FROM php:7.3.11-fpm-alpine3.9
#FROM registry.myjoomla.com/php-7.3.2-fpm-alpine3.9

MAINTAINER Phil Taylor <phil@phil-taylor.com>

RUN printf "%s%s%s\n" \
    "http://nginx.org/packages/mainline/alpine/v" \
    `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
    "/main" \
    | tee -a /etc/apk/repositories &&  curl -o /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub

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
    procps                  \
    gnupg                   \
    nginx                   \
    icu                     \
    fontconfig              \
    msttcorefonts-installer \
    && apk add --no-cache --virtual .build-deps m4 libbz2 perl pkgconf dpkg-dev libmagic file libgcc dpkg libstdc++ binutils gmp isl libgomp libatomic mpc1 mpfr3 gcc libc-dev musl-dev autoconf g++ re2c make build-base php-phpdbg \
    && pecl install redis-4.3.0                                                         \
    && update-ca-certificates && update-ms-fonts && fc-cache -f                         \
    && docker-php-ext-configure zip --with-libzip                                       \
    && docker-php-ext-install gd gmp shmop opcache bcmath intl pdo_mysql pcntl soap zip \
    && docker-php-source delete \
    && apk del --no-cache build-base .build-deps \
    && rm -rf /var/cache/apk/*                                                          \
    && rm -rf /var/cache/fontcache/*                                                    \
    && rm -rf /usr/src/php.tar.xz                                                       \
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
    && echo 'extension=redis' > /usr/local/etc/php/conf.d/redis.ini                         \
    && echo 'realpath_cache_size=2048M' > /usr/local/etc/php/conf.d/pathcache.ini           \
    && echo 'realpath_cache_ttl=7200' >> /usr/local/etc/php/conf.d/pathcache.ini            \
    && echo '[opcache]' > /usr/local/etc/php/conf.d/opcache.ini                             \
    && echo 'opcache.memory_consumption = 512M' >> /usr/local/etc/php/conf.d/opcache.ini    \
    && echo 'opcache.max_accelerated_files = 1000000' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && echo 'extension=redis' > /usr/local/etc/php/conf.d/redis.ini                             \
    && echo "default_socket_timeout=1200" >> /usr/local/etc/php/php.ini                         \
    && mkdir -p /run/nginx/         \
    && mkdir -p /var/log/nginx/     \
    && rm -Rf /tmp/pear             \
    && rm -rf /var/cache/apk/*


