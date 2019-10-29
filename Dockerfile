FROM alpine:3.10

VOLUME ["/var/cache/samba", "/var/lib/samba", "/var/log/samba", "/run/samba", "/usr/lib64/greyhole", "/var/spool/greyhole", "/config-greyhole"]

RUN apk --no-cache add \
    samba-common-tools samba-client samba-server \
    bash ncurses curl python3 gcc libc-dev perl make rpcgen php php-mbstring php-intl php-mysqlnd file ssmtp

# Setup Greyhole for Samba (will not run the Greyhole daemon)
RUN mkdir -p /usr/share/greyhole
WORKDIR /usr/share/greyhole
RUN curl -Lo greyhole-master.zip https://github.com/gboudreau/Greyhole/archive/master.zip && \
    unzip greyhole-master.zip >/dev/null && \
    rm greyhole-master.zip && \
    mv Greyhole-master/* . && \
    rm -rf Greyhole-master && \
    ln -s /usr/share/greyhole/greyhole-php /usr/bin/ && \
    ln -s /usr/share/greyhole/greyhole /usr/bin/ && \
    ln -s /usr/share/greyhole/greyhole-dfree /usr/bin/ && \
    ln -s /config-greyhole/greyhole.conf /etc/greyhole.conf && \
    echo "include_path=.:/usr/share/php7:/usr/share/greyhole" > /etc/php7/conf.d/02_greyhole.ini && \
    mkdir -p /var/cache/greyhole-dfree && chmod 777 /var/cache/greyhole-dfree

# Re-use pre-compiled .so or build a new one
ADD install_greyhole_vfs.sh .
RUN bash ./install_greyhole_vfs.sh

ENTRYPOINT ["smbd", "--foreground", "--log-stdout", "--no-process-group"]
CMD []
