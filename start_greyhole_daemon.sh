#!/bin/bash

n=$(grep daemon_niceness /etc/greyhole.conf | grep -v '#.*daemon_niceness' | sed 's/^.*= *\(.*\) *$/\1/')
/bin/nice -n "$n" /usr/bin/php /usr/bin/greyhole --daemon &
PID=$(ps ax | grep "greyhole --daemon" | grep -v grep | grep -v bash | tail -1 | awk '{print $1}')
echo "Greyhole started with PID $PID."
export PID

# Stop script
stop_script() {
    echo "Stopping Greyhole with PID $PID..."
    kill "$PID"
    exit 0
}
# Wait for supervisor to stop script
trap stop_script SIGINT SIGTERM

while true; do
    sleep 1
done
