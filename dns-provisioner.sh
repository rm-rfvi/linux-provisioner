#!/bin/bash

# Create necessary directories
mkdir -p /opt/docker/run/pihole/etc-pihole
mkdir -p /opt/docker/run/pihole/etc-dnsmasq.d
mkdir -p /opt/docker/run/portainer/data



# Create the 01-pihole.conf file
cat > /opt/docker/run/pihole/etc-dnsmasq.d/01-pihole.conf << EOF


EOF



#set file permissions
chown -R 999:999 /opt/docker/run/pihole/etc-pihole
chown -R 999:999 /opt/docker/run/pihole/etc-dnsmasq.d
chmod 644 /opt/docker/run/pihole/etc-dnsmasq.d/01-pihole.conf

systemctl disable systemd-resolved.service
systemctl stop systemd-resolved.service
