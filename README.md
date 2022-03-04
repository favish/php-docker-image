# PHP Xdebug

### Notes
This image is based off of [favish/php7-fpm:X.X.X](https://hub.docker.com/r/favish/php-7-fpm/tags) and should only be used to specifically run xdebug workloads.

Other php images do not include xdebug because it slows performance just by being added as a php extension.

### Use
You will need to set the `XDEBUG_REMOTE_HOST` environment variable to the IP or hostname of the machine you wish
to connect and run Xdebug with. This defaults to `host.docker.internal` which allows the host to connect when running Docker for Mac.

We usually use an HTTP header conditional in the NGINX location {} for the fastcgi fpm proxypass. We push the request to the regular image unless a xdebug cookie or query string parameter is present:

```ini
# Start xdebug config
# Setting cookie or args in request will pass off to xdebug php
if ($http_cookie ~* "xdebug") {
  fastcgi_pass xdebug.{{ .Release.Namespace }}.svc.cluster.local:9000;
  break;
}
if ($args ~* "xdebug") {
  fastcgi_pass xdebug.{{ .Release.Namespace }}.svc.cluster.local:9000;
  break;
}
# End xdebug config

fastcgi_pass php.{{ .Release.Namespace }}.svc.cluster.local:9000;
```

### Updating
Its important to keep the xdebug and regular fpm containers on the same version for successful debugging. When you make a new [favish/php7-fpm:X.X.X](https://hub.docker.com/r/favish/php-7-fpm/tags) image you'll need ot build a new one of these too to match. Just update the base image in this docker file to match the image you made for regular php7-fpm (e.g. `favish/php-7-fpm:1.0.0`) then tag this branch as `favish/php7-fpm:X.X.X-xdebug`. Use both images in your cluster and youre good to go.