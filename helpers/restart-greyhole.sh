#!/bin/bash

set -e
cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1

sudo docker exec samba-greyhole /usr/bin/supervisorctl restart greyhole
