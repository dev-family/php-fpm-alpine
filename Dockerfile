FROM php:7.4.14-fpm-alpine as php

RUN apk update \
&& docker-php-source extract \
&& apk add --no-cache --virtual .build-dependencies \
    $PHPIZE_DEPS \
    pcre-dev \
    build-base \
&& apk add --no-cache \
    shadow \
    vim \
    curl \
    git \
    postgresql-dev \
    xdg-utils \
    imagemagick6-dev \
    libzip-dev \
    # for GD
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
&& docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
&& docker-php-ext-configure exif \
&& docker-php-ext-install -j"$(getconf _NPROCESSORS_ONLN)" \
    intl \
    exif \
    zip \
    pdo_pgsql \
    gd \
    opcache \
&& printf "yes\n" | pecl install mongodb-1.9.0 \
&& printf "yes\n" | pecl install imagick-3.4.4 \
&& printf "yes\n" | pecl install -D 'enable-redis-igbinary="no"' redis-5.3.2 \
&& docker-php-ext-configure exif \
&& docker-php-ext-enable \
    redis \
    mongodb \
    imagick \
    opcache \
&& apk del .build-dependencies \
&& docker-php-source delete \
&& rm -rf /tmp/* /var/cache/apk/*
