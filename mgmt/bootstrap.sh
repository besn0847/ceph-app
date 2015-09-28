#!/bin/sh

/root/update-dns.sh

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf