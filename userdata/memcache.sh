#!/bin/bash

set -e

echo "Updating packages..."
sudo apt update

echo "Installing Memcached..."
sudo apt install -y memcached libmemcached-tools

echo "Configuring Memcached..."

sudo sed -i 's/^-l .*/-l 0.0.0.0/' /etc/memcached.conf

sudo systemctl enable memcached
sudo systemctl restart memcached

echo "Opening firewall..."

sudo ufw allow 11211/tcp

echo "Checking service status..."

sudo systemctl status memcached --no-pager

echo "Done!"
