# Disable auto updates
systemctl stop packagekit
systemctl disable packagekit
systemctl mask packagekit

# Disable SELinux and Firewall
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce Permissive
systemctl stop firewalld
systemctl disable firewalld

# Disable printing services
chkconfig --del cups

# Increase yum repo timeout
echo "minrate=1" >> /etc/yum.conf
echo "timeout=300" >> /etc/yum.conf

# For Virtualbox guest additions, dependency kernel-uek-devel to be installed from DVD
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

yum install kernel-uek-devel-$(uname -r)
