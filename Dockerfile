# docker build . --tag registry.myjoomla.com/base-nginx-php
# docker push registry.myjoomla.com/base-nginx-php

FROM php:7.3.1-fpm-alpine3.8

MAINTAINER Phil Taylor <phil@phil-taylor.com>

RUN   apk update \
    &&   apk add ca-certificates wget\
    &&   update-ca-certificates

RUN apk  add  --no-cache --update --virtual  \
    # Base
    buildDeps \
    gcc \
    autoconf \
    build-base 
 
RUN apk  add  --no-cache --update \
    supervisor              \
    sudo                           \
    git                     \
    curl                    \
    htop                    \
    httpie                  \
    nano                    \
    procps                  \
    zlib-dev\
    libzip-dev   \
    gnupg                   \
    nginx  \
    gmp-dev\
    libxml2-dev\
    icu-dev \
    icu 


RUN docker-php-ext-install gmp 
RUN docker-php-ext-install shmop 
RUN docker-php-ext-install opcache
RUN docker-php-ext-install bcmath 
RUN docker-php-ext-install pdo_mysql 
RUN docker-php-ext-install pcntl  
RUN docker-php-ext-install soap
RUN docker-php-ext-configure zip --with-libzip 
RUN docker-php-ext-install zip  
RUN docker-php-ext-enable zip  
RUN pecl install redis-4.2.0 
RUN apk del buildDeps

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini 

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/g' /usr/local/etc/php/php.ini   \
    && sed -i 's/post_max_size = 8M/post_max_size = 64M/g' /usr/local/etc/php/php.ini            \
    && sed -i 's/log_errors = On/log_errors = Off/g' /usr/local/etc/php/php.ini                 \
    && sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /usr/local/etc/php/php.ini                 \
    && echo '[global]' > /usr/local/etc/php/conf.d/zz-docker.conf                          \
    && echo 'daemonize = no' >> /usr/local/etc/php/conf.d/zz-docker.conf                   \
    && echo '[www]' >> /usr/local/etc/php/conf.d/zz-docker.conf                            \
    && echo 'listen=9000' >> /usr/local/etc/php/conf.d/zz-docker.conf                      \
    && echo 'extension=redis' > /usr/local/etc/php/conf.d/redis.ini                        \
# PHP CLI
    && echo 'realpath_cache_size=2048M' > /usr/local/etc/php/conf.d/pathcache.ini         \
    && echo 'realpath_cache_ttl=7200' >> /usr/local/etc/php/conf.d/pathcache.ini          \
    && echo '[opcache]' > /usr/local/etc/php/conf.d/opcache.ini                           \
    && echo 'opcache.memory_consumption = 512M' >> /usr/local/etc/php/conf.d/opcache.ini  \
    && echo 'opcache.max_accelerated_files = 1000000' >> /usr/local/etc/php/conf.d/opcache.ini \
    && echo 'extension=redis' > /usr/local/etc/php/conf.d/redis.ini \
    && echo "default_socket_timeout=1200" >> /usr/local/etc/php/php.ini \
# Others
    && mkdir -p /run/nginx/     \
    && mkdir -p /var/log/nginx/ \
    && rm -Rf /tmp/pear
