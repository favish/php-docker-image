# PHP-FPM

### Notes
Includes php and several dependencies for Drupal and commonly used drupal modules:
* Redis Support
* GD
* Imagick (image derivatives for gifs with multiframe support)
* Storage backends: mysql and mongo
* multibyte strings (mbstring)
* opcache (speed improvement that avoids recompiling with every request)
* Blackfire probe for profiling (can be used on production with no performance penalty)

### Use
You should add some extra configuration via `.ini` or `.conf` files in `/usr/local/etc/php-fpm.d` for tuning opcache
and/or file upload limits.

### TODO
* Upgrade base image support to [bullseye](https://hub.docker.com/layers/php/library/php/7.3.33-fpm-bullseye/images/sha256-9cbff771dd3099b58ed1103d335ef7a30400db4201708a67b13d2d07260f2c8b?context=explore) - This should be a drop in replacement for most aspects of this image but needs to be tested. 

### Source
[Dockerfile on GitHub](https://github.com/favish/varnish-docker-image)