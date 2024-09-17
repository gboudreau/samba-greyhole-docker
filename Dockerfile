# syntax = docker/dockerfile-upstream:master-labs

FROM alpine:3.20

ARG PHP_VERSION=php

RUN <<EOF
set -xe
apk --no-cache add \
samba-common-tools samba-client samba-server \
bash ncurses curl python3 gcc libc-dev perl make rpcgen file ssmtp supervisor gnutls-dev zlib-dev rsyslog \
$PHP_VERSION-cli $PHP_VERSION-pdo_mysql $PHP_VERSION-intl $PHP_VERSION-mbstring $PHP_VERSION-intl $PHP_VERSION-mysqlnd $PHP_VERSION-json $PHP_VERSION-pcntl rsync lsof sysstat findutils gzip patch
if [ ! -f /usr/bin/php ]; then ln -s /usr/bin/$PHP_VERSION /usr/bin/php ; fi
EOF

COPY --chmod=755 --link entrypoint.sh /entrypoint.sh
COPY --chmod=755 --link start_greyhole_daemon.sh /start_greyhole_daemon.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

WORKDIR /usr/share/greyhole
#COPY alpine-samba-patches/*.patch ./
COPY --chmod=755 --link install_greyhole_vfs.sh ./

# Default to building from master branch; specify another branch or a git tag using a Docker build argument: --build-arg "GREYHOLE_VERSION=0.15.18"
ARG GREYHOLE_VERSION=master

# Clone Greyhole from Github, and install it
ADD --link --keep-git-dir=false "https://github.com/gboudreau/Greyhole.git#$GREYHOLE_VERSION" /greyhole-install

RUN <<EOF
set -xe

cd /greyhole-install

# Greyhole
mkdir -p /var/spool/greyhole
chmod 777 /var/spool/greyhole
install -m 0755 -D -p greyhole /usr/share/greyhole
install -m 0755 -D -p greyhole-dfree /usr/share/greyhole
install -m 0755 -D -p greyhole-php /usr/share/greyhole
install -m 0755 -D -p greyhole-dfree.php /usr/share/greyhole
install -m 0644 -D -p greyhole.cron.d /etc/cron.d/greyhole
install -m 0755 -D -p greyhole.cron.weekly /etc/cron.weekly/greyhole
install -m 0755 -D -p greyhole.cron.daily /etc/cron.daily/greyhole
install -m 0755 -D -p build_vfs.sh /usr/share/greyhole/build_vfs.sh

# WebUI
install -m 0644 -D -p web-app/index.php /usr/share/greyhole/web-app/index.php
install -m 0644 -D -p web-app/README /usr/share/greyhole/web-app/README
install -m 0644 -D -p web-app/LICENSE.md /usr/share/greyhole/web-app/LICENSE.md
install -m 0644 -D -p web-app/favicon.png /usr/share/greyhole/web-app/favicon.png
install -m 0644 -D -p web-app/includes.inc.php /usr/share/greyhole/web-app/includes.inc.php
install -m 0644 -D -p web-app/init.inc.php /usr/share/greyhole/web-app/init.inc.php
install -m 0644 -D -p web-app/config_definitions.inc.php /usr/share/greyhole/web-app/config_definitions.inc.php
install -m 0644 -D -p web-app/scripts.js /usr/share/greyhole/web-app/scripts.js
install -m 0644 -D -p web-app/styles.css /usr/share/greyhole/web-app/styles.css
install -m 0644 -D -p web-app/du/index.php /usr/share/greyhole/web-app/du/index.php
install -m 0644 -D -p web-app/install/index.php /usr/share/greyhole/web-app/install/index.php
install -m 0644 -D -p web-app/install/step1.inc.php /usr/share/greyhole/web-app/install/step1.inc.php
install -m 0644 -D -p web-app/install/step2.inc.php /usr/share/greyhole/web-app/install/step2.inc.php
install -m 0644 -D -p web-app/install/step3.inc.php /usr/share/greyhole/web-app/install/step3.inc.php
install -m 0644 -D -p web-app/install/step4.inc.php /usr/share/greyhole/web-app/install/step4.inc.php
install -m 0644 -D -p web-app/install/step5.inc.php /usr/share/greyhole/web-app/install/step5.inc.php
install -m 0644 -D -p web-app/install/step6.inc.php /usr/share/greyhole/web-app/install/step6.inc.php
install -m 0644 -D -p web-app/install/step7.inc.php /usr/share/greyhole/web-app/install/step7.inc.php
install -m 0644 -D -p web-app/views/actions.php /usr/share/greyhole/web-app/views/actions.php
install -m 0644 -D -p web-app/views/greyhole_config.php /usr/share/greyhole/web-app/views/greyhole_config.php
install -m 0644 -D -p web-app/views/samba_config.php /usr/share/greyhole/web-app/views/samba_config.php
install -m 0644 -D -p web-app/views/samba_shares.php /usr/share/greyhole/web-app/views/samba_shares.php
install -m 0644 -D -p web-app/views/status.php /usr/share/greyhole/web-app/views/status.php
install -m 0644 -D -p web-app/views/storage_pool.php /usr/share/greyhole/web-app/views/storage_pool.php
install -m 0644 -D -p web-app/views/trash.php /usr/share/greyhole/web-app/views/trash.php

# Finalize install
mkdir -p /var/cache/greyhole-dfree
chmod 777 /var/cache/greyhole-dfree
mv includes /usr/share/greyhole/
mv samba-module /usr/share/greyhole/
ln -s /config-greyhole/greyhole.conf /etc/greyhole.conf
ln -s /usr/share/greyhole/greyhole /usr/bin/greyhole
ln -s /usr/share/greyhole/greyhole-dfree /usr/bin/greyhole-dfree
ln -s /usr/share/greyhole/greyhole-php /usr/bin/greyhole-php
ln -s /usr/share/greyhole/greyhole /usr/bin/cpgh
echo "include_path=.:/usr/share/php83:/usr/share/greyhole" > /etc/php83/conf.d/02_greyhole.ini

# Re-use pre-compiled .so or build a new one \
cd /usr/share/greyhole
bash ./install_greyhole_vfs.sh
EOF

VOLUME ["/var/cache/samba", "/var/lib/samba", "/var/log/samba", "/run/samba", "/config-greyhole", "/usr/share/greyhole"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
