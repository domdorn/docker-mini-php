FROM alpine:3.20

RUN apk add --update lighttpd php-fpm && rm -Rf /var/cache/apk/*

# set up folders, configure lighttpd and php-fpm
RUN mkdir -p /app/htdocs /app/error /etc/service/lighttpd /etc/service/php-fpm \
	&& sed -i -E \
		-e 's/var\.basedir\s*=\s*".*"/var.basedir = "\/app"/' \
		-e 's/#\s+(include "mod_fastcgi_fpm.conf")/\1/' \
		-e 's/#\s+server.port\s+=\s+81/server.port = 5000/' \
		/etc/lighttpd/lighttpd.conf \
	&& sed -i -E \
		-e 's/user\s*=\s*nobody/user = lighttpd/' \
		/etc/php83/php-fpm.conf \
	&& touch /var/log/php-fpm.log \
	&& chown -R lighttpd /var/log/php-fpm.log \
	&& echo -e "#!/bin/sh\nlighttpd -D -f /etc/lighttpd/lighttpd.conf" > /etc/service/lighttpd/run \
	&& echo -e "#!/bin/sh\nphp-fpm --nodaemonize" > /etc/service/php-fpm/run \
	&& chmod -R +x /etc/service/*


EXPOSE 5000

WORKDIR /app/htdocs

CMD runsvdir -P /etc/service
