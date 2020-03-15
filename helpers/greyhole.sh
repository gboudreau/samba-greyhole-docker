#!/bin/bash

opts=""
if tty -s; then
    opts="-it"
fi
sudo docker exec $opts samba-greyhole /usr/bin/greyhole "$@"
