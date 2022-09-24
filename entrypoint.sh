#!/bin/bash

set -euo pipefail

# Create ssmtp.conf

MAILHOST="${MAILHOST:-"$(hostname)"}"
MAILDOMAIN="${MAILDOMAIN:-"home.danslereseau.com"}"
MAILROOT="${MAILROOT:-"postmaster"}"
MAILHUB="${MAILHUB:-"172.17.0.1:25"}"
MAILHOSTNAME="${MAILHOSTNAME:-"$MAILHOST.$MAILDOMAIN"}"

cat << EOF >/etc/ssmtp/ssmtp.conf
# The user that gets all the mails (UID < 1000, usually the admin)
root=$MAILROOT
# The mail server (where the mail is sent to), both port 465 or 587 should be acceptable
mailhub=$MAILHUB
# Email 'From header's can override the default domain?
FromLineOverride=YES
# The full hostname.  Must be correctly formed, fully qualified domain name or GMail will reject connection.
hostname=$MAILHOSTNAME
EOF

exec "$@"
