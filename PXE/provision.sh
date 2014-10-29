#!/bin/bash

#Install packages
apt-get update -qq
apt-get install -y apache2
apt-get install -y tftpd-hpa
apt-get install -y inetutils-inetd
apt-get install -y isc-dhcp-server

#Edit inetd.conf
if ! grep -q "tftpboot"; then
	echo "tftp    dgram   udp    wait    root    /usr/sbin/in.tftpd /usr/sbin/in.tftpd -s \
	/var/lib/tftpboot" >> /etc/inetd.conf
fi

#Download Ubuntu Server ISO
if [ ! -e /home/vagrant/ubuntu-14.04.1-server-amd64.iso ]; then
	wget -qP /home/vagrant/ http://releases.ubuntu.com/14.04/ubuntu-14.04.1-server-amd64.iso
fi

#Mount Ubuntu Server ISO
if [ ! -d /mnt/install ]; then
	mount -o loop /home/vagrant/ubuntu-14.04.1-server-amd64.iso /mnt
fi

#Create /var/www//html/ubuntu directory
if [ ! -d /var/www/html/ubuntu ]; then
	mkdir /var/www/html/ubuntu
fi

#Copy all files from mounted ISO to /var/www/html/ubuntu/
if [ ! -d /var/www/html/ubuntu/install ]; then
	cp -rf /mnt/* /var/www/html/ubuntu/
fi

#Copy files in netboot to /var/lib/tftpboot/
if [ ! -d /var/lib/tftpboot/ubuntu-installer ]; then
	cp -rf /mnt/install/netboot/* /var/lib/tftpboot/
fi

#Copy configuration files
cp /vagrant/tftpd-hpa /etc/default/
cp /vagrant/syslinux.cfg /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/
cp /vagrant/dhcpd.conf /etc/dhcp/
cp /vagrant/preseed.cfg /var/www/html/ubuntu/install/
cp /vagrant/ks.cfg /var/www/html/ubuntu/install/

#Restart services
service isc-dhcp-server restart
service tftpd-hpa restart
service apache2 restart
