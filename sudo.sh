#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Disable su
mv /bin/su /bin/su.disabled

# Install sudo if not already installed
apt-get update
apt-get install -y sudo

# Add the user 'dc' to the sudo group
usermod -aG sudo dc

# Configure sudo to require the user's password
echo "dc ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "su has been disabled, sudo has been installed and configured for user 'dc'."

# Notify the user to log out and log back in to apply changes
echo "Please log out and log back in to apply the changes."
