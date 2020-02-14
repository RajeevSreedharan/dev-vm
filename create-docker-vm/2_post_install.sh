#!/bin/bash

# This script is a general post install task after OS installation
#      1. Disable auto updates
#      2. Disable SELinux and Firewall
#      3. Disable printing services
#      4. Increase yum repo timeout
#      5. Install general dependencies

# Disable auto updates
systemctl stop packagekit
systemctl disable packagekit
systemctl mask packagekit

# Disable SELinux and Firewall
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce Permissive
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
systemctl stop firewalld
systemctl disable firewalld

# Disable printing services
chkconfig --del cups

# Increase yum repo timeout
echo "minrate=1" >> /etc/yum.conf
echo "timeout=300" >> /etc/yum.conf

# Using CDROM instead of yum.oracle.com repository
# Insert the Oracle Linux DVD/*.iso and note to boot from disk instead of this DVD

mkdir /cdrom
mount /dev/cdrom /cdrom

cat > /etc/yum.repos.d/cdrom.repo <<EOF
[cdrom]
name=CDROM Repo
baseurl=file:///cdrom
enabled=1
gpgcheck=1
gpgkey=file:///cdrom/RPM-GPG-KEY-oracle
EOF

yum install kernel-uek-devel-$(uname -r)  # For Virtualbox guest additions

# Below dependencies may also be needed for other software e.g. Oracle DB 19c
yum install -y bc    
yum install -y binutils
yum install -y compat-libcap1
yum install -y compat-libstdc++-33
yum install -y dtrace-utils
yum install -y elfutils-libelf
yum install -y elfutils-libelf-devel
yum install -y fontconfig-devel
yum install -y glibc
yum install -y glibc-devel
yum install -y ksh
yum install -y libaio
yum install -y libaio-devel
yum install -y libdtrace-ctf-devel
yum install -y libXrender
yum install -y libXrender-devel
yum install -y libX11
yum install -y libXau
yum install -y libXi
yum install -y libXtst
yum install -y libgcc
yum install -y librdmacm-devel
yum install -y libstdc++
yum install -y libstdc++-devel
yum install -y libxcb
yum install -y make
yum install -y net-tools
yum install -y nfs-utils
yum install -y python
yum install -y python-configshell
yum install -y python-rtslib
yum install -y python-six
yum install -y targetcli
yum install -y smartmontools
yum install -y sysstat
yum install -y yum-utils

yum install -y "libXss.so.1()(64bit)"
yum install -y git

yum remove -y totem
