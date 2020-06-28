FROM dragoncrafted87/alpine-supervisord:latest

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="DragonCrafted87 Alpine Greyhole" \
      org.label-schema.description="Alpine Image with additional controls from supervisord to enable gracefull server shudown." \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/DragonCrafted87/docker-alpine-greyhole" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

COPY root/. /

# Create symbolic links for the config data
RUN ln -s /mnt/config/greyhole.conf /etc/greyhole.conf && \
    ln -s /mnt/config/etc_samba /etc/samba && \
    ln -s /mnt/config/var_lib_samba /var/lib/samba

# Install all the things!
RUN apk --no-cache add \
    bash \
    curl \
    file \
    findutils \
    gcc \
    gnutls-dev \
    libc-dev \
    lsof \
    make \
    ncurses \
    patch \
    perl \
    php7-cli \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mysqlnd \
    php7-pcntl \
    php7-pdo_mysql \
    rpcgen \
    rsync \
    rsyslog \
    samba-client \
    samba-common-tools \
    samba-server \
    ssmtp \
    sysstat \
    zlib-dev \
    zutils

# SSMTP (to be able to send emails)
#RUN echo "hostname=`hostname`.home.danslereseau.com" >> /etc/ssmtp/ssmtp.conf

# Setup Greyhole for Samba
ARG GREYHOLE_VERSION=master
RUN curl -Lo greyhole-master.zip https://github.com/gboudreau/Greyhole/archive/$GREYHOLE_VERSION.zip && \
    unzip greyhole-master.zip > /dev/null && \
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
    install -m 0644 -D -p web-app/index.php /usr/share/greyhole/web-app/index.php && \
    install -m 0755 -D -p build_vfs.sh /usr/share/greyhole/build_vfs.sh && \
    mkdir -p /var/cache/greyhole-dfree && chmod 777 /var/cache/greyhole-dfree && \
    mv includes /usr/share/greyhole/ && \
    mv samba-module /usr/share/greyhole/ && \
    ln -s /usr/share/greyhole/greyhole /usr/bin/greyhole && \
	  echo "include_path=.:/usr/share/php7:/usr/share/greyhole" > /etc/php7/conf.d/02_greyhole.ini && \
	  PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Parse::Yapp::Driver'

# build samba vfs
RUN cd /usr/share/greyhole/ && \
    chmod 755 install_greyhole_vfs.sh && \
    ./install_greyhole_vfs.sh

WORKDIR /root

CMD ["/docker_service_init"]
