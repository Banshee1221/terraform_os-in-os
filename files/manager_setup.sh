#!/bin/bash

# Set up keys

echo ssh-rsa ___YOUR_PUB_KEY___ > /home/ubuntu/.ssh/id_rsa.pub

cat << __EOF > /home/ubuntu/.ssh/id_rsa
<PRIVATE_KEY_DATA>
__EOF

chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/id_rsa
chmod 600 /home/ubuntu/.ssh/id_rsa.pub

# Bootstrap manager

apt update
apt install -y python-pip
pip install --upgrade pip==9.0.3
pip install kolla-ansible
pip install kolla
pip install ansible

mkdir -p /etc/kolla

cat << __EOF >> /etc/hosts
10.0.0.5    manager-01

10.0.0.201  ceph-mon1
10.0.0.202  ceph-mon2
10.0.0.203  ceph-mon3

10.0.0.211  ceph-osd1 
10.0.0.212  ceph-osd2
10.0.0.213  ceph-osd3

10.0.0.101  compute-01
10.0.0.102  compute-02
10.0.0.103  compute-03

10.0.0.11   controller-01
10.0.0.12   controller-02
10.0.0.13   controller-03
__EOF

mkdir -p /etc/ansible

cat << __EOF >> /etc/ansible/hosts
all:
  hosts:
    controller-01:
      ansible_user: ubuntu
      ansible_become: True
    controller-02:
      ansible_user: ubuntu
      ansible_become: True
    controller-03:
      ansible_user: ubuntu
      ansible_become: True
    compute-01:
      ansible_user: ubuntu
      ansible_become: True
    compute-02:
      ansible_user: ubuntu
      ansible_become: True
    compute-03:
      ansible_user: ubuntu
      ansible_become: True
    ceph-mon1:
      ansible_user: ubuntu
      ansible_become: True
    ceph-mon2:
      ansible_user: ubuntu
      ansible_become: True
    ceph-mon3:
      ansible_user: ubuntu
      ansible_become: True
    ceph-osd1:
      ansible_user: ubuntu
      ansible_become: True
    ceph-osd2:
      ansible_user: ubuntu
      ansible_become: True
    ceph-osd3:
      ansible_user: ubuntu
      ansible_become: True
  children:
    control:
      hosts:
        controller-01:
          ansible_user: ubuntu
          ansible_become: True
        controller-02:
          ansible_user: ubuntu
          ansible_become: True
        controller-03:
          ansible_user: ubuntu
          ansible_become: True
    compute:
      hosts:
        compute-01:
          ansible_user: ubuntu
          ansible_become: True
        compute-02:
          ansible_user: ubuntu
          ansible_become: True
        compute-03:
          ansible_user: ubuntu
          ansible_become: True
    mons:
      hosts:
        ceph-mon1:
          ansible_user: ubuntu
          ansible_become: True
        ceph-mon2:
          ansible_user: ubuntu
          ansible_become: True
        ceph-mon3:
          ansible_user: ubuntu
          ansible_become: True
    osds:
      hosts:
        ceph-osd1:
          ansible_user: ubuntu
          ansible_become: True
        ceph-osd2:
          ansible_user: ubuntu
          ansible_become: True
        ceph-osd3:
          ansible_user: ubuntu
          ansible_become: True
__EOF

sed -i '/search gate.idia.ac.za/d' /etc/resolv.conf

cat << __EOF > /home/ubuntu/.ssh/config
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
__EOF

chown ubuntu:ubuntu /home/ubuntu/.ssh/config