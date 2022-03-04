FROM php:7.3.3-fpm-stretch

## Install general debian packages and php extensions
RUN apt-get update \
    && apt-get install -y \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libpq-dev \
        mysql-client \
        pkg-config \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install \
        gd \
        mbstring \
        mysqli \
        opcache \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        zip

# Install imagick
# https://github.com/docker-library/php/issues/105
RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install --onlyreqdeps --force \
        imagick-3.4.3 \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable imagick

# Install php mogo client
RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS"\
    && apt-get update \
    && apt-get install -y \
        autoconf \
        pkg-config \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install --onlyreqdeps --force \
        mongodb \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable mongodb

RUN apt-get update && apt-get upgrade -y --allow-unauthenticated

# Install php redis client
RUN pecl install --onlyreqdeps --force \
        redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# Enable blackfire
# Important adjustment from blackfire docs is that our agent is available on localhost right now
# If you move blackfire to a tools pod or something, update the blackfire.agent_socket below to a service exposing 8707 on that pod
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://127.0.0.1:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini

# Add composer vendor binaries to path, primarily for Drush
ENV PATH="/var/www/vendor/bin:${PATH}"

# Use the provided default configuration for a production environment.
# We will override anything needed for dev with overlayed configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN mkdir -p /var/www/docroot

WORKDIR /var/www/docroot
