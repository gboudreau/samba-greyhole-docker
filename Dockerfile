FROM alpine:3.13

RUN apk --no-cache add \
    samba-common-tools samba-client samba-server \
    bash ncurses curl python3 gcc libc-dev perl make rpcgen file ssmtp supervisor gnutls-dev zlib-dev rsyslog \
    php8-cli php8-pdo_mysql php8-intl php8-mbstring php8-intl php8-mysqlnd php8-json php8-pcntl rsync lsof sysstat findutils gzip patch \
    && ln -s /usr/bin/php8 /usr/bin/php

# SSMTP (to be able to send emails)
COPY ssmtp.conf /etc/ssmtp/ssmtp.conf
RUN echo "hostname=$(hostname).home.danslereseau.com" >> /etc/ssmtp/ssmtp.conf

# Setup Greyhole for Samba
ARG GREYHOLE_VERSION=master
ADD "https://api.github.com/repos/gboudreau/Greyhole/commits?per_page=1" /tmp/latest_commit
RUN curl -Lo greyhole-master.zip https://github.com/gboudreau/Greyhole/archive/$GREYHOLE_VERSION.zip && \
    unzip greyhole-master.zip >/dev/null && \
    rm greyhole-master.zip && \
    cd Greyhole-* && \
	mkdir -p /var/spool/greyhole && \
	chmod 777 /var/spool/greyhole && \
	mkdir -p /usr/share/greyhole && \
	install -m 0755 -D -p greyhole /usr/share/greyhole/greyhole && \
	install -m 0755 -D -p greyhole-dfree /usr/bin && \
    install -m 0755 -D -p greyhole-php /usr/bin && \
    install -m 0755 -D -p greyhole-dfree.php /usr/share/greyhole && \
    install -m 0644 -D -p greyhole.cron.d /etc/cron.d/greyhole && \
    install -m 0755 -D -p greyhole.cron.weekly /etc/cron.weekly/greyhole && \
    install -m 0755 -D -p greyhole.cron.daily /etc/cron.daily/greyhole && \
    install -m 0755 -D -p build_vfs.sh /usr/share/greyhole/build_vfs.sh && \
	# WebUI
    install -m 0644 -D -p web-app/index.php /usr/share/greyhole/web-app/index.php && \
    install -m 0644 -D -p web-app/README /usr/share/greyhole/web-app/README && \
    install -m 0644 -D -p web-app/LICENSE.md /usr/share/greyhole/web-app/LICENSE.md && \
    install -m 0644 -D -p web-app/favicon.png /usr/share/greyhole/web-app/favicon.png && \
    install -m 0644 -D -p web-app/includes.inc.php /usr/share/greyhole/web-app/includes.inc.php && \
    install -m 0644 -D -p web-app/init.inc.php /usr/share/greyhole/web-app/init.inc.php && \
    install -m 0644 -D -p web-app/config_definitions.inc.php /usr/share/greyhole/web-app/config_definitions.inc.php && \
    install -m 0644 -D -p web-app/scripts.js /usr/share/greyhole/web-app/scripts.js && \
    install -m 0644 -D -p web-app/styles.css /usr/share/greyhole/web-app/styles.css && \
    install -m 0644 -D -p web-app/du/index.php /usr/share/greyhole/web-app/du/index.php && \
    install -m 0644 -D -p web-app/install/index.php /usr/share/greyhole/web-app/install/index.php && \
    install -m 0644 -D -p web-app/install/step1.inc.php /usr/share/greyhole/web-app/install/step1.inc.php && \
    install -m 0644 -D -p web-app/install/step2.inc.php /usr/share/greyhole/web-app/install/step2.inc.php && \
    install -m 0644 -D -p web-app/install/step3.inc.php /usr/share/greyhole/web-app/install/step3.inc.php && \
    install -m 0644 -D -p web-app/install/step4.inc.php /usr/share/greyhole/web-app/install/step4.inc.php && \
    install -m 0644 -D -p web-app/install/step5.inc.php /usr/share/greyhole/web-app/install/step5.inc.php && \
    install -m 0644 -D -p web-app/install/step6.inc.php /usr/share/greyhole/web-app/install/step6.inc.php && \
    install -m 0644 -D -p web-app/install/step7.inc.php /usr/share/greyhole/web-app/install/step7.inc.php && \
    install -m 0644 -D -p web-app/views/actions.php /usr/share/greyhole/web-app/views/actions.php && \
    install -m 0644 -D -p web-app/views/greyhole_config.php /usr/share/greyhole/web-app/views/greyhole_config.php && \
    install -m 0644 -D -p web-app/views/samba_config.php /usr/share/greyhole/web-app/views/samba_config.php && \
    install -m 0644 -D -p web-app/views/samba_shares.php /usr/share/greyhole/web-app/views/samba_shares.php && \
    install -m 0644 -D -p web-app/views/status.php /usr/share/greyhole/web-app/views/status.php && \
    install -m 0644 -D -p web-app/views/storage_pool.php /usr/share/greyhole/web-app/views/storage_pool.php && \
    install -m 0644 -D -p web-app/views/trash.php /usr/share/greyhole/web-app/views/trash.php && \
    mkdir -p /var/cache/greyhole-dfree && chmod 777 /var/cache/greyhole-dfree && \
    mv includes /usr/share/greyhole/ && \
    mv samba-module /usr/share/greyhole/ && \
    ln -s /config-greyhole/greyhole.conf /etc/greyhole.conf && \
    ln -s /usr/share/greyhole/greyhole /usr/bin/greyhole && \
	echo "include_path=.:/usr/share/php8:/usr/share/greyhole" > /etc/php8/conf.d/02_greyhole.ini

# Re-use pre-compiled .so or build a new one
WORKDIR /usr/share/greyhole/
COPY install_greyhole_vfs.sh .
RUN bash ./install_greyhole_vfs.sh

COPY start_greyhole_daemon.sh /start_greyhole_daemon.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/var/cache/samba", "/var/lib/samba", "/var/log/samba", "/run/samba", "/config-greyhole", "/usr/share/greyhole"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
