#!/bin/sh

# Step : Bootstrap Ceph MON
MON0=`grep mon0 /etc/hosts | awk '{print $1}' -`
SUBNET=`echo $MON0 | awk -F"." '{print $1"."$2"."$3".0"}' -`

cp ceph.conf /tmp
cat /tmp/ceph.conf | sed -e "s/__MON_HOST__/$MON0/g" | sed -e "s/__DOCKER_SUBNET__/$SUBNET/g" > ceph.conf
scp ceph.conf ceph@mon0:/home/ceph

cp init-mon.sh /tmp
cat /tmp/init-mon.sh | sed -e "s/__MON_HOST__/$MON0/g" > init-mon.sh
scp init-mon.sh ceph@mon0:/home/ceph

ssh ceph@mon0 'sudo /home/ceph/init-mon.sh'

scp ceph@mon0:/home/ceph/ceph.client.admin.keyring .
scp ceph.client.admin.keyring ceph@osd0:/home/ceph/
scp ceph.client.admin.keyring ceph@osd1:/home/ceph/

# Step : Bootstrap Ceph OSDs
scp ceph.conf ceph@osd0:/home/ceph
scp ceph.conf ceph@osd1:/home/ceph

scp init-osd.sh ceph@osd0:/home/ceph
scp init-osd.sh ceph@osd1:/home/ceph

ssh ceph@osd0 'sudo /home/ceph/init-osd.sh 0 osd0'
ssh ceph@osd1 'sudo /home/ceph/init-osd.sh 1 osd1'

# Step : Bootstrap Ceph MDS
scp ceph.client.admin.keyring ceph@mdc0:/home/ceph/

scp ceph.conf ceph@mdc0:/home/ceph

scp init-mds.sh ceph@mdc0:/home/ceph

ssh ceph@mdc0 'sudo /home/ceph/init-mds.sh 0 mon0'

# Step : Mount CephFS drive
KEY=`grep "key = " ceph.client.admin.keyring | awk -F "key = " '{ print $2}' -`
echo "To mount the Ceph FS drive, run : "
echo "sudo mount -t ceph mon0:6789:/ <your_mount_point> -o name=admin,secret="$KEY

