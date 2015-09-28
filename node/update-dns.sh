#!/bin/sh

cat << EOF | /usr/bin/nsupdate -k /etc/bind/int.docker.net.keys 
server dns
zone int.docker.net 
update delete `hostname`.int.docker.net. 
update add `hostname`.int.docker.net. 60 A `/sbin/ifconfig eth0 | grep "inet addr" | awk '{print $2}' - | sed -e 's/addr://g'` 
update add `hostname`.int.docker.net. 60 TXT "Updated on ".`date` 
send
EOF

cat > /etc/resolv.conf << EOF
search int.docker.net
nameserver `grep dns /etc/hosts | awk '{print $1}' -` 
EOF
