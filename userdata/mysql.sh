#!/bin/bash

DATABASE_PASS='admin123'

# Update system
sudo dnf update -y

# Install required packages
sudo dnf install -y git zip unzip mariadb105-server

# Start & enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Clone project
cd /tmp
git clone -b aws-LiftAndShift https://github.com/hkhcoder/vprofile-project.git

# Secure MariaDB & setup DB
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DATABASE_PASS}';"
sudo mysql -uroot -p"${DATABASE_PASS}" -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -uroot -p"${DATABASE_PASS}" -e "DROP DATABASE IF EXISTS test;"
sudo mysql -uroot -p"${DATABASE_PASS}" -e "FLUSH PRIVILEGES;"

# Create database & user
sudo mysql -uroot -p"${DATABASE_PASS}" -e "CREATE DATABASE accounts;"
sudo mysql -uroot -p"${DATABASE_PASS}" -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'admin123';"
sudo mysql -uroot -p"${DATABASE_PASS}" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%';"
sudo mysql -uroot -p"${DATABASE_PASS}" -e "FLUSH PRIVILEGES;"

# Restore database
sudo mysql -uroot -p"${DATABASE_PASS}" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql

# Restart MariaDB
sudo systemctl restart mariadb
