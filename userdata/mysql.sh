#!/bin/bash

set -e

DATABASE_PASS="admin123"

echo "Updating system..."
sudo apt update
sudo apt upgrade -y

echo "Installing required packages..."
sudo apt install -y git zip unzip mariadb-server

echo "Starting MariaDB..."
sudo systemctl enable mariadb
sudo systemctl start mariadb

echo "Removing old project if it exists..."
rm -rf /tmp/vprofile-project

echo "Cloning repository..."
git clone https://github.com/hkhcoder/vprofile-project.git /tmp/vprofile-project

echo "Creating database and user..."

sudo mysql <<EOF
DROP DATABASE IF EXISTS accounts;
CREATE DATABASE accounts;

DROP USER IF EXISTS 'admin'@'%';
CREATE USER 'admin'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%';
FLUSH PRIVILEGES;
EOF

echo "Importing database..."

sudo mysql accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql

echo "Restarting MariaDB..."
sudo systemctl restart mariadb

echo "====================================="
echo "Installation completed successfully!"
echo "====================================="
echo "Database : accounts"
echo "Username : admin"
echo "Password : admin123"
