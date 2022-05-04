FROM php:8.1.5-fpm-alpine as php

ARG UID=1000
ARG GID=1000
ARG PHPREDIS_VERSION=5.3.7

RUN apk update && apk add --no-cache \
    vim \
    curl \
    git \
    npm \
    libzip \
    libpq \
    libgomp \
    libjpeg-turbo \
    libpng \
    freetype

RUN apk update && apk add --virtual .ext-deps \
    # pdo_pgsql deps
    postgresql-dev \
    # gd deps
    freetype-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libpng-dev \
    # zip deps
    libzip-dev \
    # install phpredis from github
    && mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    # install extensions
    && docker-php-ext-install -j "$(nproc)" \
    zip \
    pdo \
    pdo_pgsql \
    opcache \
    bcmath \
    sockets \
    redis \
    gd \
    exif \
    && apk del .ext-deps \
    && rm -rf /var/cache/apk/*

RUN addgroup -S php -g $GID \
    && adduser -u $UID -S -G php php \
    && mkdir /app \
    && chown php:php /app

COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer

COPY php.ini /usr/local/etc/php/conf.d/
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www.conf

WORKDIR /app

USER php