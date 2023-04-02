#!/bin/bash


echo "Disabling IPv6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee /etc/sysctl.d/99-disable-ipv6.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.d/99-disable-ipv6.conf
sudo sysctl -p
echo "IPv6 disabled successfully"


sudo apt update
sudo apt install \
  ca-certificates \
  curl \
  gnupg \ 
  wget


sudo apt update
