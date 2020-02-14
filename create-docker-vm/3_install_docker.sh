#!/bin/bash

# Secondary disk OEL7_Docker_disk1.vdi added using VBoxMange
# Use fdisk to partition. 
# Post parition docker-storage-config can auto format and prepare /var/lib/docker to point to new btrfs partition

cd /etc/yum.repos.d/
wget http://yum.oracle.com/public-yum-ol7.repo

yum-config-manager --enable ol7_optional_latest
yum-config-manager --enable ol7_addons

yum install -y docker-engine btrfs-progs btrfs-progs-devel

docker-storage-config -s btrfs -d /dev/sdb1

systemctl enable docker.service
systemctl start docker.service

# dev-mirrors for local mirrors 

systemctl restart docker.service 
