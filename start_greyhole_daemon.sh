#!/bin/bash

n=$(grep daemon_niceness /etc/greyhole.conf | grep -v '#.*daemon_niceness' | sed 's/^.*= *\(.*\) *$/\1/')
/bin/nice -n "$n" /usr/bin/php /usr/bin/greyhole --daemon &

# Stop script
stop_script() {
    killall php
    exit 0
}
# Wait for supervisor to stop script
trap stop_script SIGINT SIGTERM

while true; do
    sleep 1
done
