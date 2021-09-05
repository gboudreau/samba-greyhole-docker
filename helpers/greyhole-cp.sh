#!/bin/bash

opts=""
if tty -s; then
    opts="-it"
fi

first_char=${1:0:1}
if [ "$first_char" != "/" ]; then
    sudo docker exec $opts -e "IN_DOCKER=1" samba-greyhole /usr/bin/cpgh "$(pwd)/$@"
else
    sudo docker exec $opts -e "IN_DOCKER=1" samba-greyhole /usr/bin/cpgh "$@"
fi
