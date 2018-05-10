#!/bin/bash

# Set up keys

echo ssh-rsa ___YOUR_PUB_KEY_HERE___ > /home/ubuntu/.ssh/id_rsa.pub

chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/id_rsa.pub

#for i in $(netstat -i | sed 1,2d | sed '$ d' | cut -f1 -d' '); do echo $i; done
for i in $(ip addr | grep ": e" | cut -d':' -f2)
do 
    printf "auto $i\niface $i inet dhcp\n\n" >> /etc/network/interfaces.d/51-custom.cfg
done

systemctl restart networking

apt update
apt install -y python python-simplejson

sed -i '/search gate.idia.ac.za/d' /etc/resolv.conf