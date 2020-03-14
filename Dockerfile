FROM alpine:3.10

RUN apk --no-cache add \
    samba-common-tools samba-client samba-server \
    bash ncurses curl python3 gcc libc-dev perl make rpcgen file ssmtp supervisor \
    php7-cli php7-pdo_mysql php7-intl php7-mbstring php7-intl php7-mysqlnd php7-json php7-pcntl rsync lsof sysstat findutils

# SSMTP (to be able to send emails)
COPY ssmtp.conf /etc/ssmtp/ssmtp.conf
RUN echo "hostname=`hostname`.home.danslereseau.com" >> /etc/ssmtp/ssmtp.conf

# Setup Greyhole for Samba
RUN curl -Lo greyhole-master.zip https://github.com/gboudreau/Greyhole/archive/master.zip && \
    unzip greyhole-master.zip >/dev/null && \
    rm greyhole-master.zip && \
    cd Greyhole-master && \
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
    install -m 0644 -D -p web-app/index.php /usr/share/greyhole/web-app/index.php && \
    install -m 0755 -D -p build_vfs.sh /usr/share/greyhole/build_vfs.sh && \
    mkdir -p /var/cache/greyhole-dfree && chmod 777 /var/cache/greyhole-dfree && \
    mv includes /usr/share/greyhole/ && \
    mv samba-module /usr/share/greyhole/ && \
    ln -s /config-greyhole/greyhole.conf /etc/greyhole.conf && \
    ln -s /usr/share/greyhole/greyhole /usr/bin/greyhole && \
	echo "include_path=.:/usr/share/php7:/usr/share/greyhole" > /etc/php7/conf.d/02_greyhole.ini

# Re-use pre-compiled .so or build a new one
WORKDIR /usr/share/greyhole/
ADD install_greyhole_vfs.sh .
RUN bash ./install_greyhole_vfs.sh

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/var/cache/samba", "/var/lib/samba", "/var/log/samba", "/run/samba", "/config-greyhole", "/usr/share/greyhole"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
