# Build the image once via CircleCI before running dev
# This adds uprofiler and xdebug on top of dev and adjusts opcache settings
FROM favish/php-7.3-fpm:1.0.0

WORKDIR /var/www/docroot

RUN pecl install \
	xdebug \
	&& docker-php-ext-enable \
	xdebug

# ZZ prefix to ensure configs are loaded after docker-ext configs added by the php container
COPY zz-xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug.ini

ENV XDEBUG_REMOTE_HOST="host.docker.internal"